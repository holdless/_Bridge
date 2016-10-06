void *worker_thread(void *arg)
{
  //Camera variables
  MMAL_COMPONENT_T *camera = 0;
  MMAL_ES_FORMAT_T *format;
  MMAL_STATUS_T status;
  MMAL_PORT_T *camera_video_port = NULL;

  //Encoder variables
  MMAL_COMPONENT_T *encoder = 0;
  MMAL_PORT_T *encoder_input = NULL;
  MMAL_PORT_T *encoder_output = NULL;
  MMAL_POOL_T *pool;
  MMAL_CONNECTION_T *encoder_connection;

  //fps count
  struct timespec t_start, t_finish;
  double t_elapsed;
  int frames;

  //Create camera code
  bcm_host_init();
  DBG("Host init, starting mmal stuff\n");

  status = mmal_component_create(MMAL_COMPONENT_DEFAULT_CAMERA, &camera);
  camera_video_port = camera->output[MMAL_CAMERA_VIDEO_PORT];

  {
    MMAL_PARAMETER_CAMERA_CONFIG_T cam_config = {
      { MMAL_PARAMETER_CAMERA_CONFIG, sizeof (cam_config)},
      .max_stills_w = width,
      .max_stills_h = height,
      .stills_yuv422 = 0,
      .one_shot_stills = (usestills ? 1 : 0),
      .max_preview_video_w = width,
      .max_preview_video_h = height,
      .num_preview_video_frames = 3,
      .stills_capture_circular_buffer_height = 0,
      .fast_preview_resume = 0,
      .use_stc_timestamp = MMAL_PARAM_TIMESTAMP_MODE_RESET_STC
    };
    mmal_port_parameter_set(camera->control, &cam_config.hdr);
  }

  //Set camera parameters
  if (raspicamcontrol_set_all_parameters(camera, &c_params))
  {
    fprintf(stderr, "camera parameters couldn't be set\n");
  }
  
  {
    // Set the encode format on the video port
    format = camera_video_port->format;
    format->encoding_variant = MMAL_ENCODING_I420;
    format->encoding = MMAL_ENCODING_I420;
    format->es->video.width = width;
    format->es->video.height = height;
    format->es->video.crop.x = 0;
    format->es->video.crop.y = 0;
    format->es->video.crop.width = width;
    format->es->video.crop.height = height;
    format->es->video.frame_rate.num = fps;
    format->es->video.frame_rate.den = 1;
    status = mmal_port_format_commit(camera_video_port);
    if (status)
      fprintf(stderr, "camera video format couldn't be set");

    // Ensure there are enough buffers to avoid dropping frames
    if (camera_video_port->buffer_num < VIDEO_OUTPUT_BUFFERS_NUM)
      camera_video_port->buffer_num = VIDEO_OUTPUT_BUFFERS_NUM;
  }

  /* Enable component */
  status = mmal_component_enable(camera);

  //// Camera enabled, creating encoder ////
  //Create Encoder
  status = mmal_component_create(MMAL_COMPONENT_DEFAULT_IMAGE_ENCODER, &encoder);

  encoder_input = encoder->input[0];
  encoder_output = encoder->output[0];
  // We want same format on input and output
  mmal_format_copy(encoder_output->format, encoder_input->format);
  // Specify out output format JPEG
  encoder_output->format->encoding = MMAL_ENCODING_JPEG;
  encoder_output->buffer_size = encoder_output->buffer_size_recommended;

  if (encoder_output->buffer_size < encoder_output->buffer_size_min)
    encoder_output->buffer_size = encoder_output->buffer_size_min;

  encoder_output->buffer_num = encoder_output->buffer_num_recommended;

  if (encoder_output->buffer_num < encoder_output->buffer_num_min)
    encoder_output->buffer_num = encoder_output->buffer_num_min;

  // Commit the port changes to the output port
  status = mmal_port_format_commit(encoder_output);
  // Set the JPEG quality level
  status = mmal_port_parameter_set_uint32(encoder_output, MMAL_PARAMETER_JPEG_Q_FACTOR, quality);
  // Enable encoder component
  status = mmal_component_enable(encoder);

  //// Encoder enabled, creating pool and connecting ports ////
  /* Create pool of buffer headers for the output port to consume */
  pool = mmal_port_pool_create(encoder_output, encoder_output->buffer_num, encoder_output->buffer_size);

  // Now connect the camera to the encoder
  status = connect_ports(camera_video_port, encoder->input[0], &encoder_connection);

  // Set up our userdata - this is passed though to the callback where we need the information.
  // Null until we open our filename
  PORT_USERDATA callback_data;
  callback_data.file_handle = NULL;
  callback_data.pool = pool;
  callback_data.offset = 0;

  vcos_assert(vcos_semaphore_create(&callback_data.complete_semaphore, "RaspiStill-sem", 0) == VCOS_SUCCESS);

  encoder->output[0]->userdata = (struct MMAL_PORT_USERDATA_T *)&callback_data;


  // Enable the encoder output port and tell it its callback function
  status = mmal_port_enable(encoder->output[0], encoder_buffer_callback);

  //// Starting video output  ////  
  {
    //Video Mode
    // Send all the buffers to the encoder output port
    int num = mmal_queue_length(pool->queue);
    int q;
    for (q=0;q<num;q++)
    {
      MMAL_BUFFER_HEADER_T *buffer = mmal_queue_get(pool->queue);
      if (!buffer)
        fprintf(stderr, "Unable to get a required buffer from pool queue");
      if (mmal_port_send_buffer(encoder->output[0], buffer)!= MMAL_SUCCESS)
        fprintf(stderr, "Unable to send a buffer to encoder output port");
    }
    if (mmal_port_parameter_set_boolean(camera_video_port, MMAL_PARAMETER_CAPTURE, 1) != MMAL_SUCCESS)
      fprintf(stderr, "starting capture failed");

    while(!pglobal->stop) usleep(1000);
  }

  vcos_semaphore_delete(&callback_data.complete_semaphore);

  //Close everything MMAL

  return NULL;
}


/******************************************************************************
  Callback from mmal JPEG encoder
 ******************************************************************************/
static void encoder_buffer_callback(MMAL_PORT_T *port, MMAL_BUFFER_HEADER_T *buffer)
{
  int complete = 0;

  // We pass our file handle and other stuff in via the userdata field.
  PORT_USERDATA *pData = (PORT_USERDATA *)port->userdata;

  if (pData)
  {
    if (buffer->length)
    {
      mmal_buffer_header_mem_lock(buffer);

      //fprintf(stderr, "The flags are %x of length %i offset %i\n", buffer->flags, buffer->length, pData->offset);

      //Write bytes
      /* copy JPG picture to global buffer */
      if(pData->offset == 0)
        pthread_mutex_lock(&pglobal->in[plugin_number].db);

      memcpy(pData->offset + pglobal->in[plugin_number].buf, buffer->data, buffer->length);
      pData->offset += buffer->length;
      //fwrite(buffer->data, 1, buffer->length, pData->file_handle);
      mmal_buffer_header_mem_unlock(buffer);
    }

    // Now flag if we have completed
    if (buffer->flags & (MMAL_BUFFER_HEADER_FLAG_FRAME_END | MMAL_BUFFER_HEADER_FLAG_TRANSMISSION_FAILED))
    {
      //set frame size
      pglobal->in[plugin_number].size = pData->offset;

      //Set frame timestamp
      if(wantTimestamp)
      {
        gettimeofday(&timestamp, NULL);
        pglobal->in[plugin_number].timestamp = timestamp;
      }

      //mark frame complete
      complete = 1;

      pData->offset = 0;
      /* signal fresh_frame */
      pthread_cond_broadcast(&pglobal->in[plugin_number].db_update);
      pthread_mutex_unlock(&pglobal->in[plugin_number].db);
    }
  }
  else
  {
    DBG("Received a encoder buffer callback with no state\n");
  }

  // release buffer back to the pool
  mmal_buffer_header_release(buffer);

  // and send one back to the port (if still open)
  if (port->is_enabled)
  {
    MMAL_STATUS_T status;
    MMAL_BUFFER_HEADER_T *new_buffer;

    new_buffer = mmal_queue_get(pData->pool->queue);

    if (new_buffer)
    {
      status = mmal_port_send_buffer(port, new_buffer);

      if(status != MMAL_SUCCESS)
      {
        DBG("Failed returning a buffer to the encoder port \n");
        print_mmal_status(status);
      }

    }
    else
    {
      DBG("Unable to return a buffer to the encoder port\n");
    }

  }

  if (complete)
    vcos_semaphore_post(&(pData->complete_semaphore));

}

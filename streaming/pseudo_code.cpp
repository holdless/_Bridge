  ////Camera variables
  MMAL_COMPONENT_T *camera = 0;
  MMAL_ES_FORMAT_T *format;
  MMAL_STATUS_T status;
  MMAL_PORT_T *camera_video_port = NULL;
  MMAL_PORT_T *preview_input_port = NULL;

  MMAL_CONNECTION_T *camera_preview_connection = 0;

  ////Encoder variables
  MMAL_COMPONENT_T *encoder = 0;
  MMAL_PORT_T *encoder_input = NULL;
  MMAL_PORT_T *encoder_output = NULL;
  MMAL_POOL_T *pool;
  MMAL_CONNECTION_T *encoder_connection;

  ////fps count
  struct timespec t_start, t_finish;
  double t_elapsed;
  int frames;
  
  
  
  ////Create camera code
  bcm_host_init();
  status = mmal_component_create(MMAL_COMPONENT_DEFAULT_CAMERA, &camera);
  
  camera_video_port = camera->output[MMAL_CAMERA_VIDEO_PORT];

  //Enable camera control port
  // Enable the camera, and tell it its control callback function
  status = mmal_port_enable(camera->control, camera_control_callback);
  
  MMAL_PARAMETER_CAMERA_CONFIG_T cam_config = {.....
  mmal_port_parameter_set(camera->control, &cam_config.hdr);
  //Set camera parameters
  raspicamcontrol_set_all_parameters(camera, &c_params)
  
  
  
  // Set the encode format on the video port
  format = camera_video_port->format;
  format->encoding_variant = MMAL_ENCODING_I420;
  format->encoding = MMAL_ENCODING_I420;
  ...
  status = mmal_port_format_commit(camera_video_port);
  
  
  
  
  /* Enable component */
  status = mmal_component_enable(camera);

  
  
  
  //Create Encoder
  status = mmal_component_create(MMAL_COMPONENT_DEFAULT_IMAGE_ENCODER, &encoder);
  encoder_input = encoder->input[0];
  encoder_output = encoder->output[0];
   
  // We want same format on input and output
  mmal_format_copy(encoder_output->format, encoder_input->format);
  
  // Specify out output format JPEG
  encoder_output->format->encoding = MMAL_ENCODING_JPEG;
  
  // Commit the port changes to the output port
  status = mmal_port_format_commit(encoder_output);

  // Set the JPEG quality level
  status = mmal_port_parameter_set_uint32(encoder_output, MMAL_PARAMETER_JPEG_Q_FACTOR, quality);


  // Enable encoder component
  status = mmal_component_enable(encoder);
  
  
  
  
  
  /* Create pool of buffer headers for the output port to consume */
  pool = mmal_port_pool_create(encoder_output, encoder_output->buffer_num, encoder_output->buffer_size);
  
  
  
  // Now connect the camera to the encoder  
  status = connect_ports(camera_video_port, encoder->input[0], &encoder_connection);
  
  
  
  //// Set up our userdata - this is passed though to the callback where we need the information.
  // Null until we open our filename
  PORT_USERDATA callback_data;
  callback_data.file_handle = NULL;
  callback_data.pool = pool;
  callback_data.offset = 0;

  vcos_assert(vcos_semaphore_create(&callback_data.complete_semaphore, "RaspiStill-sem", 0) == VCOS_SUCCESS);

  encoder->output[0]->userdata = (struct MMAL_PORT_USERDATA_T *)&callback_data;



  // Enable the encoder output port and tell it its callback function
  status = mmal_port_enable(encoder->output[0], encoder_buffer_callback);
  
  
  
  
  
    //Video Mode
    DBG("Starting video output\n");
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

#include "bcm_host.h"
#include "mmal.h"
#include "util/mmal_default_components.h"
#include "interface/vcos/vcos.h"
#include <stdio.h>

static uint8_t codec_header_bytes[512];
static unsigned int codec_header_bytes_size = sizeof(codec_header_bytes);

static FILE *source_file;

/* Macros abstracting the I/O, just to make the example code clearer */
#define SOURCE_OPEN(uri) \
   source_file = fopen(uri, "rb"); if (!source_file) goto error;
#define SOURCE_READ_CODEC_CONFIG_DATA(bytes, size) \
   size = fread(bytes, 1, size, source_file); rewind(source_file)
#define SOURCE_READ_DATA_INTO_BUFFER(a) \
   a->length = fread(a->data, 1, a->alloc_size - 128, source_file); \
   a->offset = 0; a->pts = a->dts = MMAL_TIME_UNKNOWN
#define SOURCE_CLOSE() \
   if (source_file) fclose(source_file)

/** Context for our application */
static struct CONTEXT_T {
   VCOS_SEMAPHORE_T semaphore;
   MMAL_QUEUE_T *queue;
} context;

/** Callback from the input port.
 * Buffer has been consumed and is available to be used again. */
static void input_callback(MMAL_PORT_T *port, MMAL_BUFFER_HEADER_T *buffer)
{
   struct CONTEXT_T *ctx = (struct CONTEXT_T *)port->userdata;

   /* The decoder is done with the data, just recycle the buffer header into its pool */
   mmal_buffer_header_release(buffer);

   /* Kick the processing thread */
   vcos_semaphore_post(&ctx->semaphore);
}

/** Callback from the output port.
 * Buffer has been produced by the port and is available for processing. */
static void output_callback(MMAL_PORT_T *port, MMAL_BUFFER_HEADER_T *buffer)
{
   struct CONTEXT_T *ctx = (struct CONTEXT_T *)port->userdata;

   /* Queue the decoded video frame */
   mmal_queue_put(ctx->queue, buffer);

   /* Kick the processing thread */
   vcos_semaphore_post(&ctx->semaphore);
}

int main(int argc, char **argv)
{
   MMAL_STATUS_T status = MMAL_EINVAL;
   MMAL_COMPONENT_T *decoder = 0;
   MMAL_POOL_T *pool_in = 0, *pool_out = 0;
   unsigned int count;

   bcm_host_init();

   vcos_semaphore_create(&context.semaphore, "example", 1);

   SOURCE_OPEN(argv[1]);

   /* Create the decoder component.
    * This specific component exposes 2 ports (1 input and 1 output). Like most components
    * its expects the format of its input port to be set by the client in order for it to
    * know what kind of data it will be fed. */
   status = mmal_component_create(MMAL_COMPONENT_DEFAULT_VIDEO_DECODER, &decoder);

   /* Set format of video decoder input port */
   MMAL_ES_FORMAT_T *format_in = decoder->input[0]->format;
   format_in->type = MMAL_ES_TYPE_VIDEO;
   format_in->encoding = MMAL_ENCODING_H264;
   format_in->es->video.width = 1280;
   format_in->es->video.height = 720;
   format_in->es->video.frame_rate.num = 30;
   format_in->es->video.frame_rate.den = 1;
   format_in->es->video.par.num = 1;
   format_in->es->video.par.den = 1;
   /* If the data is known to be framed then the following flag should be set:
    * format_in->flags |= MMAL_ES_FORMAT_FLAG_FRAMED; */

   SOURCE_READ_CODEC_CONFIG_DATA(codec_header_bytes, codec_header_bytes_size);
   status = mmal_format_extradata_alloc(format_in, codec_header_bytes_size);
   format_in->extradata_size = codec_header_bytes_size;
   if (format_in->extradata_size)
      memcpy(format_in->extradata, codec_header_bytes, format_in->extradata_size);

   status = mmal_port_format_commit(decoder->input[0]);

   /* The format of both ports is now set so we can get their buffer requirements and create
    * our buffer headers. We use the buffer pool API to create these. */
   decoder->input[0]->buffer_num = decoder->input[0]->buffer_num_min;
   decoder->input[0]->buffer_size = decoder->input[0]->buffer_size_min;
   decoder->output[0]->buffer_num = decoder->output[0]->buffer_num_min;
   decoder->output[0]->buffer_size = decoder->output[0]->buffer_size_min;
   pool_in = mmal_pool_create(decoder->input[0]->buffer_num,
                              decoder->input[0]->buffer_size);
   pool_out = mmal_pool_create(decoder->output[0]->buffer_num,
                               decoder->output[0]->buffer_size);

   /* Create a queue to store our decoded video frames. The callback we will get when
    * a frame has been decoded will put the frame into this queue. */
   context.queue = mmal_queue_create();

   /* Store a reference to our context in each port (will be used during callbacks) */
   decoder->input[0]->userdata = (void *)&context;
   decoder->output[0]->userdata = (void *)&context;

   /* Enable all the input port and the output port.
    * The callback specified here is the function which will be called when the buffer header
    * we sent to the component has been processed. */
   status = mmal_port_enable(decoder->input[0], input_callback);
   status = mmal_port_enable(decoder->output[0], output_callback);

   /* Component won't start processing data until it is enabled. */
   status = mmal_component_enable(decoder);

   /* Start decoding */
   /* This is the main processing loop */
   for (count = 0; count < 500; count++)
   {
      MMAL_BUFFER_HEADER_T *buffer;

      /* Wait for buffer headers to be available on either of the decoder ports */
      vcos_semaphore_wait(&context.semaphore);

      /* Send data to decode to the input port of the video decoder */
      if ((buffer = mmal_queue_get(pool_in->queue)) != NULL)
      {
         SOURCE_READ_DATA_INTO_BUFFER(buffer);
         status = mmal_port_send_buffer(decoder->input[0], buffer);
      }

      /* Get our decoded frames */
      while ((buffer = mmal_queue_get(context.queue)) != NULL)
      {
         /* We have a frame, do something with it (why not display it for instance?).
          * Once we're done with it, we release it. It will automatically go back
          * to its original pool so it can be reused for a new video frame.
          */
         mmal_buffer_header_release(buffer);
      }

      /* Send empty buffers to the output port of the decoder */
      while ((buffer = mmal_queue_get(pool_out->queue)) != NULL)
      {
         status = mmal_port_send_buffer(decoder->output[0], buffer);
      }
   }

   /* Stop decoding */
   /* Stop everything. Not strictly necessary since mmal_component_destroy()
    * will do that anyway */
   mmal_port_disable(decoder->input[0]);
   mmal_port_disable(decoder->output[0]);
   mmal_component_disable(decoder);

   vcos_semaphore_delete(&context.semaphore);
}

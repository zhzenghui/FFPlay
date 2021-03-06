//
//  FFPlayer.m
//  FFPlay
//
//  Created by xy on 16/4/12.
//  Copyright © 2016年 yuenvshen. All rights reserved.
//

#import "FFPlayer.h"

@interface FFPlayer (private)


-(void)convertFrameToRGB;
-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height;
-(void)savePicture:(AVPicture)pFrame width:(int)width height:(int)height index:(int)iFrame;
-(void)setupScaler;
@end


@interface FFPlayer ()
@end



@implementation FFPlayer


- (void)setupScaler
{
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, _outputWidth, _outputHeight);
    
    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     _outputWidth,
                                     _outputHeight,
                                     PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
    
}

- (void)setOutputWidth:(int)newValue
{
    if (_outputWidth != newValue) {
        _outputWidth = newValue;
        [self setupScaler];
    }
}

- (void)setOutputHeight:(int)newValue
{
    if (_outputHeight != newValue) {
        _outputHeight = newValue;
        [self setupScaler];
    }
}


- (id)initWithVideo:(NSString *)moviePath usesTcp:(BOOL)usesTcp {
    
    if (!(self=[super init])) return nil;

    AVCodec     *pCodec;   //编解码器
    avcodec_register_all();//Register all the codecs, parsers and bitstream filters which were enabled at
    av_register_all();     //nitialize libavformat and register all the muxers, demuxers and * protocols.
    avformat_network_init(); // 网络相关
    
//    视频参数集合
    AVDictionary *opts = 0;
    
    if (usesTcp) {
//        字面意思是使用rtsp  tcp协议，
        av_dict_set(&opts, "rtsp_transport", "tcp", 0);
    }
    
//    打开网络连接  Open an input stream and read the header.
    if (avformat_open_input(&pFormatCtx, [moviePath UTF8String], NULL, &opts) != 0) {
        
        av_log(NULL, AV_LOG_ERROR, "couldn''t open file \n");
        goto initError;
    }
    
//  Read packets of a media file to get stream information.
//    
    if (avformat_find_stream_info(pFormatCtx, NULL) <  0) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information \n");
        goto initError;
    }
    
    videoStream = -1;
    
    for (int  i =0; i<pFormatCtx->nb_streams; i++) {
        
        if (pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO ) {
            NSLog(@"found video stream");
            videoStream =i;
        }
    }
    
    
    if (videoStream == -1) {
        goto initError;
    }
    
//    获取解码后的内容
    pCodecCtx = pFormatCtx->streams[videoStream]->codec;
    
    
//     解码后获取视频流
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id)  ;
    
    if (pCodec == NULL) {
        av_log(NULL, AV_LOG_ERROR, "unsupported codec! \n");
        goto initError;
    }
    
    if (avcodec_open2(pCodecCtx, pCodec, NULL) <  0) {
        av_log(NULL, AV_LOG_ERROR, "cannot open video decoder");
        
        goto initError;
    }

    pFrame = avcodec_alloc_frame();
    
    _outputWidth = pCodecCtx->width;
    _outputHeight = pCodecCtx->height;
    
    
    return self;
    
    
initError:
    return nil;
}



- (double)duration
{
    return (double)pFormatCtx->duration / AV_TIME_BASE;
}

- (double)currentTime
{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    return packet.pts * (double)timeBase.num / timeBase.den;
}


- (int)sourceWidth
{
    return pCodecCtx->width;
}

- (int)sourceHeight
{
    return pCodecCtx->height;
}



- (BOOL)stepFrame
{
    // AVPacket packet;
    int frameFinished=0;
    
    while (!frameFinished && av_read_frame(pFormatCtx, &packet) >=0 ) {
        // Is this a packet from the video stream?

//        NSLog(@"stepFrame :%i ",   packet.stream_index);
        if(packet.stream_index==videoStream) {
            // Decode video frame
            avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
        }
        
    }
    
    return frameFinished!=0;
}


- (void)seekTime:(double)seconds
{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(pFormatCtx, videoStream, targetFrame, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(pCodecCtx);
}



- (UIImage *)currentImage
{
    if (!pFrame->data[0]) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:_outputWidth height:_outputHeight];
}

- (void)convertFrameToRGB
{
    sws_scale(img_convert_ctx,
              pFrame->data,
              pFrame->linesize,
              0,
              pCodecCtx->height,
              picture.data,
              picture.linesize);
}





- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height
{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);

    
    
    return image;
}


@end
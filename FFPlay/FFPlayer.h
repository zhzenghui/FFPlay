//
//  FFPlayer.h
//  FFPlay
//
//  Created by xy on 16/4/12.
//  Copyright © 2016年 yuenvshen. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// libavf I/O and Muxing/Demuxing Library
//
//  mux demux 的名称解释 http://blog.csdn.net/haomcu/article/details/7072707
#import "avformat.h"
////
////
//// libavc Encoding/Decoding Library
#import "avcodec.h"  //编码解码库
//
//// I/O operations
#import "avio.h"
//
////
//// libsws Color conversion and scaling
//// 图像格式转换以及图像缩放
#import "swscale.h"

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioToolbox.h>



@interface FFPlayer : NSObject {
    
    /**
     * Format I/O context.
     * New fields can be added to the end with minor version bumps.
     * Removal, reordering and changes to existing fields require a major
     * version bump.
     * sizeof(AVFormatContext) must not be used outside libav*, use
     * avformat_alloc_context() to create an AVFormatContext.
     *
     */
    AVFormatContext *pFormatCtx;

    /**
     * main external API structure.
     * New fields can be added to the end with minor version bumps.
     * Removal, reordering and changes to existing fields require a major
     * version bump.
     * Please use AVOptions (av_opt* / av_set/get*()) to access these fields from user
     * applications.
     * sizeof(AVCodecContext) must not be used outside libav*.
     */
    AVCodecContext *pCodecCtx;
    
    
//    This structure describes decoded (raw) audio or video data.
//
//
    AVPacket packet;
    AVFrame *pFrame;
    AVPacket *_packet, _currentPacket;
    AVPicture picture;
    AVCodecContext *_audioCodecContext;

    
    
    struct SwsContext *img_convert_ctx;

    int16_t *_audioBuffer;
    
    
//    UIImage *currentImage;
//    NSMutableArray *audioPacketQueue;
    
    NSLock *audioPacketQueueLock;
    
    int audiopacktQueueSize;
    int videoStream;
    int audioStream;
    
//    int sourceWidth, sourceHeight;
//    int outputWidth, outputHeight;
    
    double duration;
    double currentTime;
    
    BOOL primed;
    BOOL _inBuffer;

}


@property (nonatomic, readonly) UIImage *currentImage;


@property (nonatomic, readonly) int sourceWidth, sourceHeight;
@property (nonatomic)           int outputWidth, outputHeight;

@property (nonatomic, readonly) double duration;
@property (nonatomic, readonly) double currentTime;



@property (nonatomic, strong)   NSMutableArray *audioPacketQueue;

@property (nonatomic, assign)  AVCodecContext *audioCodecContext;



@property (nonatomic, assign) AudioQueueBufferRef emptyAudioBuffer;
//@property (nonatomic, assign) AVStream *_audioStream;
@property (nonatomic, assign) int audioPacketQueueSize;


/* Initialize with movie at moviePath. Output dimensions are set to source dimensions. */
-(id)initWithVideo:(NSString *)moviePath usesTcp:(BOOL)usesTcp;

/* Read the next frame from the video stream. Returns false if no frame read (video over). */
-(BOOL)stepFrame;

/* Seek to closest keyframe near specified time */
-(void)seekTime:(double)seconds;


- (AVPacket*)readPacket;



@end

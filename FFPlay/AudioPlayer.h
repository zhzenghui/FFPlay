//
//  AudioPlayer.h
//  FFPlay
//
//  Created by xy on 16/4/18.
//  Copyright © 2016年 yuenvshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FFPlayer.h"


#define kNumAQBufs 3
#define kAudioBufferSeconds 3

typedef enum _AUDIO_STATE {
    AUDIO_STATE_READY           = 0,
    AUDIO_STATE_STOP            = 1,
    AUDIO_STATE_PLAYING         = 2,
    AUDIO_STATE_PAUSE           = 3,
    AUDIO_STATE_SEEKING         = 4
} AUDIO_STATE;

@interface AudioPlayer : NSObject {
    
//    This structure encapsulates all the information for describing the basic
//    format properties of a stream of audio data.
    AudioStreamBasicDescription audioStreamBasicDesc_;

//    Defines an opaque data type that represents an audio queue.
    AudioQueueRef audioQueue_;
//    An pointer to an AudioQueueBuffer.
    AudioQueueBufferRef audioQueueBuffer_[kNumAQBufs];

    AVCodecContext *_audioCodecContext;

    
    NSTimeInterval durationTime_, startedTime_;
    NSInteger state_;

    
    
    BOOL started_, finished_;

    
    NSString *playingFilePath_;
    NSTimer *seekTimer_;
    NSLock *decodeLock_;
    
}


- (void)_startAudio;
- (void)_stopAudio;
- (BOOL)createAudioQueue;
- (void)removeAudioQueue;
- (void)audioQueueOutputCallback:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer;
- (void)audioQueueIsRunningCallback;
- (OSStatus)enqueueBuffer:(AudioQueueBufferRef)buffer;
- (id)initWithStreamer:(FFPlayer *)streamer;

- (OSStatus)startQueue;

@end

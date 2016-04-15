//
//  ViewController.m
//  FFPlay
//
//  Created by xy on 16/4/12.
//  Copyright © 2016年 yuenvshen. All rights reserved.
//

#import "ViewController.h"
#import "FFPlayer.h"

@interface ViewController ()
@property (nonatomic, retain) NSTimer *nextFrameTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _video = [[FFPlayer alloc] initWithVideo:@"http://krtv.qiniudn.com/150522nextapp" usesTcp:NO];
    _video.outputWidth = 426;
    _video.outputHeight = 320;

    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:imageView];
    imageView.backgroundColor = [UIColor grayColor];
    
    self.imageView = imageView;
    [imageView setContentMode:UIViewContentModeScaleAspectFit];

    

}


- (void)viewDidAppear:(BOOL)animated {
    
    [self playButtonAction:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)playButtonAction:(id)sender {
//    [playButton setEnabled:NO];
    lastFrameTime = -1;
    
    // seek to 0.0 seconds
//    [_video seekTime:0.0];
    
    [_nextFrameTimer invalidate];
    self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (IBAction)showTime:(id)sender
{
    NSLog(@"current time: %f s", _video.currentTime);
}



#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)

-(void)displayNextFrame:(NSTimer *)timer
{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    if (![_video stepFrame]) {
        [timer invalidate];
//        [playButton setEnabled:YES];
//        [video closeAudio];
        return;
    }
    _imageView.image = _video.currentImage;
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (lastFrameTime<0) {
        lastFrameTime = frameTime;
    } else {
        lastFrameTime = LERP(frameTime, lastFrameTime, 0.8);
    }
//    [label setText:[NSString stringWithFormat:@"%.0f",lastFrameTime]];
    
    NSLog(@"%.0f", lastFrameTime);
}


@end

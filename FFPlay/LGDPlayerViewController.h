//
//  ViewController.h
//  FFPlay
//
//  Created by xy on 16/4/12.
//  Copyright © 2016年 yuenvshen. All rights reserved.
//

#import <UIKit/UIKit.h>



@class FFPlayer;

@interface ViewController : UIViewController {
    float lastFrameTime;

}



@property (nonatomic, retain) FFPlayer *video;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end


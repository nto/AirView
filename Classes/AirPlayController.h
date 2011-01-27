//
//  AirPlayController.h
//  AirView
//
//  Created by Clément Vasseur on 12/16/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import <UiKit/UIWindow.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import "AirPlayHTTPServer.h"

@interface AirPlayController : NSObject {
	AirPlayHTTPServer *httpServer;
    MPMoviePlayerViewController *playerView;
    MPMoviePlayerController *player;
    UIWindow *window;
    float start_position;
}

- (id)initWithWindow:(UIView *)uiWindow;
- (void)startServer;
- (void)stopServer;
- (void)stopPlayer;
- (void)play:(NSURL *)location atRelativePosition:(float)position;
- (void)stop;
- (void)setPosition:(float)position;
- (float)position;
- (void)setRate:(float)value;
- (NSTimeInterval)duration;
- (void)dealloc;

@end

//
//  AirPlayController.m
//  AirView
//
//  Created by Clément Vasseur on 12/16/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import "AirPlayController.h"
#import "AirPlayHTTPConnection.h"
#import "DeviceInfo.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation AirPlayController

- (id)initWithWindow:(UIWindow *)uiWindow
{
    if ((self = [super init])) {
        window = uiWindow;

		DDLogVerbose(@"AirPlayController: init");

		// Create server using our custom AirPlayHTTPServer class
		httpServer = [[AirPlayHTTPServer alloc] init];
		httpServer.airplay = self;

		// Tell the server to broadcast its presence via Bonjour.
		[httpServer setType:@"_airplay._tcp."];
		[httpServer setTXTRecordDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
			@"0x7", @"features",
			[DeviceInfo platform], @"model",
			[DeviceInfo deviceId], @"deviceid",
			nil]];

		// We're going to extend the base HTTPConnection class with our AirPlayHTTPConnection class.
		[httpServer setConnectionClass:[AirPlayHTTPConnection class]];

		// Set a dummy document root
		[httpServer setDocumentRoot:@"/dummy"];

//		[httpServer setPort:7000];

		playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:nil];
		player = playerView.moviePlayer;
	}

    return self;
}

- (void)startServer
{
	NSError *error;

	DDLogVerbose(@"AirPlayController: startServer");

	// Start the server (and check for problems)
	if(![httpServer start:&error])
		DDLogError(@"Error starting HTTP Server: %@", error);
}

- (void)stopServer
{
	DDLogVerbose(@"AirPlayController: stopServer");

	[httpServer stop];
}

- (void)play:(NSURL *)location atPosition:(NSTimeInterval)position
{
	DDLogVerbose(@"AirPlayController: play %@", location);

	dispatch_async(dispatch_get_main_queue(), ^{
		if (playerView == nil) {
			playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:location];
			player = playerView.moviePlayer;
		} else {
			[player setContentURL:location];
		}
//		if (position > 0) {
//			DDLogVerbose(@"AirPlayController: set initial playback time to %f", position);
//			player.initialPlaybackTime = position;
//		}
		[window addSubview:playerView.view];
		player.fullscreen = YES;

		[[NSNotificationCenter defaultCenter] addObserver:self
							 selector:@selector(movieFinishedCallback:)
							     name:MPMoviePlayerPlaybackDidFinishNotification
							   object:player];

		[player play];
	});
}

- (void)movieFinishedCallback:(NSNotification *)notification
{
	DDLogVerbose(@"AirPlayController: movie finished");

	[[NSNotificationCenter defaultCenter] removeObserver:self
							name:MPMoviePlayerPlaybackDidFinishNotification
						      object:[notification object]];

	[self stopPlayer];
}

- (void)stopPlayer
{
	DDLogVerbose(@"AirPlayController: stop player");

	[playerView.view removeFromSuperview];
	[player stop];
	player.initialPlaybackTime = 0;
}

- (void)stop
{
	DDLogVerbose(@"AirPlayController: stop");

	dispatch_sync(dispatch_get_main_queue(), ^{
		[self stopPlayer];
	});
}

- (void)setPosition:(float)position
{
    DDLogVerbose(@"AirPlayController: set position %f", position);

	dispatch_async(dispatch_get_main_queue(), ^{
		if (player.playbackState ==  MPMoviePlaybackStateStopped)
			player.initialPlaybackTime = position;
		else
			player.currentPlaybackTime = position;
	});
}

- (float)position
{
	__block float position;

	if (player == nil)
		return 0;

	dispatch_sync(dispatch_get_main_queue(), ^{
		position = player.currentPlaybackTime;
	});

	return position;
}

- (NSTimeInterval)duration
{
	__block NSTimeInterval duration;

	if (player == nil)
		return 0;

	dispatch_sync(dispatch_get_main_queue(), ^{
		duration = player.duration;
	});

	return duration;
}

- (void)setRate:(float)value
{
    DDLogVerbose(@"AirPlayController: rate %f", value);

	dispatch_async(dispatch_get_main_queue(), ^{
		player.currentPlaybackRate = value;
	});
}

- (void)dealloc
{
	DDLogVerbose(@"AirPlayController: release");

	[playerView release];
	[httpServer release];
	[super dealloc];
}

@end

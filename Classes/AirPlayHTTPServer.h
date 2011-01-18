//
//  AirPlayHTTPServer.h
//  AirView
//
//  Created by Clément Vasseur on 12/16/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import "HTTPServer.h"
#import "HTTPConnection.h"

@class AirPlayController;

@interface AirPlayHTTPServer : HTTPServer {
    AirPlayController *airplay;
}

@property (nonatomic, assign) AirPlayController *airplay;

- (HTTPConfig *)config;

@end

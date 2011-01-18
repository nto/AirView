//
//  AirPlayHTTPServer.m
//  AirView
//
//  Created by Clément Vasseur on 12/16/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import "AirPlayHTTPServer.h"
#import "AirPlayHTTPConnection.h"

@implementation AirPlayHTTPServer

@synthesize airplay;

- (HTTPConfig *)config
{
	return [[[AirPlayHTTPConfig alloc] initWithServer:self documentRoot:documentRoot queue:connectionQueue airplay:airplay] autorelease];
}

@end

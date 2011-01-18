//
//  AirPlayHTTPConnection.h
//  AirView
//
//  Created by Clément Vasseur on 12/15/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import "HTTPConnection.h"
#import "AirPlayController.h"

@interface AirPlayHTTPConfig : HTTPConfig {
    AirPlayController *airplay;
}

- (id)initWithServer:(HTTPServer *)server documentRoot:(NSString *)documentRoot queue:(dispatch_queue_t)q airplay:(AirPlayController *)airplay;

@property (nonatomic, readonly) AirPlayController *airplay;

@end

@interface AirPlayHTTPConnection : HTTPConnection {
}

- (AirPlayController *)airplay;

@end

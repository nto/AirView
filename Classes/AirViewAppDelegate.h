//
//  AirViewAppDelegate.h
//  AirView
//
//  Created by Clément Vasseur on 12/18/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirPlayController.h"

@interface AirViewAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	AirPlayController *airplay;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

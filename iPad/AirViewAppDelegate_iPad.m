//
//  AirViewAppDelegate_iPad.m
//  AirView
//
//  Created by Clément Vasseur on 12/18/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import "AirViewAppDelegate_iPad.h"

@implementation AirViewAppDelegate_iPad


#pragma mark -
#pragma mark Application lifecycle

/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[super dealloc];
}


@end

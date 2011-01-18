//
//  AirPlayHTTPConnection.m
//  AirView
//
//  Created by Clément Vasseur on 12/15/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import <Foundation/NSCharacterSet.h>
#import "AirPlayHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPReverseResponse.h"
#import "HTTPLogging.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;

@implementation AirPlayHTTPConfig

@synthesize airplay;

- (id)initWithServer:(HTTPServer *)aServer
	documentRoot:(NSString *)aDocumentRoot
	       queue:(dispatch_queue_t)q
	     airplay:(AirPlayController *)airplayController
{
	if ((self = [super init]))
	{
		server = [aServer retain];

		documentRoot = [aDocumentRoot stringByStandardizingPath];
		if ([documentRoot hasSuffix:@"/"])
		{
			documentRoot = [documentRoot stringByAppendingString:@"/"];
		}
		[documentRoot retain];

		if (q)
		{
			dispatch_retain(q);
			queue = q;
		}

		airplay = [airplayController retain];
	}
	return self;
}
@end

@implementation AirPlayHTTPConnection

- (AirPlayController *)airplay
{
	AirPlayHTTPConfig *cfg = [config isKindOfClass:[AirPlayHTTPConfig class]] ? (id)config : nil;
	return cfg.airplay;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();

	// Add support for GET

	if ([method isEqualToString:@"GET"])
	{
		if ([path isEqualToString:@"/scrub"])
			return YES;
	}

	// Add support for POST

	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/reverse"] ||
		    [path isEqualToString:@"/play"] ||
		    [path isEqualToString:@"/stop"] ||
			  [path hasPrefix:@"/scrub?position="] ||
			  [path hasPrefix:@"/rate?value="])
			return YES;
	}

	// Add support for PUT

	if ([method isEqualToString:@"PUT"])
	{
		if ([path isEqualToString:@"/photo"])
			return YES;
	}

	return [super supportsMethod:method atPath:path];
}

/**
 * This method is called after receiving all HTTP headers, but before reading any of the request body.
 **/
- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();

	HTTPLogVerbose(@"prepareForBodyWithSize %qu", contentLength);
}


- (void)processDataChunk:(NSData *)postDataChunk
{
	HTTPLogTrace();

	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.

	BOOL result = [request appendData:postDataChunk];
	if (!result)
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	HTTPLogVerbose(@"%@[%p]: %@ (%qu) %@", THIS_FILE, self, method, requestContentLength, path);

	AirPlayController *airplay = [self airplay];

	if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/scrub"])
	{
		NSString *str = [NSString stringWithFormat:@"duration: %f\nposition: %f\n",
						 airplay.duration, airplay.position];
		NSData *response = [str dataUsingEncoding:NSUTF8StringEncoding];
		HTTPDataResponse *res = [[HTTPDataResponse alloc] initWithData:response];
		[res setHttpHeaderValue:@"text/parameters" forKey:@"Content-Type"];
		return [res autorelease];
	}

	if ([method isEqualToString:@"PUT"] && [path isEqualToString:@"/photo"])
	{
		HTTPLogVerbose(@"%@[%p]: PUT (%qu) %@", THIS_FILE, self, requestContentLength, path);

		return [[[HTTPDataResponse alloc] initWithData:nil] autorelease];
	}


	if (![method isEqualToString:@"POST"])
		return [super httpResponseForMethod:method URI:path];

	if ([path isEqualToString:@"/reverse"])
	{
		return [[[HTTPReverseResponse alloc] init] autorelease];
	}
	else if ([path hasPrefix:@"/scrub?position="])
	{
		NSString *str = [path substringFromIndex:16];
		float value = [str floatValue];
		[airplay setPosition:value];

		return [[[HTTPDataResponse alloc] initWithData:nil] autorelease];
	}
	else if ([path hasPrefix:@"/rate?value="])
	{
		NSString *str = [path substringFromIndex:12];
		float value = [str floatValue];
		[airplay setRate:value];

		return [[[HTTPDataResponse alloc] initWithData:nil] autorelease];
	}
	else if ([path isEqualToString:@"/stop"])
	{
		[airplay stop];

		return [[[HTTPDataResponse alloc] initWithData:nil] autorelease];
	}
	else if ([path isEqualToString:@"/play"])
	{
		NSString *postStr = nil;
		NSData *postData = [request body];
		NSArray *headers;
		NSURL *url = nil;
		NSTimeInterval start_position = 0;

		if (postData)
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];

		headers = [postStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

		for (id h in headers) {
			NSArray *a = [h componentsSeparatedByString:@": "];

			if ([a count] >= 2) {
				NSString *key = [a objectAtIndex:0];
				NSString *value = [a objectAtIndex:1];

				if ([key isEqualToString:@"Content-Location"])
					url = [NSURL URLWithString:value];
				else if ([key isEqualToString:@"Start-Position"])
					start_position = [value doubleValue];
			}
		}

		if (url)
			[airplay play:url atPosition:start_position];

		return [[[HTTPDataResponse alloc] initWithData:nil] autorelease];
	}

	return [super httpResponseForMethod:method URI:path];
}

@end

#import "HTTPReverseResponse.h"
#import "HTTPLogging.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_OFF; // | HTTP_LOG_FLAG_TRACE;


@implementation HTTPReverseResponse

- (UInt64)contentLength
{
	return 0;
}

- (UInt64)offset
{
	return 0;
}

- (void)setOffset:(UInt64)offset
{
	// Nothing to do
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
	HTTPLogTrace();
	
	return nil;
}

- (BOOL)isDone
{
	return YES;
}

- (NSDictionary *)httpHeaders
{
	HTTPLogTrace();
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"PTTH/1.0", @"Upgrade",
			@"Upgrade", @"Connection",
			nil];
}

- (NSInteger)status
{
	HTTPLogTrace();
	
	return 101;
}

@end

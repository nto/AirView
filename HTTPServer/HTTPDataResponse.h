#import <Foundation/Foundation.h>
#import "HTTPResponse.h"


@interface HTTPDataResponse : NSObject <HTTPResponse>
{
	NSUInteger offset;
	NSData *data;
	NSMutableDictionary *httpHeadersDict;
}

- (id)initWithData:(NSData *)data;
- (NSDictionary *)httpHeaders;
- (void)setHttpHeaderValue:(NSString *)value forKey:(NSString *)key;
- (void)dealloc;

@end

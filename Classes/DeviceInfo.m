//
//  DeviceInfo.m
//  AirView
//
//  Created by Clément Vasseur on 12/22/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import "DeviceInfo.h"
#import "DDLog.h"

#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>

#include <net/if.h>
#include <net/if_dl.h>

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#if !defined(IFT_ETHER)
# define IFT_ETHER 0x6 /* Ethernet CSMACD */
#endif

@implementation DeviceInfo

+ (NSString *)getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
	sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
	char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
	free(answer);
	return results;
}

+ (NSString *)platform
{
	return [self getSysInfoByName:"hw.machine"];
}

+ (NSString *)deviceId
{
	NSMutableString *res;
	struct ifaddrs *addrs;
	const struct ifaddrs *cursor;
	const struct sockaddr_dl *dlAddr;
	const uint8_t *base;
	int i;

	if (getifaddrs(&addrs) != 0) {
		DDLogError(@"getifaddrs failed");
		return nil;
	}

	res = nil;
	cursor = addrs;
	while (cursor != NULL) {
		if ((cursor->ifa_addr->sa_family == AF_LINK) &&
			(((const struct sockaddr_dl *) cursor->ifa_addr)->sdl_type == IFT_ETHER)) {
			dlAddr = (const struct sockaddr_dl *) cursor->ifa_addr;
			base = (const uint8_t *) &dlAddr->sdl_data[dlAddr->sdl_nlen];
			res = [NSMutableString stringWithCapacity:32];
			for (i = 0; i < dlAddr->sdl_alen; i++) {
				if (i != 0)
					[res appendString:@":"];
				[res appendFormat:@"%02X", base[i]];
			}
			goto out;
		}
		cursor = cursor->ifa_next;
	}

out:
	freeifaddrs(addrs);
	return res;
}

@end

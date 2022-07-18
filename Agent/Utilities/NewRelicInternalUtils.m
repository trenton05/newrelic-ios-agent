//
//  NewRelicInternalUtils.m
//  NewRelicAgent
//
//  Created by Jonathan Karon on 9/21/12.
//
//
#import "NRMAAgentVersion.h"
#import "NewRelicInternalUtils.h"
#import "NRMAReachability.h"
#import "NRLogger.h"
#import "NRConstants.h"
#import "NRTimer.h"

#if !TARGET_OS_TV

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#endif

#import "NRConstants.h"
#import "NRMAUDIDManager.h"
#import <sys/sysctl.h>

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import <mach/mach.h>

#define NRMA_CARRIER_OTHER        @"unknown"
#define NRMA_CARRIER_WIFI         @"wifi"

#ifdef NRMA_REACHABILITY_DEBUG
#import "NRMADEBUG_Reachability.h"
#endif

// This gets autogenerated into a _vers file using the "Current Project Version" from the project file.

NSTimeInterval NRMAMillisecondTimestamp() {
    return (NSTimeInterval)(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000;
}

@implementation NewRelicInternalUtils
static NSString* _agentVersion;
static NSString* _deviceId;
static NSString* _osVersion;

+ (BOOL) isFloat:(NSNumber*)number {
    if (!number) return NO;

   switch([number objCType][0]) {
       case 'f': case 'd':
           return YES;
       default:
           return NO;
   }
}

+ (BOOL) isInteger:(NSNumber*)number {
    if (!number) return NO;
    switch ([number objCType][0]) {
        case 'i':
        case 's':
        case 'l':
        case 'q':
        case 'I':
        case 'S':
        case 'L':
        case 'Q': // integer types; casing all unsigned to signed
            return YES;
        default:
            return NO;
    }
    return NO;
}

+ (BOOL) isBool:(NSNumber*)number{
    if (!number) return NO;
    switch ([number objCType][0]) {
        case 'c':
        case 'B':
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

+ (NSString*) agentVersion {
    if (!_agentVersion) {
        // NewRelicAgentVersionString is a \n-terminated const unsigned char[], the last part of which is a "-" and the build version
        size_t vStrLen = strlen(__NRMA_NewRelic_iOS_Agent_Version);
        NSString* vers = [[NSString alloc] initWithBytes:__NRMA_NewRelic_iOS_Agent_Version
                                                  length:vStrLen
                                                encoding:NSUTF8StringEncoding];
        if ([vers isKindOfClass:[NSString class]] && vers.length > 0) {
            _agentVersion = vers;
        } else {
            _agentVersion = @"0";
        }
    }
    return _agentVersion;
}

+ (NSString*) deviceId {
    if (!_deviceId) {
        _deviceId = [NRMAUDIDManager UDID];
    }
    return _deviceId;
}

+ (NSString*) osVersion {
    if (!_osVersion) {
        _osVersion = [[UIDevice currentDevice] systemVersion];
    }
    return _osVersion;
}

+ (NSString*) osName {
    //we do this to retain the "iOS" value. +systemName returns "iphone OS" for iOS now.
    if ([[[UIDevice currentDevice] systemName] isEqualToString:NRMA_OSNAME_TVOS]) {
        return NRMA_OSNAME_TVOS;
    }
    else if([[[UIDevice currentDevice] systemName] isEqualToString:NRMA_OSNAME_WATCHOS]) {
        return NRMA_OSNAME_WATCHOS;
    }
    
    return NRMA_OSNAME_IOS;
}

+ (NSString*) agentName {
    if ([[[UIDevice currentDevice] systemName] isEqualToString:NRMA_OSNAME_TVOS]) {
        return @"tvOSAgent";
    }
    return @"iOSAgent";
}

/*
 Returns true if the current thread is a known web view thread, namely 'WebCore: ...' or 'WebThread'.
 */
+ (BOOL) isWebViewThread {
    NSString* threadName = [[NSThread currentThread] name];

    if (threadName == nil || threadName.length == 0) {
        return NO;
    }

    if ([threadName rangeOfString:@"WebCore"].location == 0 || [threadName rangeOfString:@"WebThread"].location == 0) {
        return YES;
    }

    return NO;
}

+ (NSString*) stringFromNRMAApplicationPlatform:(NRMAApplicationPlatform)applicationPlatform {
    switch (applicationPlatform) {
        case NRMAPlatform_Native:
            return kNRMAPlatformString_Native;
        case NRMAPlatform_Cordova:
            return kNRMAPlatformString_Cordova;
        case NRMAPlatform_PhoneGap:
            return kNRMAPlatformString_PhoneGap;
        case NRMAPlatform_Xamarin:
            return kNRMAPlatformString_Xamarin;
        case NRMAPlatform_Unity:
            return kNRMAPlatformString_Unity;
        case NRMAPlatform_Appcelerator:
            return kNRMAPlatformString_Appcelerator;
        case NRMAPlatform_ReactNative:
            return kNRMAPlatformString_ReactNative;
        case NRMAPlatform_Flutter:
            return kNRMAPlatformString_Flutter;
    }
}

/*
 Returns the carrier name, or 'wifi' if the device is on a wifi network.
 */
+ (NSString*) carrierName {
#if TARGET_OS_TV
    return @"wifi";
#else
#ifdef NRMA_REACHABILITY_DEBUG
    static NRMADEBUG_Reachability* debugLog;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        debugLog = [NRMADEBUG_Reachability new];
    });
    [debugLog syncIncTotal];
    NRTimer* timer = [NRTimer new];
#endif

    static NSString* cachedCarrierName;
    static NSTimeInterval lastCachedAt_millis;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^() {
        cachedCarrierName = nil;
        lastCachedAt_millis = 0;
    });

    // this will block N callers for as long as it takes to resolve the carrier name on the first caller,
    // after that all callers will succeed fast for kNRMACarrierNameCacheLifetime milliseconds, with only the
    // overhead of the locking code.

    //double check for the same thing before and after synchronization
    //we might encounter unnecessary sync blockage here if we do the check beforehand
    //and we will prevent multiple checks
    if (cachedCarrierName == nil || (NRMAMillisecondTimestamp() - lastCachedAt_millis) > kNRCarrierNameCacheLifetime) {
        NRMAReachability* r = [self reachability];
        @synchronized(r) {
            if (cachedCarrierName == nil || (NRMAMillisecondTimestamp() - lastCachedAt_millis) > kNRCarrierNameCacheLifetime) {
                NRMANetworkStatus internetStatus = [self networkStatus];

                if (internetStatus == ReachableViaWWAN) {

                    CTCarrier* carrier = [r getCarrierInfo];

                    NRLOG_VERBOSE(@"Carrier Name: %@", carrier.carrierName);

                    // set a default carrier if the value returned is nil, blank, or 'carrier'.
                    if (carrier.carrierName == nil ||
                            carrier.carrierName.length == 0 ||
                            [carrier.carrierName caseInsensitiveCompare:@"carrier"] == NSOrderedSame) {
                        cachedCarrierName = NRMA_CARRIER_OTHER;
                    } else {
                        cachedCarrierName = carrier.carrierName;
                    }
                } else {
                    cachedCarrierName = NRMA_CARRIER_WIFI;
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:kNRCarrierNameDidUpdateNotification
                                                                    object:cachedCarrierName];

                lastCachedAt_millis = NRMAMillisecondTimestamp();
#ifdef NRMA_REACHABILITY_DEBUG
                [debugLog syncIncReachabilityHit];
                [timer stopTimer];
                [debugLog addReachabilityWait:timer.timeElapsedInMilliSeconds];
#endif
            }
#ifdef NRMA_REACHABILITY_DEBUG
            else {
                [debugLog syncIncCacheHit];
                [debugLog syncIncWaited];
                [timer stopTimer];
                [debugLog addWaitingCacheHitWait:timer.timeElapsedInMilliSeconds];
            }
#endif
        }
    }
#ifdef NRMA_REACHABILITY_DEBUG
    else {
        [debugLog syncIncNoWait];
        [debugLog syncIncCacheHit];
        [timer stopTimer];
        [debugLog addNoWaitingCacheHitWait:timer.timeElapsedInMilliSeconds];
    }
#endif

#ifdef NRMA_REACHABILITY_DEBUG
    if (debugLog.total % 1000 == 0){
        NRLOG_INFO(@"DEBUG UPDATE: %@",debugLog);
    }
#endif
    return cachedCarrierName;
#endif
}

+ (NSString*) deviceOrientation {


#if !TARGET_OS_TV
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            return @"Landscape";
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            return @"Portrait";
            break;
        case UIDeviceOrientationFaceDown:
            return @"Face-Down";
            break;
        case UIDeviceOrientationFaceUp:
            return @"Face-Up";
            break;
        default:
            return @"Unknown";
            break;
    }
#else
    return @"Landscape";
#endif
}

+ (NRMANetworkStatus) networkStatus {
#ifdef NRMA_REACHABILITY_DEBUG
    static NRMADEBUG_Reachability* debugLog;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        debugLog = [NRMADEBUG_Reachability new];
    });
    [debugLog syncIncTotal];
    NRTimer* timer = [NRTimer new];
#endif

    static NRMANetworkStatus status;
    static NSTimeInterval lastCachedAt_millis;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^() {
        status = NotReachable;
        lastCachedAt_millis = 0;
    });
    //double check for the same thing before and after synchronization
    //we might encounter unnecessary sync blockage here if we do the check beforehand
    //and we will prevent multiple checks

    if (lastCachedAt_millis == 0 || (NRMAMillisecondTimestamp() - lastCachedAt_millis) > kNRNetworkStatusCacheLifetime) {
        NRMAReachability* r = [self reachability];
        @synchronized(r) {
            if (lastCachedAt_millis == 0 || (NRMAMillisecondTimestamp() - lastCachedAt_millis) > kNRNetworkStatusCacheLifetime) {
                status = [r currentReachabilityStatus];
                lastCachedAt_millis = NRMAMillisecondTimestamp();
#ifdef NRMA_REACHABILITY_DEBUG
                [debugLog syncIncReachabilityHit];
                        [timer stopTimer];
                        [debugLog addReachabilityWait:timer.timeElapsedInMilliSeconds];
#endif
            }
#ifdef NRMA_REACHABILITY_DEBUG
            else {
                [debugLog syncIncCacheHit];
                [debugLog syncIncWaited];
                [timer stopTimer];
                [debugLog addWaitingCacheHitWait:timer.timeElapsedInMilliSeconds];
            }
#endif
        }
    }
#ifdef NRMA_REACHABILITY_DEBUG
    else {
        [debugLog syncIncNoWait];
        [debugLog syncIncCacheHit];
        [timer stopTimer];
        [debugLog addNoWaitingCacheHitWait:timer.timeElapsedInMilliSeconds];
    }
#endif
#ifdef NRMA_REACHABILITY_DEBUG
    if (debugLog.total % 1000 == 0){
    NRLOG_INFO(@"DEBUG UPDATE: %@",debugLog);
    }
#endif
    return status;
}


+ (NSString*) getCurrentWanType {
#ifdef NRMA_REACHABILITY_DEBUG
    static NRMADEBUG_Reachability* debugLog;
    static dispatch_once_t reachOnceToken;
    dispatch_once(&reachOnceToken, ^{
        debugLog = [NRMADEBUG_Reachability new];
    });
    [debugLog syncIncTotal];
    NRTimer* timer = [NRTimer new];
#endif


    static NSString* wanType;
    static NSTimeInterval lastCachedAt_millis;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wanType = nil;
        lastCachedAt_millis = 0;
    });

    NRMANetworkStatus status = [self networkStatus];
    //double check for the same thing before and after synchronization
    //we might encounter unnecessary sync blockage here if we do the check beforehand
    //and we will prevent multiple checks
    if (lastCachedAt_millis == 0 || (NRMAMillisecondTimestamp() - lastCachedAt_millis) > kNRWanTypeCacheLifetime) {
        NRMAReachability* r = [self reachability];
        @synchronized(r) {
            if (lastCachedAt_millis == 0 || (NRMAMillisecondTimestamp() - lastCachedAt_millis) > kNRWanTypeCacheLifetime) {
                wanType = [r getCurrentWanNetworkType:status];
                lastCachedAt_millis = NRMAMillisecondTimestamp();
#ifdef NRMA_REACHABILITY_DEBUG
                [debugLog syncIncReachabilityHit];
                [timer stopTimer];
                [debugLog addReachabilityWait:timer.timeElapsedInMilliSeconds];
#endif
            }
#ifdef NRMA_REACHABILITY_DEBUG
            else {
                [debugLog syncIncCacheHit];
                [debugLog syncIncWaited];
                [timer stopTimer];
                [debugLog addWaitingCacheHitWait:timer.timeElapsedInMilliSeconds];
            }
#endif
        }
    }
#ifdef NRMA_REACHABILITY_DEBUG
    else {
        [debugLog syncIncNoWait];
        [debugLog syncIncCacheHit];
        [timer stopTimer];
        [debugLog addNoWaitingCacheHitWait:timer.timeElapsedInMilliSeconds];
    }
#endif

#ifdef NRMA_REACHABILITY_DEBUG
    if (debugLog.total % 1000 == 0){
        NRLOG_INFO(@"%@",debugLog);
    }
#endif
    if (!wanType.length) {
        switch (status) {
            case ReachableViaWiFi:
                return NRMA_CARRIER_WIFI;
                break;
            default:
                return NRMA_CARRIER_OTHER;
                break;
        }
    }
    return wanType;

}


+ (NRMAReachability*) reachability {
    static NRMAReachability* r = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        r = [NRMAReachability reachability];
    });
    return r;
}

/*
 Returns the device model.  Ex.  iPhone4,1
 */
static NSString* __mach_model;

+ (NSString*) deviceModel {
    NSString* mach_model = [self machModel];
    if ([mach_model length]) {
        return mach_model;
    }

    mach_model = [self deviceModelViaSysCtrl];
    if ([mach_model length]) {
        [self setMachModel:mach_model];
        return mach_model;
    }

    return [[UIDevice currentDevice] model];
}

+ (NSString*) machModel {
    @synchronized(__mach_model) {
        return __mach_model;
    }
}

+ (void) setMachModel:(NSString*)model {
    @synchronized(__mach_model) {
        __mach_model = model;
    }
}

+ (NSString*) deviceModelViaSysCtrl {
    size_t size;
    NSString* model = nil;
    if (sysctlbyname("hw.machine", NULL, &size, NULL, 0) == 0) {
        char* name = malloc(size);
        if (name != NULL) {
            @try {
                // get the platform name
                if (sysctlbyname("hw.machine", name, &size, NULL, 0) == 0) {
                    model = [NSString stringWithCString:name
                                               encoding:NSUTF8StringEncoding];
                }
            } @finally {
                free(name);
            }
        }
    }
    return model;
}

+ (NSString*) normalizedStringFromURL:(NSURL*)url {
    return [NewRelicInternalUtils normalizedStringFromString:url.absoluteString];
}

+ (NSString*) normalizedStringFromString:(NSString*)url {
    // remove any request parameters from the URL before handing it off to New Relic
    NSRange pathRange = [url rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@";?"]];
    if (pathRange.location != NSNotFound) {
        url = [url substringToIndex:pathRange.location];
    }

    // correct a really lame failing in the NSURL validator, which will allow a single slash after the protocol...
    NSRange slashRange = [url rangeOfString:@"://"];
    if (slashRange.location == NSNotFound) {
        slashRange = [url rangeOfString:@":/"];
        if (slashRange.location != NSNotFound) {
            url = [url stringByReplacingOccurrencesOfString:@":/"
                                                 withString:@"://"];
        }
    }

    return url;
}

+ (NSString*) cleanseStringForCollector:(NSString*)string {
    NSArray* badCharacters = @[@"#",
            @"/",
            @"|",
            @"\\",
            @"\"",
            @"\'",
            @"(",
            @")",
            @"]",
            @"[",
            @";",
            @"!",
            @"$",
            @"@",
            @"<",
            @">"];
    for (NSString* badCharacter in badCharacters) {
        string = [string stringByReplacingOccurrencesOfString:badCharacter
                                                   withString:@"_"];
    }
    return string;
}

#pragma mark - regex helper

+ (BOOL) validateString:(NSString*)input
 usingRegularExpression:(NSRegularExpression*)regex {
    NSRange inputRange = NSMakeRange(0, input.length);
    NSRange resultRange = [regex rangeOfFirstMatchInString:input
                                                   options:NSMatchingAnchored
                                                     range:inputRange];
    if (inputRange.length == resultRange.length && inputRange.location == resultRange.location) {
        //if range of the input and the result are the same then the input is valid
        return YES;
    }
    return NO;
}


+ (NSString*) getStorePath {
#if TARGET_OS_TV
    //tvOS doesn't support the documents dir. The cache dir is the next best thing (and is used by the crash reporter, which means it should work O.K.)
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDir = paths[0];
    return cacheDir.path;
#else
    NSArray* paths = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                            inDomains:NSUserDomainMask];
    NSURL* documentDirURL = paths[0];
    return [documentDirURL.path stringByAppendingPathComponent:@"newrelic"];
#endif
}
@end

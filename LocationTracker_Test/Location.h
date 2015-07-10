//
//  Location.h
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 09/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject

+(CLLocation*)lastReceivedLocation;
+(void)setLastReceivedLocation :(CLLocation*)location;

+(NSDate *)lastDidEnterTimestamp;
+(void)setLastDidEnterTimestamp :(NSDate *)timestamp;

+(NSDate *)lastDidExitTimestamp;
+(void)setLastDidExitTimestamp :(NSDate *)timestamp;

+(BOOL)locationTracking;
+(void)setLocationTracking :(BOOL)flag;

+(BOOL)regionMonitoring;
+(void)setregionMonitoring :(BOOL)flag;
@end

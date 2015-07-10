//
//  Location.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 09/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "Location.h"

@implementation Location

+(CLLocation*)lastReceivedLocation{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicLocation = [ud objectForKey:@"last_received_location"];
    CLLocation *location;
    if (dicLocation) {
        CLLocationDegrees lat = [[dicLocation valueForKey:@"latitude"]doubleValue];
        CLLocationDegrees lon = [[dicLocation valueForKey:@"longitude"]doubleValue];
        location = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    }
    return location;
}

+(void)setLastReceivedLocation :(CLLocation*)location{
    NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    NSDictionary *dicLocation = @{
                                  @"latitude":lat,
                                  @"longitude":lon
                                  };
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:dicLocation forKey:@"last_received_location"];
    [ud synchronize];
}

+(NSDate *)lastDidEnterTimestamp{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *date = [ud objectForKey:@"last_did_enter_timestamp"];
    return date;
}
+(void)setLastDidEnterTimestamp :(NSDate *)timestamp{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:timestamp forKey:@"last_did_enter_timestamp"];
    [ud synchronize];
}

+(NSDate *)lastDidExitTimestamp{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *date = [ud objectForKey:@"last_did_exit_timestamp"];
    return date;
}
+(void)setLastDidExitTimestamp :(NSDate *)timestamp{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:timestamp forKey:@"last_did_exit_timestamp"];
    [ud synchronize];
}

@end

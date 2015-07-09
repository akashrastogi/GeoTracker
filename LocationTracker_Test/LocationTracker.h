//
//  LocationManager.h
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 09/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationTracker : NSObject<CLLocationManagerDelegate>
+ (LocationTracker *)sharedInstance;
-(void)startMonitoringSignificantLocationChanges;
-(void) showLocalNotification :(NSString *)msg;
@end

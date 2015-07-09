//
//  LocationManager.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 09/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "LocationTracker.h"
#import "WebServiceManager.h"

@interface LocationTracker ()
@property (nonatomic) CLLocationManager * locationManager;
@end

@implementation LocationTracker
@synthesize locationManager;

// singleton instance
static LocationTracker *_locationTracker = nil;
+ (LocationTracker *)sharedInstance {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _locationTracker = [[LocationTracker alloc] init];
    });
    return _locationTracker;
}

#pragma mark - Location tracking
- (CLLocationManager *) locationManager {
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
    }
    return locationManager;
}
-(void)startMonitoringSignificantLocationChanges {
    NSLog(@"startMonitoringSignificantLocationChanges");
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
}
-(void)stopMonitoringSignificantLocationChanges {
    NSLog(@"stopMonitoringSignificantLocationChanges");
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSMutableArray *arr = [NSMutableArray new];
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    NSString *deviceOS = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice]systemName], [[UIDevice currentDevice] systemVersion]];
    for (CLLocation *loc in locations) {
        NSDictionary *dict = @{@"latitude": [NSNumber numberWithFloat:loc.coordinate.latitude],
                               @"longitude": [NSNumber numberWithLong:loc.coordinate.longitude],
                               @"speed": [NSNumber numberWithDouble:[loc speed]],
                               @"course": [NSNumber numberWithDouble:[loc course]],
                               @"horizontal_accuracy": [NSNumber numberWithDouble:loc.horizontalAccuracy],
                               @"vertical_accuracy": [NSNumber numberWithDouble:loc.verticalAccuracy],
                               @"battery_level": [NSNumber numberWithFloat:batteryLevel],
                               @"device": deviceOS};
        [arr addObject:dict];
    }
    
    // if locations availale, send them to server
    if ([arr count]>0) {
        NSDictionary *param = @{@"locations": arr};
        WebServiceManager *wsManager = [[WebServiceManager alloc]init];
        [wsManager postLocation:param withCompletionHandler:^(id response, NSError *err) {
            if (err) {
                NSString *errMsg = [NSString stringWithFormat:@"Could not post locations to server. \n Error- %@", err.localizedDescription];
                NSLog(@"%@", errMsg);
                [self updateUIforWebserviceresult:errMsg];
            }
            else {
                NSLog(@"Location data posted to server successfully. \n Locations- %@", arr);
                NSString *msg = [NSString stringWithFormat:@"Locations- %@", arr];
                [self updateUIforWebserviceresult:msg];
            }
        }];
    }
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error{
    [self updateUIforWebserviceresult:error.localizedDescription];
}

#pragma mark - Tell the user about location updates
-(void) updateUIforWebserviceresult :(NSString *)msg{
    if ([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive) {
        [[[UIAlertView alloc]initWithTitle:@"didUpdateLocations" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    }
    else {
        [self showLocalNotification:msg];
    }
}

-(void) showLocalNotification :(NSString *)msg{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber+1];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = msg;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}
@end

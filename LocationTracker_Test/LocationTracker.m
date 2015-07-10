//
//  LocationManager.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 09/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "LocationTracker.h"
#import "WebServiceManager.h"
#import "Location.h"

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
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = 100.0;
        locationManager.delegate = self;
    }
    return locationManager;
}
-(void)startMonitoringSignificantLocationChanges {
    NSLog(@"startMonitoringSignificantLocationChanges");
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self showNotificationAlert:@"Your device doesn't support significant location change monitoring."];
        return;
    }
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
}
-(void)stopMonitoringSignificantLocationChanges {
    NSLog(@"stopMonitoringSignificantLocationChanges");
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - Region monitoring
-(void)startRegionMonitoring{
    NSLog(@"startRegionMonitoring");
    // stop region monitoring if exist
    [self stopRegionMonitoring];
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        [self showNotificationAlert:@"Your device doesn't region monitoring."];
        return;
    }
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    // read regions from geojson file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Regions" ofType:@"geojson"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    // add regions to location manager for monitoring
    for (NSDictionary *dict in array) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[dict valueForKey:@"lat"] doubleValue], [[dict valueForKey:@"long"] doubleValue]);
        CLLocationDistance radius = [[dict valueForKey:@"radius"]doubleValue];
        NSString *identifier = [dict valueForKey:@"identifier"];
        CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:coordinate radius:radius identifier:identifier];
        [self.locationManager startMonitoringForRegion:region];
    }
}
-(void)stopRegionMonitoring{
    NSLog(@"stopRegionMonitoring");
    for (CLRegion *region in self.locationManager.monitoredRegions){
        [ self.locationManager stopMonitoringForRegion: region];
    }
}

#pragma mark - CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@", @"locationManager didUpdateLocations called");
    if (locations.count == 0) {
        return;
    }
    
    CLLocation *newLocation = [locations lastObject];
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases we will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    
    // test the distance covered from last received location, Distance should be more than 0 meters
    CLLocationDistance distanceCovered = 0.0;
    CLLocation *lastReceivedLocation = [Location lastReceivedLocation];
    [Location setLastReceivedLocation:newLocation];
    if (lastReceivedLocation) {
        distanceCovered = [newLocation distanceFromLocation:lastReceivedLocation];
        if (distanceCovered <= 0) return;
    }
    
    NSMutableArray *arr = [NSMutableArray new];
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    NSString *deviceOS = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice]systemName], [[UIDevice currentDevice] systemVersion]];
    for (CLLocation *loc in locations) {
        NSDictionary *dict = @{
                               @"latitude": [NSNumber numberWithFloat:loc.coordinate.latitude],
                               @"longitude": [NSNumber numberWithLong:loc.coordinate.longitude],
                               @"speed": [NSNumber numberWithDouble:[loc speed]],
                               @"course": [NSNumber numberWithDouble:[loc course]],
                               @"horizontal_accuracy": [NSNumber numberWithDouble:loc.horizontalAccuracy],
                               @"vertical_accuracy": [NSNumber numberWithDouble:loc.verticalAccuracy],
                               @"battery_level": [NSNumber numberWithFloat:batteryLevel],
                               @"device": deviceOS
                               };
        [arr addObject:dict];
    }
    
    NSDictionary *param = @{
                            @"type": @"location_update",
                            @"distance_in_meters": [NSNumber numberWithDouble:distanceCovered],
                            @"locations": arr
                            };
    WebServiceManager *wsManager = [[WebServiceManager alloc]init];
    [wsManager postLocation:param withCompletionHandler:^(id response, NSError *err) {
        if (err) {
            NSString *errMsg = [NSString stringWithFormat:@"Could not post locations to server. \n Error- %@", err.localizedDescription];
            NSLog(@"%@", errMsg);
            [self showNotificationAlert:errMsg];
        }
        else {
            NSLog(@"Location data posted to server successfully. \n Locations- %@", param);
            NSString *msg = [NSString stringWithFormat:@"Locations- %@", param];
            [self showNotificationAlert:msg];
        }
    }];
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error{
    [self showNotificationAlert:error.localizedDescription];
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    // check if received this event with 5 second, discard it to avoid duplication
    NSDate *lastDidEnterTime = [Location lastDidEnterTimestamp];
    if (lastDidEnterTime &&
        [[NSDate date] timeIntervalSinceDate:lastDidEnterTime] < 5) {
        return;
    }
    
    NSDictionary *param = @{
                            @"type": @"did_enter_region",
                            @"region_identifier": region.identifier
                            };
    WebServiceManager *wsManager = [[WebServiceManager alloc]init];
    [wsManager postLocation:param withCompletionHandler:^(id response, NSError *err) {
        if (err) {
            NSString *errMsg = [NSString stringWithFormat:@"Could not post 'didEnterRegion' event for identifier- %@ to server. \n Error- %@", region.identifier, err.localizedDescription];
            NSLog(@"%@", errMsg);
            [self showNotificationAlert:errMsg];
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"'didEnterRegion' data posted to server successfully. \n Identifier- %@", region.identifier];
            NSLog(@"%@", msg);
            [self showNotificationAlert:msg];
        }
    }];
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    // check if received this event with 5 second, discard it to avoid duplication
    NSDate *lastDidExitTime = [Location lastDidExitTimestamp];
    if (lastDidExitTime &&
        [[NSDate date] timeIntervalSinceDate:lastDidExitTime] < 5) {
        return;
    }
    
    NSDictionary *param = @{
                            @"type": @"did_exit_region",
                            @"region_identifier": region.identifier
                            };
    WebServiceManager *wsManager = [[WebServiceManager alloc]init];
    [wsManager postLocation:param withCompletionHandler:^(id response, NSError *err) {
        if (err) {
            NSString *errMsg = [NSString stringWithFormat:@"Could not post 'didExitRegion' event for identifier- %@ to server. \n Error- %@", region.identifier, err.localizedDescription];
            NSLog(@"%@", errMsg);
            [self showNotificationAlert:errMsg];
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"'didExitRegion' data posted to server successfully. \n Identifier- %@", region.identifier];
            NSLog(@"%@", msg);
            [self showNotificationAlert:msg];
        }
    }];
    [self.locationManager stopMonitoringForRegion:region];
}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    [self showNotificationAlert:[NSString stringWithFormat:@"monitoringDidFailForRegion for Identifier- %@ \n Error- %@", region.identifier, error.localizedDescription]];
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"didStartMonitoring for region identifier- %@", region.identifier);
}

#pragma mark - Tell the user about location updates
-(void) showNotificationAlert :(NSString *)msg{
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

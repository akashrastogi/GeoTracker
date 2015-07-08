//
//  AppDelegate.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 08/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic) CLLocationManager * locationManager;
@end

@implementation AppDelegate
@synthesize locationManager;
CLLocation *lastLocation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    if ([[UIApplication sharedApplication]respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                       message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                       message:@"The functions of this app are limited because the Background App Refresh is disable."
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            NSLog(@"UIApplicationLaunchOptionsLocationKey");
            [self showLocalNotification:@"app is launched by core location event"];
        }
        [self startMonitoringSignificantLocationChanges];
    }
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    return YES;
}

#pragma mark - app state methods
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    //lastRegion
    CLLocation *loc = [locations lastObject];
    CLLocationDistance distance = 0.0;
    if (lastLocation) {
        distance = [loc distanceFromLocation:lastLocation];
    }
    NSString *location = [NSString stringWithFormat:@"distance- %f && locations- %@", distance, [locations componentsJoinedByString:@"\n"]];
    NSLog(@"didUpdateLocations- %@", location);
    if ([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive) {
        [[[UIAlertView alloc]initWithTitle:@"didUpdateLocations" message:location delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    }
    else {
        [self showLocalNotification:location];
    }
    lastLocation = loc;
}

#pragma mark - Show local notification
-(void) showLocalNotification :(NSString *)appstate{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber+1];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = appstate;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}
@end

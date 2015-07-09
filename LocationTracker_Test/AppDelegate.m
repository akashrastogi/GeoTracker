//
//  AppDelegate.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 08/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "AppDelegate.h"
#import <RestKit/RestKit.h>
#import "WebServiceManager.h"

@interface AppDelegate ()
@property (nonatomic) CLLocationManager * locationManager;
@end

@implementation AppDelegate
@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configure RestKit
    [self setupRestKit];
    
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

#pragma mark - Show local notification
-(void) updateUIforWebserviceresult :(NSString *)msg{
    if ([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive) {
        [[[UIAlertView alloc]initWithTitle:@"didUpdateLocations" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    }
    else {
        [self showLocalNotification:msg];
    }
}

-(void) showLocalNotification :(NSString *)appstate{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber+1];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = appstate;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark - RestKit configuration
- (void) setupRestKit {
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL: [NSURL URLWithString:BASE_URL]];
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
    [RKObjectManager setSharedManager:objectManager];
}
@end

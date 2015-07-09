//
//  AppDelegate.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 08/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "AppDelegate.h"
#import <RestKit/RestKit.h>
#import "LocationTracker.h"

@implementation AppDelegate

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
        LocationTracker *locationTracker = [LocationTracker sharedInstance];
        [locationTracker startMonitoringSignificantLocationChanges];
        
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            NSLog(@"app is launched by core location event");
            [locationTracker showLocalNotification:@"app is launched by core location event"];
        }
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

#pragma mark - RestKit configuration
- (void) setupRestKit {
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL: [NSURL URLWithString:BASE_URL]];
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [objectManager setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
    [RKObjectManager setSharedManager:objectManager];
}
@end

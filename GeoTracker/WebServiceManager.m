//
//  WebServiceManager.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 09/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "WebServiceManager.h"
#import <RestKit/RestKit.h>

@interface WebServiceManager ()
@property (nonatomic, strong)RKObjectManager *ObjectManager;
@end

@implementation WebServiceManager
-(id) init{
    if (self = [super init]) {
        if (![RKObjectManager sharedManager]) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            [appDelegate setupRestKit];
        }
        self.ObjectManager = [RKObjectManager sharedManager];
    }
    
    return self;
}

-(void) postLocation :(NSDictionary *)param withCompletionHandler: (completionBlock)completionHandler{
    [self.ObjectManager.HTTPClient postPath:POST_LOCATIONS parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(nil, error);
    }];
}

@end

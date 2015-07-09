//
//  WebServiceManager.h
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 09/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completionBlock)(id response, NSError *err);

@interface WebServiceManager : NSObject
-(id) init;
-(void) postLocation :(NSDictionary *)param withCompletionHandler: (completionBlock)completionHandler;

@end

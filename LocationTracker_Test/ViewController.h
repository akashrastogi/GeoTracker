//
//  ViewController.h
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 08/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *switchLocationTracking;
@property (weak, nonatomic) IBOutlet UISwitch *switchRegionMonitoring;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end


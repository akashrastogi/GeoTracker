//
//  ViewController.m
//  LocationTracker_Test
//
//  Created by Akash Rastogi on 08/07/15.
//  Copyright (c) 2015 Akash. All rights reserved.
//

#import "ViewController.h"
#import "Location.h"
#import "LocationTracker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add action target to the controls
    [self.switchLocationTracking addTarget:self action:@selector(locationTrackingValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.switchRegionMonitoring addTarget:self action:@selector(regionMonitoringValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.mapView.delegate = self;
    
    [self initialSetup];
}

- (void)initialSetup{
    [self.switchLocationTracking setOn:[Location locationTracking]];
    [self locationTrackingValueChanged:self.switchLocationTracking];
    
    [self.switchRegionMonitoring setOn:[Location regionMonitoring]];
    [self regionMonitoringValueChanged:self.switchRegionMonitoring];
}

- (IBAction)locationTrackingValueChanged:(UISwitch *)sender {
    LocationTracker *tracker = [LocationTracker sharedInstance];
    if (sender.isOn) {
        [tracker startMonitoringSignificantLocationChanges];
    }
    else [tracker stopMonitoringSignificantLocationChanges];
    
    [Location setLocationTracking:sender.isOn];
}

- (IBAction)regionMonitoringValueChanged:(UISwitch *)sender {
    LocationTracker *tracker = [LocationTracker sharedInstance];
    if (sender.isOn) {
        [tracker startRegionMonitoring];
    }
    else [tracker stopRegionMonitoring];
    
    [Location setregionMonitoring:sender.isOn];
}

#pragma mark - MKMapView Delegate methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    return nil;
}
@end

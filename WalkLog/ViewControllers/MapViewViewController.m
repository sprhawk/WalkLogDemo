//
//  MapViewViewController.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-9-29.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "MapViewViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MarsCoordinate.h"
#import "EarthToMars.h"

@interface MapViewViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager * _locationManager;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocation *l = userLocation.location;
    if (l) {
        CLLocationCoordinate2D coor = l.coordinate;
        NSLog(@"MapView User Location:lon:%f, lat:%f", coor.longitude, coor.latitude);
        
        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(coor, 200, 200);
        [mapView setRegion:r animated:YES];
    }
}

#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *l = [locations lastObject];
    if (l) {
        CLLocationCoordinate2D coor = l.coordinate;
        double lat = 0;
        double lon = 0;
        NSLog(@"CoreLocation location:lon:%f, lat:%f", coor.longitude, coor.latitude);

        mars_corrected_coordinate(coor.longitude, coor.latitude, &lon, &lat);
        CLLocationCoordinate2D c = [[EarthToMars sharedEarthToMars] marsCoordinateFromEarth:coor];
        NSLog(@"mars:calculated:lon:%f, lat:%f, lookup:lon:%f, lat:%f", lon, lat, c.longitude, c.latitude);
    }
}

@end

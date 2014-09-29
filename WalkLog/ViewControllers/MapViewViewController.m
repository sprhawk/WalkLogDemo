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

#import "MyLocationAnnotation.h"

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
        NSLog(@"MapView User Location:lat:%f, lon:%f", coor.longitude, coor.latitude);
        
        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(coor, 200, 200);
        [mapView setRegion:r animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MyLocationAnnotation class]]) {
        MKPinAnnotationView *v = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        v.canShowCallout = YES;
        MyLocationAnnotation *a = annotation;
        switch (a.type) {
            case AnnotationTypeCalculated:
                v.pinColor = MKPinAnnotationColorRed;
                break;
            case AnnotationTypeLookup:
                v.pinColor = MKPinAnnotationColorGreen;
                break;
            default:
                break;
        }
        return v;
    }
    return nil;
}

#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *l = [locations lastObject];
    if (l) {
        CLLocationCoordinate2D coor = l.coordinate;
        double lat = 0;
        double lon = 0;
        NSLog(@"CoreLocation location:lat:%f, lon:%f", coor.longitude, coor.latitude);

        mars_corrected_coordinate(coor.latitude, coor.longitude, &lat, &lon);
        CLLocationCoordinate2D c = [[EarthToMars sharedEarthToMars] marsCoordinateFromEarth:coor];
        NSLog(@"mars:calculated:lat:%f, lon:%f, lookup:lat:%f, lon:%f", lon, lat, c.longitude, c.latitude);
        
        MyLocationAnnotation *a = [[MyLocationAnnotation alloc] init];
        a.coordinate = c;
        a.type = AnnotationTypeLookup;
        a.title = @"Lookup";
        [self.mapView addAnnotation:a];
        
        a = [[MyLocationAnnotation alloc] init];
        a.type = AnnotationTypeCalculated;
        a.title = @"Calculated";
        a.coordinate = CLLocationCoordinate2DMake(lat, lon);
        [self.mapView addAnnotation:a];
    }
}

@end

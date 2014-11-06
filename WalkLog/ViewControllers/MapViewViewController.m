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
#import <CoreMotion/CoreMotion.h>

#import "MarsCoordinate.h"
#import "EarthToMars.h"

#import "MyLocationAnnotation.h"
#import "DataCenter.h"
#import "NetworkCenter.h"

@interface MapViewViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>
{
    CLLocationManager * _locationManager;
}

@property (nonatomic, strong, readwrite) CMMotionManager *motionManager;
@property (nonatomic, strong, readwrite) NSOperationQueue *queue;

@property (nonatomic, strong, readwrite) id<MKAnnotation> calcAnnotation;
@property (nonatomic, strong, readwrite) id<MKAnnotation> lookupAnnotation;
@property (nonatomic, strong, readwrite) id<MKAnnotation> earthAnnotation;

@property (nonatomic, assign, readwrite) BOOL isUserLocationSet;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
- (IBAction)didTap:(id)sender;
- (IBAction)showHistory:(id)sender;
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

- (void)awakeFromNib
{
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        [self startUpdatingLocation];
    }
    
    if (nil == self.motionManager) {
        self.queue = [[NSOperationQueue alloc] init];
        self.motionManager = [[CMMotionManager alloc] init];
        if(self.motionManager.accelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = 0.1;
            [self.motionManager startAccelerometerUpdatesToQueue:self.queue
                                                     withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                         //                                                         NSString *a = [NSString stringWithFormat:@"a:%f;%f;%f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z];
                                                         //                                                         NSLog(@"%@", a);
                                                         //                                                         NSData *d = [a dataUsingEncoding:NSUTF8StringEncoding];
                                                         //                                                         [[NetworkCenter sharedCenter] sendData:d];
                                                     }];
        }
        
        if (self.motionManager.gyroAvailable) {
            self.motionManager.gyroUpdateInterval = 0.1;
            [self.motionManager startGyroUpdatesToQueue:self.queue
                                            withHandler:^(CMGyroData *gyroData, NSError *error) {
                                                //                                                NSString *a = [NSString stringWithFormat:@"g:%f;%f;%f", gyroData.rotationRate.x, gyroData.rotationRate.y, gyroData.rotationRate.z];
                                                //                                                NSData *d = [a dataUsingEncoding:NSUTF8StringEncoding];
                                                //                                                [[NetworkCenter sharedCenter] sendData:d];
                                            }];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *a = [[DataCenter sharedCenter] allLocations];
        NSLog(@"allLocations count:%d", a.count);
        for (CLLocation *l in a) {
            CLLocationCoordinate2D coor = l.coordinate;
            double lat = 0.0f, lon = 0.0;
            mars_corrected_coordinate(coor.latitude, coor.longitude, &lat, &lon);
            CLLocationCoordinate2D c;
            c.latitude = lat;
            c.longitude = lon;
            
            MyLocationAnnotation *ann = nil;
            ann = [[MyLocationAnnotation alloc] init];
            ann.coordinate = c;
            ann.type = AnnotationTypeCalculated;
            ann.title = l.timestamp.description;
            [self.mapView addAnnotation:ann];
        }
    });
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
        NSLog(@"MapView User Location:lat:%f, lon:%f", coor.latitude, coor.longitude);
        if (!self.isUserLocationSet) {
            MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(coor, 200, 200);
            [mapView setRegion:r animated:YES];
            self.isUserLocationSet = YES;
        }
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
            case AnnotationTypeEarth:
            default:
                v.pinColor = MKPinAnnotationColorPurple;
                break;
        }
        return v;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"didFailToLocateUserWithError:%@", error);
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"mapViewDidFailLoadingMap:%@", error);
}

#pragma mark - Location operations
- (void)startUpdatingLocation
{
    if([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (kCLAuthorizationStatusAuthorized == status
            || kCLAuthorizationStatusAuthorizedAlways == status
            || (kCLAuthorizationStatusNotDetermined == status && ![_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            
            _locationManager.distanceFilter = 10.0f;
//            [_locationManager startUpdatingLocation];
            
            if ([CLLocationManager headingAvailable]) {
                [_locationManager startUpdatingHeading];
            }
            
            [_locationManager startMonitoringSignificantLocationChanges];
        }
        else if(kCLAuthorizationStatusNotDetermined == status
                || kCLAuthorizationStatusAuthorizedWhenInUse == status
                ) {
            [_locationManager requestAlwaysAuthorization]; // only 7.0 and above
        }
        else if(kCLAuthorizationStatusDenied == status
                || kCLAuthorizationStatusRestricted == status) {
            
        }
    }
}

#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *l = [locations lastObject];
    if (l) {
        [[DataCenter sharedCenter] insertLocation:l];
        
        CLLocationCoordinate2D coor;
        coor = l.coordinate;
//        coor.latitude = 39 * 360 +  56.7643;
//        coor.longitude = 116 * 360 + 24.7349;
        double lat = 0;
        double lon = 0;
//        NSString *s = [NSString stringWithFormat:@"CoreLocation location:lat:%f, lon:%f", coor.latitude, coor.longitude];
//        NSLog(@"%@", s);
//        NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
//        [[NetworkCenter sharedCenter] sendData:d];
        
        mars_corrected_coordinate(coor.latitude, coor.longitude, &lat, &lon);
        CLLocationCoordinate2D c = [[EarthToMars sharedEarthToMars] marsCoordinateFromEarth:coor];
        NSLog(@"mars:calculated:lat:%f, lon:%f, lookup:lat:%f, lon:%f", lat, lon, c.latitude, c.longitude);
        
        MyLocationAnnotation *a = nil;
        a = [[MyLocationAnnotation alloc] init];
        a.coordinate = c;
        a.type = AnnotationTypeLookup;
        a.title = @"Lookup";
        if (self.lookupAnnotation) {
            [self.mapView removeAnnotation:self.lookupAnnotation];
        }
        self.lookupAnnotation = a;
        [self.mapView addAnnotation:self.lookupAnnotation];
        
        a = [[MyLocationAnnotation alloc] init];
        a.type = AnnotationTypeCalculated;
        a.title = @"Calculated";
        a.coordinate = CLLocationCoordinate2DMake(lat, lon);
        if (self.calcAnnotation) {
            [self.mapView removeAnnotation:self.calcAnnotation];
        }
        self.calcAnnotation = a;
        [self.mapView addAnnotation:self.calcAnnotation];
        
        a = [[MyLocationAnnotation alloc] init];
        a.coordinate = coor;
        a.type = AnnotationTypeEarth;
        a.title = @"Earth";
        if (self.earthAnnotation) {
            [self.mapView removeAnnotation:self.earthAnnotation];
        }
        self.earthAnnotation = a;
        [self.mapView addAnnotation:self.earthAnnotation];
        
        if (UIApplicationStateBackground == [UIApplication sharedApplication].applicationState) {
            UILocalNotification *n = [[UILocalNotification alloc] init];
            n.alertBody = [NSString stringWithFormat:@"lat:%f lon:%f", coor.latitude, coor.longitude];
            [[UIApplication sharedApplication] presentLocalNotificationNow:n];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManater:%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
//    NSLog(@"heading:%@", newHeading);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}

- (IBAction)didTap:(id)sender {
//    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (IBAction)showHistory:(id)sender {
    UIActionSheet *s = [[UIActionSheet alloc] initWithTitle:@"Type"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"List", @"Map", nil];
    [s showInView:self.view];
}

#pragma mark - ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"showList" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"showMap" sender:nil];
            break;
        default:
            break;
    }
}
@end

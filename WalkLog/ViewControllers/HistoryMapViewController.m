//
//  HistoryMapViewController.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-9.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "HistoryMapViewController.h"
#import <MapKit/MapKit.h>
#import "DataCenter.h"
#include "MarsCoordinate.h"
#import "MyLocationAnnotation.h"

@interface HistoryMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign, readwrite) BOOL isUserLocationSet;
@end

@implementation HistoryMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
            MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(coor, 3000, 3000);
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

@end

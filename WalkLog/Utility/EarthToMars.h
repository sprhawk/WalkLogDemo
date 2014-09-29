//
//  EarthToMars.h
//  WalkLog
//
//  Created by YANG HONGBO on 2014-9-29.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EarthToMars : NSObject
+ (instancetype)sharedEarthToMars;
- (CLLocationCoordinate2D)marsCoordinateFromEarth:(CLLocationCoordinate2D)coordinate;
@end

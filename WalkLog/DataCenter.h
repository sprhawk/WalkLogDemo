//
//  DataCenter.h
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-8.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define DataCenterDidInsertLocationNotification @"DataCenterDidInsertLocationNotification"

@interface DataCenter : NSObject
+ (instancetype)sharedCenter;
- (BOOL)insertLocation:(CLLocation *)location;
- (NSUInteger)locationsCount;
- (CLLocation *)locationAtIndex:(NSUInteger)index;
- (CLLocation *)locationAtIndex:(NSUInteger)index isForeground:(BOOL *)isForeground;
- (NSArray *)allLocations;
@end

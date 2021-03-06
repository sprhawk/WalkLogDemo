//
//  SelectLocationStatement.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-8.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "SelectLocationStatement.h"

@implementation SelectLocationStatement

+ (id)statementWithYSqlite:(YSqlite *)ysqlite
{
    SelectLocationStatement * s = nil;
    s = [[self class] statementWithSql:@"select latitude, longitude, haccuracy, altitude, vaccuracy, course, speed, timestamp, foreground from locations order by timestamp desc limit :limit offset :offset ;" ysqlite:ysqlite];
    return s;
}
- (CLLocation *)locationAtIndex:(NSUInteger)index
{
    return [self locationAtIndex:index isForeground:NULL];
}

- (CLLocation *)locationAtIndex:(NSUInteger)index isForeground:(BOOL *)isForeground
{
    CLLocation *l = nil;
    [self reset];
    [self bindInt:1 index:1];
    [self bindInt:(int)index index:2];
    if ([self execute]) {
        if ([self hasRow]) {
            double lat, lon, hacc, alt, vacc, course, speed, timestamp;
            lat = [self doubleValueAtIndex:0];
            lon = [self doubleValueAtIndex:1];
            hacc = [self doubleValueAtIndex:2];
            alt = [self doubleValueAtIndex:3];
            vacc = [self doubleValueAtIndex:4];
            course = [self doubleValueAtIndex:5];
            speed = [self doubleValueAtIndex:6];
            timestamp = [self int64ValueAtIndex:7];
            if (isForeground) {
                *isForeground = [self intValueAtIndex:8];
            }
            
            CLLocationCoordinate2D coor;
            coor.latitude = lat;
            coor.longitude = lon;
            l = [[CLLocation alloc] initWithCoordinate:coor
                                              altitude:alt
                                    horizontalAccuracy:hacc
                                      verticalAccuracy:vacc
                                             timestamp:[NSDate dateWithTimeIntervalSince1970:timestamp * 1.0f / 1000.0f]];
            return l;
        }
        else {
            NSLog(@"has no row at index:%d", (int)index);
        }
    }
    return l;
}

@end

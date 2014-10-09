//
//  InsertLocationStatement.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-8.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "InsertLocationStatement.h"

@implementation InsertLocationStatement
+ (id)statementWithYSqlite:(YSqlite *)ysqlite
{
    return [[self class] statementWithSql:@"insert into locations (latitude, longitude, haccuracy, altitude, vaccuracy, course, speed, timestamp)"
                                            @"values(:latitude, :longitude, :haccuracy, :altitude, :vaccuracy, :course, :speed, :timestamp);"
                                  ysqlite:ysqlite];
}

- (BOOL)insertLocation:(CLLocation *)location
{
    if (location) {
        CLLocationCoordinate2D coor = location.coordinate;
        [self bindDouble:coor.latitude key:@":latitude"];
        [self bindDouble:coor.longitude key:@":longitude"];
        [self bindDouble:location.horizontalAccuracy key:@":haccuracy"];
        [self bindDouble:location.altitude key:@":altitude"];
        [self bindDouble:location.verticalAccuracy key:@":vaccuracy"];
        [self bindDouble:location.course key:@":course"];
        [self bindDouble:location.speed key:@":speed"];
        NSTimeInterval t = [location.timestamp timeIntervalSince1970];
        [self bindDouble:t key:@":timestamp"];
        
        return [self execute];
    }
    return NO;
}
@end

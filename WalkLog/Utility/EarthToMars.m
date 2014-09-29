//
//  EarthToMars.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-9-29.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "EarthToMars.h"
#import "CSqlite.h"

@interface EarthToMars ()
{
    CSqlite *_csqlite;
}
@end

@implementation EarthToMars

+ (instancetype)sharedEarthToMars
{
    static EarthToMars * __earthToMars = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __earthToMars = [[[self class] alloc] init];
    });
    return __earthToMars;
}

- (id)init
{
    self = [super init];
    if (self) {
        _csqlite = [[CSqlite alloc] init];
        [_csqlite openSqlite];
    }
    return self;
}

- (void)dealloc
{
    [_csqlite closeSqlite];
}

- (CLLocationCoordinate2D)marsCoordinateFromEarth:(CLLocationCoordinate2D)coordinate
{
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(coordinate.latitude*10);
    TenLog = (int)(coordinate.longitude*10);
    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
    sqlite3_stmt* stmtL = [_csqlite NSRunSql:sql];
    int offLat=0;
    int offLog=0;
    while (sqlite3_step(stmtL)==SQLITE_ROW)
    {
        offLat = sqlite3_column_int(stmtL, 0);
        offLog = sqlite3_column_int(stmtL, 1);
        
    }
    
    CLLocationCoordinate2D coor;
    coor.latitude = coordinate.latitude + offLat*0.0001;
    coor.longitude = coordinate.longitude + offLog*0.0001;
    
    return coor;
}
@end

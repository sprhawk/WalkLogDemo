//
//  InsertLocationStatement.h
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-8.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "YSqliteStatement.h"

#import <CoreLocation/CoreLocation.h>

@interface InsertLocationStatement : YSqliteStatement

+ (id)statementWithYSqlite:(YSqlite *)ysqlite;

- (BOOL)insertLocation:(CLLocation *)location;

@end

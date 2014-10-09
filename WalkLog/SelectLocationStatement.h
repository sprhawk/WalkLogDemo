//
//  SelectLocationStatement.h
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-8.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "YSqliteStatement.h"
#import <CoreLocation/CoreLocation.h>

@interface SelectLocationStatement : YSqliteStatement

- (CLLocation *)locationAtIndex:(NSUInteger)index;

@end

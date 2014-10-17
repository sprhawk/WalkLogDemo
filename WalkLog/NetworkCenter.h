//
//  NetworkCenter.h
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-18.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkCenter : NSObject
+ (instancetype)sharedCenter;
- (void)startBrowser;
- (void)sendData:(NSData *)data;
@end

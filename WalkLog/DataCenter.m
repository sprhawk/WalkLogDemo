//
//  DataCenter.m
//  WalkLog
//
//  Created by YANG HONGBO on 2014-10-8.
//  Copyright (c) 2014年 Yang.me. All rights reserved.
//

#import "DataCenter.h"

#import "ysqlite.h"
#import "YSqliteStatement.h"
#import "InsertLocationStatement.h"
#import "SelectLocationStatement.h"

@interface DataCenter ()

@property (nonatomic, strong, readwrite) YSqlite *ysqlite;
@property (nonatomic, strong, readwrite) InsertLocationStatement *insertLocationStatement;
@property (nonatomic, strong, readwrite) YSqliteStatement *locationsCountStatement;
@property (nonatomic, strong, readwrite) SelectLocationStatement *selectLocationStatement;
@end

@implementation DataCenter

+ (instancetype)sharedCenter
{
    static DataCenter *__sharedCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedCenter = [[[self class] alloc] init];
    });
    return __sharedCenter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (nil == self.ysqlite) {
            self.ysqlite = [[YSqlite alloc] init];
            BOOL ret = [self.ysqlite openOrCreateWithBlock:^(YSqlite *ysqlite) {
                BOOL rslt = NO;
                int version = [ysqlite userVersion];
                if (0 == version) {
                    NSError *error = nil;
                    NSURL * url = [[NSBundle mainBundle] URLForResource:@"schema_1" withExtension:@"sql"];
                    rslt = [ysqlite loadBatchStatementsAtURL:url error:&error];
                    if (!rslt) {
                        @throw [NSException exceptionWithName:@"WalLogDatabaseException" reason:[error localizedDescription] userInfo:nil];
                    }
                    
                    [ysqlite setUserVersion:1];
                }
                if (1 == version) {
                    
                }
            }];
            
            if (ret) {
                if (nil == self.insertLocationStatement) {
                    self.insertLocationStatement = [InsertLocationStatement statementWithYSqlite:self.ysqlite];
                }
                self.locationsCountStatement = [YSqliteStatement statementWithSql:@"select count() from locations;" ysqlite:self.ysqlite];
                self.selectLocationStatement = [SelectLocationStatement statementWithYSqlite:self.ysqlite];
            }
            else {
                NSLog(@"create sqlite failed");
            }
        }
    }
    return self;
}

- (BOOL)insertLocation:(CLLocation *)location
{
    BOOL r = [self.insertLocationStatement insertLocation:location];
    if (r) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DataCenterDidInsertLocationNotification
                                                            object:nil
                                                          userInfo:@{@"location": location}];
    }
    return r;
}

- (NSUInteger)locationsCount
{
    [self.locationsCountStatement reset];
    if ([self.locationsCountStatement execute]) {
        NSUInteger c = [self.locationsCountStatement intValueAtIndex:0];
        return c;
    }
    return 0;
}

- (CLLocation *)locationAtIndex:(NSUInteger)index
{
    return [self locationAtIndex:index isForeground:NULL];
}

- (CLLocation *)locationAtIndex:(NSUInteger)index isForeground:(BOOL *)isForeground
{
    CLLocation *l = [self.selectLocationStatement locationAtIndex:index isForeground:isForeground];
    return l;
}

@end

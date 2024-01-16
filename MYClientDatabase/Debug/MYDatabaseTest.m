//
//  MYDearBusinessTest.m
//  MYDearBusiness
//
//  Created by APPLE on 2024/1/8.
//

#import "MYDatabaseTest.h"
#import <MYDearDebug/MYDearDebug.h>
#import <MYUtils/MYUtils.h>
#import "MYApplicationManager.h"
#import <MYNetwork/MYNetwork.h>
#import <MYDearBusiness/MYDearBusiness.h>

@interface MYClientDatabase (MYDelete)

- (void)removeDatabaseFile;

@end

@implementation MYDatabaseTest

+ (void)load {
    [TheDebug registDebugModule:@"database".local moduleItmes:@[
        [MYDebugItemModel modelWithName:@"删除表格" block:^{
        [self deleteTables];
    }],
    ]];
    
}

+ (void)deleteTables {
    [theDatabase removeDatabaseFile];
}

@end

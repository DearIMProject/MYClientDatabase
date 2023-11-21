//
//  MYChatPersonManager.h
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/21.
//  用于对通讯录用户列表信息等的管理

#import <Foundation/Foundation.h>
#import "MYDataChatPerson.h"

NS_ASSUME_NONNULL_BEGIN

#define theChatPersonManager MYChatPersonManager.shared

@interface MYChatPersonManager : NSObject

+ (instancetype)shared;

- (NSMutableArray<MYDataChatPerson *> *)cacheChatPersons;

- (void)resetChatPersons:(NSArray<MYDataChatPerson *> *)chatpersons;

- (void)updateChatPerson:(MYDataChatPerson *)chatPerson;

- (void)removeChatPerson:(MYDataChatPerson *)chatPerson;

- (MYDataChatPerson *)chatPersonWithUserId:(long long)userId;

@end

NS_ASSUME_NONNULL_END

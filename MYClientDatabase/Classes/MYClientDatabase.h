//
//  MYClientDatabase.h
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//

#import <Foundation/Foundation.h>
#import "MYDBUser.h"
#import "MYDataMessage.h"
#import "MYChatUserManager.h"


#define theDatabase MYClientDatabase.database

NS_ASSUME_NONNULL_BEGIN

@interface MYClientDatabase : NSObject

+ (instancetype)database;

/// 获取该用户所有的聊天人
- (NSArray<MYDBUser *> *)getAllChatPersonWithUserId:(long long)userId;

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId;

- (void)addChatMessage:(MYDataMessage *)message;

@end

NS_ASSUME_NONNULL_END

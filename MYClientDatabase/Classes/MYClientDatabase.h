//
//  MYClientDatabase.h
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//

#import <Foundation/Foundation.h>
#import "MYDataChatPerson.h"
#import "MYDataMessage.h"
#import "MYChatPersonManager.h"


#define theDatabase MYClientDatabase.database

NS_ASSUME_NONNULL_BEGIN

@interface MYClientDatabase : NSObject

+ (instancetype)database;

/// 获取该用户所有的聊天人
- (NSArray<MYDataChatPerson *> *)getAllChatPersonWithUserId:(long long)userId;

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId;

@end

NS_ASSUME_NONNULL_END

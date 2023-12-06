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



@end

@interface MYClientDatabase (MYDBMessage)

- (BOOL)addChatMessage:(MYDataMessage *)message fromUserId:(long long)userId belongToUserId:(long long)ownerUserId;
- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId belongToUserId:(long long)owneruserId;
@end

@interface MYClientDatabase (MYDBUser)
/// 获取该用户userId所有的聊天人
- (NSArray<MYDBUser *> *)getAllChatPersonWithUserId:(long long)userId;

/// 获取正在聊天的人
- (NSArray<MYDBUser *> *)getChatListWithUserId:(long long)userId;

/// 更新指定用户的通讯录信息
/// - Parameters:
///   - users: 用户信息
///   - userId: userId
- (void)updateAllUser:(NSArray<MYDBUser *> *)users fromUid:(long long)userId;

/// 获取某个用户的用户信息
/// - Parameter userId: userId
- (MYDBUser *)getChatPersonWithUserId:(long long)userId;

- (void)setUserInChat:(MYDBUser *)user withOwnerUserId:(long long)userId;

@end



NS_ASSUME_NONNULL_END

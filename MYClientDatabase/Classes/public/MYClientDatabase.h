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

FOUNDATION_EXPORT NSString * const MESSAGE_SEND_SUCCESS_NOTIFICATION;
#define theDatabase MYClientDatabase.database

NS_ASSUME_NONNULL_BEGIN

@interface MYClientDatabase : NSObject

+ (instancetype)database;

/// 登录后创建和重置数据库
- (void)setupWithUid:(long long)uid;

- (void)resetCaches;

@end

@interface MYClientDatabase (MYDBMessage)

- (BOOL)addChatMessage:(MYDataMessage *)message withUserId:(long long)userId;

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId;

- (BOOL)sendSuccessWithTimer:(NSTimeInterval)timer messageId:(long long)messageId withUserId:(long long)fromId;

/// 获取针对userId聊天的消息未读数量
/// - Parameters:
///   - userId: 聊天用户
///   - owneruserId: userId
- (int)getNotReadNumberWithUserId:(long long)userId;

/// 当前用户所有的聊天未读数量
/// - Parameter ownerUserId: userId
- (int)getNotReadNumbers;


- (NSTimeInterval)getLastestTimestamp;

/// 获取当前userId聊天下的最新消息
/// - Parameters:
///   - userId: 聊天的用户Id
///   - owneruserId: 归属userId
- (NSString *)lastestContentWithUserId:(long long)userId;

- (void)messageSendFailureInMessage:(MYDataMessage *)message;

/// 标记消息已读
/// - Parameters:
///   - message: 已读消息体
///   - userId: 用户id
///   - owneruserId: 归属userId
- (void)setReadedMessageWithMessage:(MYDataMessage *)message withUserId:(long long)userId;

- (BOOL)setReadedWithTimestamp:(NSTimeInterval)timestamp userId:(long long)userId;
/// 获取消息
/// - Parameters:
///   - userId: 用户id
///   - owneruserId: userId
- (MYDataMessage *)messageWithTimestamp:(NSTimeInterval)timestamp userId:(long long)userId;

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

- (void)setUserInChat:(MYDBUser *)user;

@end


NS_ASSUME_NONNULL_END

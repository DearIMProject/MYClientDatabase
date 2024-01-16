//
//  MYChatMessageManager.h
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/23.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "MYDataMessage.h"

NS_ASSUME_NONNULL_BEGIN

#define theChatMessageManager MYChatMessageManager.shared

@interface MYChatMessageManager : NSObject

@property (nonatomic, strong) FMDatabase *database;/**< 数据库  */

+ (instancetype)shared;
// userId 对话的人
// ownerUserId 该对话的拥有者


/// 获取当前用户userId与用户personUserId的对话
/// - Parameters:
///   - personuserId: 对话的用户
///   - userId: 当前用户
- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)personUserId belongToUserId:(long long)userId;

/// 当前用户userId向用户personUserId添加一条消息
/// - Parameters:
///   - message: 消息体
///   - personUserId: 当前聊天的人
///   - userId: 当前用户
- (BOOL)addMessage:(MYDataMessage *)message withUserId:(long long)personUserId belongToUserId:(long long)userId;

/// 发送的消息成功送达
/// - Parameters:
///   - messageId: 消息Id
///   - timestamp: 消息时间戳
///   - personUserId: 对话的用户
///   - userId: 当前用户
- (BOOL)updateMessageWithSendSuccess:(NSTimeInterval)timestamp
                           messageId:(long long)messageId
                          withUserId:(long long)userId
                      belongToUserId:(long long)owneruserId;


/// 获取当前聊天下未读消息
/// - Parameters:
///   - userId: 当前聊天的用户
///   - owneruserId: 当前用户
- (int)getNotReadNumberWithUserId:(long long)userId
                   belongToUserId:(long long)owneruserId;

- (int)getNotReadNumberBelongToUserId:(long long)owneruserId;

/// 添加一个已读用户到信息中
/// - Parameters:
///   - userId: 已读用户id
///   - messageId: 信息id
///   - owneruserId: 当前用户
- (BOOL)addReadUserId:(long long)userId
        withMessageId:(long long)messageId
       belongToUserId:(long long)owneruserId;

/// 获取最新的时间戳
- (NSTimeInterval)getLastestTimestampBelongToUserId:(long long)owneruserId;

/// 获取当前用户消息的最新消息内容
- (NSString *)lastestContentWithUserId:(long long)userId belongToUserId:(long long)owneruserId;

- (void)messageSendFailureInMessage:(MYDataMessage *)message;

@end

NS_ASSUME_NONNULL_END

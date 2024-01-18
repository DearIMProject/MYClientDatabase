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


/// 当前用户userId向用户personUserId添加一条消息
/// - Parameters:
///   - message: 消息体
///   - personUserId: 当前聊天的人
///   - userId: 当前用户
- (BOOL)addMessage:(MYDataMessage *)message withUserId:(long long)personUserId belongToUserId:(long long)userId;



- (int)getNotReadNumberWithUserId:(long long)userId
                   belongToUserId:(long long)owneruserId;


/// 添加一个已读用户到信息中
/// - Parameters:
///   - userId: 已读用户id
///   - messageId: 信息id
///   - owneruserId: 当前用户
- (BOOL)addReadUserId:(long long)userId
        withMessageId:(long long)messageId
       belongToUserId:(long long)owneruserId;



@end

NS_ASSUME_NONNULL_END

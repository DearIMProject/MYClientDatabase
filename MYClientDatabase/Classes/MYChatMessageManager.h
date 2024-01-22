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
- (void)resetCaches;


/// 当前用户userId向用户personUserId添加一条消息
/// - Parameters:
///   - message: 消息体
///   - personUserId: 当前聊天的人
///   - userId: 当前用户
- (BOOL)addMessage:(MYDataMessage *)message withUserId:(long long)personUserId ;



- (int)getNotReadNumberWithUserId:(long long)userId;
                   


/// 添加一个已读用户到信息中
/// - Parameters:
///   - userId: 已读用户id
///   - messageId: 信息id
- (BOOL)addReadUserId:(long long)userId
        withMessageId:(long long)messageId;



@end

NS_ASSUME_NONNULL_END

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
- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId belongToUserId:(long long)userId;

- (BOOL)addMessage:(MYDataMessage *)message fromUserId:(long long)userId belongToUserId:(long long)userId;

- (BOOL)updateMessageWithSendSuccess:(NSTimeInterval)timestamp fromUserId:(long long)userId belongToUserId:(long long)userId;

@end

NS_ASSUME_NONNULL_END

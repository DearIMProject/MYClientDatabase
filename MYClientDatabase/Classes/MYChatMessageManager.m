//
//  MYChatMessageManager.m
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/23.
//

#import "MYChatMessageManager.h"

@implementation MYChatMessageManager

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId {
    NSMutableArray<MYDataMessage *> *chatMessages = [NSMutableArray array];
    if (!self.database.isOpen) {
        return chatMessages;
    }
    NSString *sql = @"select msgId,fromEntity,fromId,toId,toEntity messageType,content,sendSuccess,timestamp from tb_message where affUserId = ?";
    FMResultSet *resultSet = [self.database executeQuery:sql, @(userId)];
    while (resultSet.next) {
        MYDataMessage *message = [[MYDataMessage alloc] init];
        message.msgId = [resultSet longLongIntForColumn:@"msgId"];
        message.fromEntity = [resultSet intForColumn:@"fromEntity"];
        message.fromId = [resultSet longLongIntForColumn:@"fromId"];
        message.toEntity = [resultSet intForColumn:@"toEntity"];
        message.toId = [resultSet longLongIntForColumn:@"toId"];
        message.messageType = [resultSet intForColumn:@"messageType"];
        message.content = [resultSet stringForColumn:@"content"];
        message.sendSuccess = [resultSet boolForColumn:@"sendSuccess"];
        [chatMessages addObject:message];
    }
    return chatMessages;
}

@end

//
//  MYChatMessageManager.m
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/23.
//

#import "MYChatMessageManager.h"
#import <MYUtils/MYUtils.h>

NSString *kMessageTable = @"tb_message";
NSString *kMessageId = @"msgId";
NSString *kFromEntity = @"fromEntity";
NSString *kFromId = @"fromId";
NSString *kToId = @"toId";
NSString *kToEntity = @"toEntity";
NSString *kMessageType = @"messageType";
NSString *kContent = @"content";
NSString *kTimestamp = @"timestamp";
NSString *kAffMessageUserId = @"affUserId";
NSString *kSendStatus = @"sendStatus";

@interface MYChatMessageManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *,NSMutableArray<MYDataMessage *> *> *userMsgsMap;

@end

@implementation MYChatMessageManager
//TODO: wmy 本地缓存，在一定时候需要同步到数据库，同步数据库的时候需要放到线程中添加

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userMsgsMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId belongToUserId:(long long)owneruserId {
    NSMutableArray<MYDataMessage *> *messages = self.userMsgsMap[@(userId)];
    if (!messages.count) {
        messages = [self getDataChatMessagesWithPerson:userId ownerUserId:owneruserId];
        self.userMsgsMap[@(userId)] = [NSMutableArray arrayWithArray:messages];
    }
    return messages;
}

- (NSArray<MYDataMessage *> *)getDataChatMessagesWithPerson:(long long)userId ownerUserId:(long long)ownerUserId{
    NSMutableArray<MYDataMessage *> *chatMessages = [NSMutableArray array];
    if (!self.database.isOpen) {
        return chatMessages;
    }
    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@,%@"
                     " from %@"
                     " where %@ = ? and ( %@ = ? or %@ = ? )",
                     kMessageId,kFromEntity,kFromId,kToId,kToEntity,kMessageType,kContent,kSendStatus,kTimestamp,
                     kMessageTable,
                     kAffMessageUserId,kFromId,kToId];
    [MYLog debug:sql];
    FMResultSet *resultSet = [self.database executeQuery:sql, @(ownerUserId),@(userId),@(userId)];
    while (resultSet.next) {
        MYDataMessage *message = [[MYDataMessage alloc] init];
        message.msgId = [resultSet longLongIntForColumn:kMessageId];
        message.fromEntity = [resultSet intForColumn:kFromEntity];
        message.fromId = [resultSet longLongIntForColumn:kFromId];
        message.toEntity = [resultSet intForColumn:kToEntity];
        message.toId = [resultSet longLongIntForColumn:kToId];
        message.messageType = [resultSet intForColumn:kMessageType];
        message.content = [resultSet stringForColumn:kContent];
        message.sendStatus = [resultSet intForColumn:kSendStatus];
        [chatMessages addObject:message];
    }
    return chatMessages;
}

- (BOOL)addMessage:(MYDataMessage *)message fromUserId:(long long)userId belongToUserId:(long long)ownerUserId{
    NSMutableArray<MYDataMessage *> *messages = self.userMsgsMap[@(userId)];
    if (!messages.count) {
        NSArray *innerMessages = [self getDataChatMessagesWithPerson:userId ownerUserId:ownerUserId];
        messages = [NSMutableArray arrayWithArray:innerMessages];
        self.userMsgsMap[@(userId)] = messages;
        
    }
    [messages addObject:message];
    return [self addDataMessage:message fromUserId:userId belongToUserId:ownerUserId];
}

- (BOOL)addDataMessage:(MYDataMessage *)message fromUserId:(long long)userId belongToUserId:(long long)ownerUserId{
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@)"
                     " values(?,?,?,?,?,?,?,?,?)",
                     kMessageTable,
                     kFromEntity,
                     kFromId,
                     kToId,
                     kToEntity,
                     kMessageType,
                     kContent,
                     kSendStatus,
                     kTimestamp,
                     kAffMessageUserId];
    [MYLog debug:sql];
    BOOL success = [self.database executeUpdate:sql,@(message.fromEntity),@(message.fromId),@(message.toId),@(message.toEntity),
    @(message.messageType),message.content,@(message.sendStatus),@(message.timestamp),@(ownerUserId)];
    return success;
}

- (BOOL)updateMessageWithSendSuccess:(NSTimeInterval)timestamp fromUserId:(long long)userId belongToUserId:(long long)owneruserId{
    NSMutableArray<MYDataMessage *> *messages = self.userMsgsMap[@(userId)];
    if (!messages.count) {
        NSArray *innerMessages = [self getDataChatMessagesWithPerson:userId ownerUserId:owneruserId];
        messages = [NSMutableArray arrayWithArray:innerMessages];
        self.userMsgsMap[@(userId)] = messages;
    }
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *message;
    while (message = [reverseEnumerator nextObject]) {
        if (message.timestamp == timestamp) {
            message.sendStatus = MYDataMessageStatus_Success;
            break;
        }
    }
}

@end

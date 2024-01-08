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
NSString *kReadList = @"readList";

//TODO: wmy 所有数据库的操作，均拉一个新的线程

@interface MYChatMessageManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *,NSMutableArray<MYDataMessage *> *> *userMsgsMap;

@end

@implementation MYChatMessageManager
//TODO: wmy 本地缓存，在一定时候需要同步到数据库，同步数据库的时候需要放到线程中添加

#pragma mark - dealloc
#pragma mark - life cycle

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
        // 如果当前用户的消息为空，就到数据库中获取，并存于内存中
        messages = [self _getDataChatMessagesWithPerson:userId ownerUserId:owneruserId];
        self.userMsgsMap[@(userId)] = [NSMutableArray arrayWithArray:messages];
    }
    return messages;
}

/// 数据库中获取消息
- (NSArray<MYDataMessage *> *)_getDataChatMessagesWithPerson:(long long)userId ownerUserId:(long long)ownerUserId{
    NSMutableArray<MYDataMessage *> *chatMessages = [NSMutableArray array];
    if (!self.database.isOpen) {
        return chatMessages;
    }
    [MYLog debug:@"📚查询当前%lld 和 %lld 的消息列表",userId,ownerUserId];
    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@,%@"
                     " from %@"
                     " where %@ = ? and"
                     "( %@=? and %@ = ? or %@ = ? and %@ = ? ) ",
                     kMessageId,kFromEntity,kFromId,kToId,kToEntity,kMessageType,kContent,kSendStatus,kTimestamp,
                     kMessageTable,
                     kAffMessageUserId,
                     kFromId,kToId,kFromId,kToId];
    [MYLog debug:@"📚sql = %@",sql];
    FMResultSet *resultSet = [self.database executeQuery:sql, @(ownerUserId),@(userId),@(ownerUserId),@(ownerUserId),@(userId)];
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

- (BOOL)addMessage:(MYDataMessage *)message withUserId:(long long)userId belongToUserId:(long long)ownerUserId{
    NSMutableArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId belongToUserId:ownerUserId];
    //TODO: wmy 对于自己发给自己的消息，需要做一个去重
    if (userId == ownerUserId) {
        NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
        MYDataMessage *findMessage;
        while (findMessage = [reverseEnumerator nextObject]) {
            if (findMessage.timestamp == message.timestamp) {
                NSLog(@"📚找到自己发给自己的消息中有一个相同的信息，因此不做处理");
                return YES;
            }
        }
    }
    // 内存中添加一个消息
    [messages addObject:message];
    [MYLog debug:@"📚内存中添加一个message = %@",message];
    self.userMsgsMap[@(userId)] = messages;
    return [self _addDataMessage:message belongToUserId:ownerUserId];
}

- (BOOL)_addDataMessage:(MYDataMessage *)message belongToUserId:(long long)ownerUserId{
    
    
    [self.database beginTransaction];
    BOOL success = false;
    @try {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@)"
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
        [MYLog debug:@"📚sql = %@",sql];
        success = [self.database executeUpdate:sql,@(message.fromEntity),@(message.fromId),@(message.toId),@(message.toEntity),
                   @(message.messageType),message.content,@(message.sendStatus),@(message.timestamp),@(ownerUserId)];
        [MYLog debug:@"📚数据库中添加一个message = %@,是否添加成功 %d",message,success];
        
    } @catch (NSException *exception) {
        [self.database rollback];
        NSLog(@"exception = %@",exception);
    } @finally {
        if (success) {
            [self.database commit];
        }
        return success;
    }
}

- (BOOL)updateMessageWithSendSuccess:(NSTimeInterval)timestamp
                           messageId:(long long)messageId
                          withUserId:(long long)userId
                      belongToUserId:(long long)owneruserId {
    [MYLog debug:@"📚更新消息成功标识"];
    NSMutableArray<MYDataMessage *> *messages =  [self getChatMessageWithPerson:userId belongToUserId:owneruserId];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *message;
    while (message = [reverseEnumerator nextObject]) {
        if (message.timestamp == timestamp) {
            message.sendStatus = MYDataMessageStatus_Success;
            message.msgId = messageId;
            [MYLog debug:@"📚更新内存消息成功标识"];
            return [self _updateDataMessageWithSuccess:message];
        }
    }
    return NO;
}

- (BOOL)_updateDataMessageWithSuccess:(MYDataMessage *)message {
    [self.database beginTransaction];
    BOOL success = false;
    @try {
        NSString *sql = [NSString stringWithFormat:@"update %@ set "
                         "%@ = ?,"
                         "%@ = ? "
                         "where %@ = ?"
                         ,
                         kMessageTable,
                         kSendStatus,
                         kMessageId,
                         kTimestamp
        ];
        [MYLog debug:@"📚sql = %@",sql];
        success = [self.database executeUpdate:sql,@(message.sendStatus),@(message.msgId),@(message.timestamp)];
        [MYLog debug:@"📚更新数据消息成功标识,%d",success];
    } @catch (NSException *exception) {
        [self.database rollback];
        NSLog(@"exception = %@",exception);
    } @finally {
        if (success) {
            [self.database commit];
        }
        return success;
    }
}

- (int)getNotReadNumberWithUserId:(long long)userId
                   belongToUserId:(long long)owneruserId {
    int notReadList = 0;
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId belongToUserId:owneruserId];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *message;
    while (message = [reverseEnumerator nextObject]) {
        if (!message.readList.length ||
            [message.readList containsString:[NSString stringWithFormat:@"%lld",userId]]) {
            notReadList ++;
        }
    }
    return notReadList;
}

- (BOOL)addReadUserId:(long long)userId withMessageId:(long long)messageId belongToUserId:(long long)owneruserId {
    //TODO: wmy
    NSMutableString *string = [NSMutableString string];
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId belongToUserId:owneruserId];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *message;
    while (message = [reverseEnumerator nextObject]) {
        if (message.msgId == messageId) {
            [string appendString:message.readList];
            [string appendFormat:@",%lld",userId];
            message.readList = string;
            break;
        }
    }
    return [self _addReadUserId:userId withMessage:message readList:string];
}

- (BOOL)_addReadUserId:(long long)userId withMessage:(MYDataMessage *)message readList:(NSString *)readList {
    //TODO: wmy
    [self.database beginTransaction];
    BOOL success = false;
    @try {
        NSString *sql = [NSString stringWithFormat:@"update %@ set "
                         "%@ = ? "
                         "where %@ = ?"
                         ,
                         kMessageTable,
                         kSendStatus,
                         kMessageId
        ];
        [MYLog debug:@"📚sql = %@",sql];
        success = [self.database executeUpdate:sql,@(message.sendStatus),@(message.msgId)];
        [MYLog debug:@"📚更新数据消息成功标识,%d",success];
    } @catch (NSException *exception) {
        [self.database rollback];
        NSLog(@"exception = %@",exception);
    } @finally {
        if (success) {
            [self.database commit];
        }
        return success;
    }
    return NO;
}


@end
 

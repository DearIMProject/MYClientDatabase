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
NSString *kSendStatus = @"sendStatus";
NSString *kReadList = @"readList";

//TODO: wmy 所有数据库的操作，均拉一个新的线程
//TODO: wmy 在启动App后需要先从数据库中拉取一次所有的消息

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

- (void)resetCaches {
    [self.userMsgsMap removeAllObjects];
}

/// 获取当前用户userId与用户personUserId的对话
/// - Parameters:
///   - personuserId: 对话的用户
///   - userId: 当前用户
- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId {
    NSMutableArray<MYDataMessage *> *messages = self.userMsgsMap[@(userId)];
    if (!messages.count) {
        // 如果当前用户的消息为空，就到数据库中获取，并存于内存中
        messages = [self _getDataChatMessagesWithPerson:userId];
        self.userMsgsMap[@(userId)] = [NSMutableArray arrayWithArray:messages];
    }
    return messages;
}

/// 数据库中获取消息 
- (NSArray<MYDataMessage *> *)_getDataChatMessagesWithPerson:(long long)userId {
    NSMutableArray<MYDataMessage *> *chatMessages = [NSMutableArray array];
    if (!self.database.isOpen) {
        return chatMessages;
    }
    [MYLog debug:@"📚查询当前%lld 和 %lld 的消息列表",userId];
    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@,%@,%@"
                     " from %@"
                     " where %@ <> ? and "
                     "(( %@=?) or( %@ = ? ));",
                     kMessageId,kFromEntity,kFromId,kToId,kToEntity,kMessageType,kContent,kSendStatus,kTimestamp,kReadList,
                     kMessageTable,
                     kMessageType,
                     kFromId,kToId];
    [MYLog debug:@"📚sql = %@",sql];
    FMResultSet *resultSet = [self.database executeQuery:sql,
                              @(8),
                              @(userId),@(userId)];
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
        message.timestamp = [resultSet doubleForColumn:kTimestamp];
        message.readList = [resultSet stringForColumn:kReadList];
        [chatMessages addObject:message];
    }
    return chatMessages;
}
// userId 是fromId
- (BOOL)addMessage:(MYDataMessage *)message withUserId:(long long)userId {
    NSMutableArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId];
    // 对于自己发给自己的消息，需要做一个去重
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *findMessage;
    while (findMessage = [reverseEnumerator nextObject]) {
        if (findMessage.timestamp == message.timestamp) {
            NSLog(@"📚找到自己发给自己的消息中有一个相同的信息，因此不做处理");
            return YES;
        }
    }
    
    // 内存中添加一个消息
    [messages addObject:message];
    [MYLog debug:@"📚内存中添加一个message = %@",message];
    self.userMsgsMap[@(userId)] = messages;
    return [self _addDataMessage:message];
}

- (BOOL)_addDataMessage:(MYDataMessage *)message {
    [self.database beginTransaction];
    BOOL success = false;
    @try {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@,%@)"
                         " values(?,?,?,?,?,?,?,?)",
                         kMessageTable,
                         kFromEntity,
                         kFromId,
                         kToId,
                         kToEntity,
                         kMessageType,
                         kContent,
                         kSendStatus,
                         kTimestamp
                         ];
        [MYLog debug:@"📚sql = %@",sql];
        success = [self.database executeUpdate:sql,@(message.fromEntity),@(message.fromId),@(message.toId),@(message.toEntity),
                   @(message.messageType),message.content,@(message.sendStatus),@(message.timestamp)];
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

/// 发送的消息成功送达
/// - Parameters:
///   - messageId: 消息Id
///   - timestamp: 消息时间戳
///   - personUserId: 对话的用户
///   - userId: 当前用户
- (BOOL)sendSuccessWithTimer:(NSTimeInterval)timestamp messageId:(long long)messageId withUserId:(long long)fromId {
    [MYLog debug:@"📚更新消息成功标识"];
    NSMutableArray<MYDataMessage *> *messages =  [self getChatMessageWithPerson:fromId];
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
/// 获取当前聊天下未读消息
/// - Parameters:
///   - userId: 当前聊天的用户
///   - owneruserId: 当前用户
- (int)getNotReadNumberWithUserId:(long long)userId {
    int notReadList = 0;
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *message;
    while (message = [reverseEnumerator nextObject]) {
        if (!message.readList.length ||
            [message.readList containsString:[NSString stringWithFormat:@"%lld",message.toId]]) {
            ;;
        } else {
            notReadList ++;
        }
    }
    return notReadList;
}

- (int)getNotReadNumbers {
    int count = 0;
    for (NSNumber *uidNumber in self.userMsgsMap.allKeys) {
        count += [self getNotReadNumberWithUserId:uidNumber.longLongValue];
    }
    return count;
}

- (BOOL)addReadUserId:(long long)userId withMessageId:(long long)messageId {
    //TODO: wmy
    NSMutableString *string = [NSMutableString string];
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId];
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
    [self.database beginTransaction];
    BOOL success = false;
    @try {
        NSString *sql = [NSString stringWithFormat:@"update %@ set "
                         "%@ = ? ,"
                         "%@ = ? "
                         "where %@ = ?"
                         ,
                         kMessageTable,
                         kSendStatus,
                         kReadList,
                         kMessageId
        ];
        [MYLog debug:@"📚sql = %@",sql];
        success = [self.database executeUpdate:sql,@(message.sendStatus),message.readList?:@"",@(message.msgId)];
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
/// 获取最新的时间戳
- (NSTimeInterval)getLastestTimestamp {
    NSString *sql = [NSString stringWithFormat:@"select MAX(%@) from %@ "
                     ,
                     kTimestamp,
                     kMessageTable
    ];
    [MYLog debug:@"📚sql = %@",sql];
    FMResultSet *resultSet = [self.database executeQuery:sql];
    if (resultSet.next) {
        NSTimeInterval timestamp = [resultSet longLongIntForColumn:[NSString stringWithFormat:@"max(%@)",kTimestamp]];
        return timestamp;
    }
    return 0;
}
/// 获取当前用户消息的最新消息内容
- (NSString *)lastestContentWithUserId:(long long)userId  {
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId];
    return messages.lastObject.content;
}

- (void)messageSendFailureInMessage:(MYDataMessage *)message {
    NSArray<MYDataMessage *> *messages = self.userMsgsMap[@(message.toId)];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *aMessage;
    while (aMessage = [reverseEnumerator nextObject]) {
        if (message.timestamp == aMessage.timestamp) {
            aMessage.sendStatus = MYDataMessageStatus_Failure;
            [self _addReadUserId:aMessage.toId withMessage:aMessage readList:nil];
            break;
        }
    }
}

/// 标记消息为已读
/// - Parameters:
///   - timestamp: 已读消息体
///   - userId: 用户id
///   - owneruserId: 归属用户
- (void)setReadedMessageWithMessage:(MYDataMessage *)message withUserId:(long long)userId {
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *aMessage;
    while (aMessage = [reverseEnumerator nextObject]) {
        if (message.content.doubleValue == aMessage.timestamp) {
            long long mUserId = aMessage.toId;
            aMessage.readList = [NSString stringWithFormat:@"%lld",mUserId];
            [self _addReadUserId:aMessage.toId withMessage:aMessage readList:aMessage.readList];
            [self _addDataMessage:message];
            break;
        }
    }
}

/// 设置已读
/// - Parameters:
///   - timestamp: 时间戳
///   - userId: 相关userId
///   - owneruserId: 归属userId
- (BOOL)setReadedWithTimestamp:(NSTimeInterval)timestamp userId:(long long)userId {
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *aMessage;
    while (aMessage = [reverseEnumerator nextObject]) {
        if (timestamp == aMessage.timestamp) {
            long long mUserId = aMessage.toId;
            if ([aMessage.readList containsString:[NSString stringWithFormat:@",%lld",mUserId]] ||
                [aMessage.readList containsString:[NSString stringWithFormat:@",%lld,",mUserId]] ||
                [aMessage.readList containsString:[NSString stringWithFormat:@",%lld,",mUserId]]) {
                // 如果已经包含了则怎么都不做
                return YES;
            } else {
                NSMutableString *string = [NSMutableString string];
                [string appendString:aMessage.readList];
                if (string.length) {
                    [string appendFormat:[NSString stringWithFormat:@",%lld",mUserId]];
                } else {
                    [string appendFormat:[NSString stringWithFormat:@"%lld",mUserId]];
                }
                return [self _addReadUserId:mUserId withMessage:aMessage readList:string];
            }
            break;

        }
    }
    return NO;
}

- (MYDataMessage *)messageWithTimestamp:(NSTimeInterval)timestamp userId:(long long)userId {
    NSArray<MYDataMessage *> *messages = [self getChatMessageWithPerson:userId];
    NSEnumerator *reverseEnumerator = messages.reverseObjectEnumerator;
    MYDataMessage *aMessage;
    while (aMessage = [reverseEnumerator nextObject]) {
        if (timestamp == aMessage.timestamp) {
            return aMessage;
        }
    }
    return nil;
}
@end
 

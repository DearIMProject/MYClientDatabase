//
//  MYClientDatabase.m
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//

#import "MYClientDatabase.h"
#import "MYChatPersonManager.h"
#import <fmdb/FMDB.h>

NSString *kDatabaseName = @"database.sqlite";

@interface MYClientDatabase ()

@property(nonatomic, assign) BOOL openSuccess;
@property(nonatomic, strong) FMDatabase *database;

@end

@implementation MYClientDatabase

+ (instancetype)database {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self removeDatabaseFile];
        [self copyDatabaseToHomeDirectory];
        [self openSqlDataBase];
    }
    return self;
}

#pragma mark - ChatPerson

- (NSArray<MYDataChatPerson *> *)getAllChatPersonWithUserId:(long long)userId {
    NSArray<MYDataChatPerson *> *chatPersons = theChatPersonManager.cacheChatPersons;
    if (!chatPersons.count) {
        return [self dataGetAllChatPersonWithUserId:userId];
    }
    return chatPersons;
}

- (NSArray<MYDataChatPerson *> *)dataGetAllChatPersonWithUserId:(long long)userId {
    NSMutableArray<MYDataChatPerson *> *chatPersons = [NSMutableArray array];
    if (!self.database.isOpen) {
        return chatPersons;
    }
    NSString *sql = @"select userId,username,icon,affUserId from tb_user where affUserId = ?";
    FMResultSet *resultSet = [self.database executeQuery:sql, @(userId)];
    while (resultSet.next) {
        MYDataChatPerson *person = [[MYDataChatPerson alloc] init];
        person.userId = [resultSet longLongIntForColumn:@"userId"];
        person.name = [resultSet stringForColumn:@"username"];
        person.iconURL = [resultSet stringForColumn:@"icon"];
        person.affUserId = [resultSet longLongIntForColumn:@"affUserId"];
        person.iconURL = [resultSet stringForColumn:@"icon"];
        [chatPersons addObject:person];
    }
    [theChatPersonManager resetChatPersons:chatPersons];
    return chatPersons;
}


- (void)removeDatabaseFile {
    NSString *dstPath = [self docDBFilePath];
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:dstPath];
    if (isFileExist) {
        NSError *error;
        [NSFileManager.defaultManager removeItemAtPath:dstPath error:&error];
        NSLog(@"error = %@", error);
    }

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

- (NSString *)docDBFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [path objectAtIndex:0];
    NSString *dstPath = [docDirectory stringByAppendingPathComponent:kDatabaseName];
    return dstPath;
}

- (void)copyDatabaseToHomeDirectory {
    //TODO: wmy 将sqlite放到home目录下
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:[NSString stringWithFormat:@"MYClientDatabase.bundle/%@", kDatabaseName] ofType:nil];
    NSString *dstPath = [self docDBFilePath];
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:dstPath];
    if (!isFileExist) {
        NSLog(@"dstPath = %@", dstPath);
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:dstPath error:&error];
        NSLog(@"error = %@", error);
    }

}

// 打开数据库
- (void)openSqlDataBase {
    // _db是数据库的句柄,即数据库的象征,如果对数据库进行增删改查,就得操作这个示例

    // 获取数据库文件的路径
    NSString *docPath = [self docDBFilePath];
    self.database = [FMDatabase databaseWithPath:docPath];
    if (!self.database.isOpen) {
        self.openSuccess = self.database.open;
        NSLog(@"数据库打开成功");
    }
}

@end

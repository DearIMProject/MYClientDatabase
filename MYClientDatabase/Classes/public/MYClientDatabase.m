//
//  MYClientDatabase.m
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//

#import "MYClientDatabase.h"
#import "MYChatUserManager.h"
#import <fmdb/FMDB.h>
#import "MYChatMessageManager.h"

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
- (void)updateAllUser:(NSArray<MYDBUser *> *)users fromUid:(long long)userId {
    //TODO: wmy
    [theChatUserManager updateChatPersons:users fromUserId:userId];
}
- (NSArray<MYDBUser *> *)getAllChatPersonWithUserId:(long long)userId {
    NSArray<MYDBUser *> *chatPersons = theChatUserManager.cacheChatPersons;
    if (!chatPersons.count) {
        return [self dataGetAllChatPersonWithUserId:userId];
    }
    return chatPersons;
}

- (NSArray<MYDBUser *> *)dataGetAllChatPersonWithUserId:(long long)userId {
    return [theChatUserManager dataGetAllChatPersonWithUserId:userId];
}

- (MYDBUser *)getChatPersonWithUserId:(long long)userId {
    return [theChatUserManager chatPersonWithUserId:userId];
}

#pragma mark - message

- (void)addChatMessage:(MYDataMessage *)message {
    //TODO: wmy 
}

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId {
    return [theChatMessageManager getChatMessageWithPerson:userId];
}

#pragma mark - file

- (void)removeDatabaseFile {
    NSString *dstPath = [self docDBFilePath];
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:dstPath];
    if (isFileExist) {
        NSError *error;
        [NSFileManager.defaultManager removeItemAtPath:dstPath error:&error];
        NSLog(@"error = %@", error);
    }
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
    theChatMessageManager.database = self.database;
    theChatUserManager.database = self.database;
    if (!self.database.isOpen) {
        self.openSuccess = self.database.open;
        NSLog(@"😄数据库打开成功");
    }
}

@end

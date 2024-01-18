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

NSString * const MESSAGE_SEND_SUCCESS_NOTIFICATION = @"kMessageSendSuccess";

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
//        TODO: wmy 测试，每次启动都删除原始文件
//        [self removeDatabaseFile];
        [self copyDatabaseToHomeDirectory];
        [self openSqlDataBase];
    }
    return self;
}



#pragma mark - ChatPerson

- (MYDBUser *)getChatPersonWithUserId:(long long)userId {
    return [theChatUserManager chatPersonWithUserId:userId];
}

- (void)setUserInChat:(MYDBUser *)user withOwnerUserId:(long long)userId {
    [theChatUserManager updateUser:user inChat:YES belongUserId:userId];
}

#pragma mark - message

- (BOOL)addChatMessage:(MYDataMessage *)message withUserId:(long long)userId belongToUserId:(long long)ownerUserId{
    [theChatUserManager updateUser:[theChatUserManager chatPersonWithUserId:userId] inChat:YES belongUserId:ownerUserId];
    BOOL success = [theChatMessageManager addMessage:message withUserId:userId belongToUserId:ownerUserId];
    if (success) {
        [NSNotificationCenter.defaultCenter postNotificationName:MESSAGE_SEND_SUCCESS_NOTIFICATION object:nil userInfo:@{@"message":message}];
    }
    return success;
}

#pragma mark - Forward
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([theChatUserManager respondsToSelector:aSelector]) {
        return theChatUserManager;
    }
    if ([theChatMessageManager respondsToSelector:aSelector]) {
        return theChatMessageManager;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [theChatUserManager respondsToSelector:aSelector] ||
    [theChatMessageManager respondsToSelector:aSelector] ||
    [super respondsToSelector:aSelector];
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

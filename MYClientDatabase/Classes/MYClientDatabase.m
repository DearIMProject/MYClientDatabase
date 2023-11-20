//
//  MYClientDatabase.m
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//

#import "MYClientDatabase.h"
#import <fmdb/FMDB.h>

NSString *kDatabaseName = @"database.sqlite";

@interface MYClientDatabase ()

@property (nonatomic, assign) BOOL openSuccess;
@property (nonatomic, strong) FMDatabase *database;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self copyDatabaseToHomeDirectory];
        [self openSqlDataBase];
    }
    return self;
}

- (NSArray<MYDataChatPerson *> *)getAllChatPersonWithUserId:(long long)userId {
    FMResultSet *resultSet = [self.database executeQuery:@"SELECT userId,username,icon FROM tb_user where affUserId=?",userId];
    //TODO: wmy
    NSMutableArray<MYDataChatPerson *> *chatPersons = [NSMutableArray array];
    while (resultSet.next) {
        MYDataChatPerson *person = [[MYDataChatPerson alloc] init];
        person.userId = [resultSet intForColumn:@"userId"];
        person.name = [resultSet stringForColumn:@"username"];
        person.iconURL = [resultSet stringForColumn:@"icon"];
    }
    return chatPersons;
}

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId {
    return nil;
}

- (NSString *)docDBFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [path objectAtIndex:0];
    NSString *dstPath = [docDirectory stringByAppendingPathComponent:kDatabaseName];
    return dstPath;
}

- (void)copyDatabaseToHomeDirectory {
    //TODO: wmy 将sqlite放到home目录下
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kDatabaseName ofType:nil];
    NSString *dstPath = [self docDBFilePath];
    NSLog(@"dstPath = %@",dstPath);
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:dstPath error:&error];
    NSLog(@"");
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

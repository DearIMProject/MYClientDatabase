//
//  MYClientDatabase.m
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//

#import "MYClientDatabase.h"
#import <sqlite3.h>

NSString *kDatabaseName = @"database.sqlite";

@implementation MYClientDatabase {
    sqlite3 *_db;
}

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
    
    //TODO: wmy
    return nil;
}

- (NSArray<MYDataMessage *> *)getChatMessageWithPerson:(long long)userId {
    return nil;
}

- (void)copyDatabaseToHomeDirectory {
    //TODO: wmy 将sqlite放到home目录下
//    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@"MYClientDatabase" withExtension:@"bundle"];
//    NSBundle *resourceBundle = [NSBundle bundleWithURL:url];
//    NSString *path = [resourceBundle pathForResource:kDatabaseName ofType:nil];
    NSLog(@"path");
    UIImage *image = [UIImage imageNamed:@"MYClientDatabase.bundle/DCIM_1657090588"];
    NSLog(@"");
}

// 打开数据库
- (void)openSqlDataBase {
    // _db是数据库的句柄,即数据库的象征,如果对数据库进行增删改查,就得操作这个示例
    
    // 获取数据库文件的路径
//    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *docPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"MYClientDatabase.bundle/%@",kDatabaseName] ofType:nil];
    
    NSString *fileName = docPath;
    NSLog(@"fileNamePath = %@",fileName);
    // 将 OC 字符串转换为 C 语言的字符串
    const char *cFileName = fileName.UTF8String;
    
    // 打开数据库文件(如果数据库文件不存在,那么该函数会自动创建数据库文件)
    int result = sqlite3_open(cFileName, &_db);
    
    if (result == SQLITE_OK) {  // 打开成功
        NSLog(@"成功打开数据库");
    } else {
        NSLog(@")打开数据库失败");
    }
}

@end

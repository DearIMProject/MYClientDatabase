//
//  MYChatUserManager.m
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/21.
//

#import "MYChatUserManager.h"

@interface MYChatUserManager ()

@property(nonatomic, strong) NSMutableArray<MYDBUser *> *cacheChatPersons;/**<  通讯录缓存 */

@end

@implementation MYChatUserManager

+ (instancetype)shared {
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
        _cacheChatPersons = [NSMutableArray array];
    }
    return self;
}

- (NSArray<MYDBUser *> *)dataGetAllChatPersonWithUserId:(long long)userId {
    NSMutableArray<MYDBUser *> *chatPersons = [NSMutableArray array];
    if (!self.database.isOpen) {
        return chatPersons;
    }
    NSString *sql = @"select userId,username,icon,affUserId from tb_user where affUserId = ?";
    FMResultSet *resultSet = [self.database executeQuery:sql, @(userId)];
    while (resultSet.next) {
        MYDBUser *person = [[MYDBUser alloc] init];
        person.userId = [resultSet longLongIntForColumn:@"userId"];
        person.name = [resultSet stringForColumn:@"username"];
        person.iconURL = [resultSet stringForColumn:@"icon"];
        person.affUserId = [resultSet longLongIntForColumn:@"affUserId"];
        person.iconURL = [resultSet stringForColumn:@"icon"];
        [chatPersons addObject:person];
    }
    [theChatUserManager resetChatPersons:chatPersons];
    return chatPersons;
}

- (void)updateChatPerson:(MYDBUser *)chatPerson {
    //TODO: wmy 判断通讯录是否存在
    [_cacheChatPersons addObject:chatPerson];
}

- (void)removeChatPerson:(MYDBUser *)chatPerson {
    MYDBUser *findChatPerson;
    for (MYDBUser *removeChatPerson in _cacheChatPersons) {
        if (removeChatPerson.userId == chatPerson.userId) {
            findChatPerson = removeChatPerson;
            break;
        }
    }
    [_cacheChatPersons removeObject:findChatPerson];
}

- (void)resetChatPersons:(NSArray<MYDBUser *> *)chatpersons {
    [_cacheChatPersons removeAllObjects];
    [_cacheChatPersons addObjectsFromArray:chatpersons];
}

- (MYDBUser *)chatPersonWithUserId:(long long)userId {
    for (MYDBUser *chatPerson in _cacheChatPersons) {
        if (chatPerson.userId == userId) {
            return chatPerson;
        }
    }
    return nil;
}
@end

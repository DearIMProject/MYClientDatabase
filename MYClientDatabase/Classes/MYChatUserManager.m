//
//  MYChatUserManager.m
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/21.
//

#import "MYChatUserManager.h"
#import <MYUtils/MYUtils.h>

NSString *kUserTable = @"tb_user";
NSString *kUserId = @"userId";
NSString *kUserName = @"username";
NSString *kEmail = @"email";
NSString *kIcon = @"icon";
NSString *kStatus = @"status";
NSString *kAffUserId = @"affUserId";

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
//    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@ from %@ where %@ = ?",kUserId,kUserName,kAffUserId,kIcon,kUserTable,kAffUserId];
    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@ from %@ ",kUserId,kUserName,kAffUserId,kIcon,kUserTable];
    [MYLog debug:sql];
//    FMResultSet *resultSet = [self.database executeQuery:sql, @(userId)];
    FMResultSet *resultSet = [self.database executeQuery:sql];
    while (resultSet.next) {
        MYDBUser *person = [[MYDBUser alloc] init];
        person.userId = [resultSet longLongIntForColumn:kUserId];
        person.name = [resultSet stringForColumn:kUserName];
        person.iconURL = [resultSet stringForColumn:kIcon];
        person.affUserId = [resultSet longLongIntForColumn:kAffUserId];
        [chatPersons addObject:person];
    }
    [theChatUserManager resetChatPersons:chatPersons];
    return chatPersons;
}

- (BOOL)updateChatPersons:(NSArray<MYDBUser *> *)persons fromUserId:(long long)userId {
    //TODO: wmy
    [self.database beginTransaction];
    BOOL isSuccess = YES;
    
    @try {
        for (MYDBUser *user in persons) {
            NSString *sql = [NSString stringWithFormat:@"INSERT into %@(%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?)",kUserTable,kUserId,kUserName,kIcon,kAffUserId,kEmail,kStatus];
            [MYLog debug:sql];
            isSuccess = [self.database executeUpdate:sql,
                         @(user.userId),
                         user.name,
                         user.iconURL,
                         @(userId),
                         user.email,
                         @(user.status)];
        }
    } @catch (NSException *exception) {
        isSuccess = NO;
        [self.database rollback];
    } @finally {
        if (isSuccess) {
            [self.database commit];
            [self.cacheChatPersons addObjectsFromArray:persons];
        }
    }
    return isSuccess;
    
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
    return [self dataUserWithUserId:userId];
}

- (MYDBUser *)dataUserWithUserId:(long long)userId {
    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@ from %@ where %@ = ?",kUserId,kUserName,kAffUserId,kIcon,kUserTable,kUserId];
    [MYLog debug:sql];
    FMResultSet *resultSet = [self.database executeQuery:sql];
    if (resultSet.next) {
        MYDBUser *person = [[MYDBUser alloc] init];
        person.userId = [resultSet longLongIntForColumn:kUserId];
        person.name = [resultSet stringForColumn:kUserName];
        person.iconURL = [resultSet stringForColumn:kIcon];
        person.affUserId = [resultSet longLongIntForColumn:kAffUserId];
        return person;
    }
    return nil;
}

@end

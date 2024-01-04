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
NSString *kUserAffUserId = @"affUserId";
NSString *kIsInChat = @"isInChat";

@interface MYChatUserManager ()

@property(nonatomic, strong) NSMutableArray<MYDBUser *> *cacheAddressPersons;/**<  通讯录缓存 */
@property (nonatomic, strong) NSMutableArray<MYDBUser *> *cacheChatPersons;/**<  正在聊天的人的缓存 */

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
        _cacheAddressPersons = [NSMutableArray array];
        _cacheChatPersons = [NSMutableArray array];
    }
    return self;
}

- (NSArray<MYDBUser *> *)getChatPersonWithUserId:(long long)userId {
    if (self.cacheChatPersons.count) {
        return self.cacheChatPersons;
    }
    return [self getDataChatPersonWithUserId:userId];
}

- (NSArray<MYDBUser *> *)getDataChatPersonWithUserId:(long long)userId {
    NSMutableArray<MYDBUser *> *chatPersons = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select "
                     " %@,%@,%@,%@ from %@"
                     " where %@ = ? and %@ = ?",
                     kUserId,kUserName,kUserAffUserId,kIcon,kUserTable,
                     kUserAffUserId,kIsInChat];
    [MYLog debug:@"📚sql = %@",sql];
    FMResultSet *resultSet = [self.database executeQuery:sql, @(userId),@(1)];
    while (resultSet.next) {
        MYDBUser *person = [[MYDBUser alloc] init];
        person.userId = [resultSet longLongIntForColumn:kUserId];
        person.name = [resultSet stringForColumn:kUserName];
        person.iconURL = [resultSet stringForColumn:kIcon];
        person.affUserId = [resultSet longLongIntForColumn:kUserAffUserId];
        [chatPersons addObject:person];
    }
    [theChatUserManager resetChatPersons:chatPersons];
    return chatPersons;
}

- (NSArray<MYDBUser *> *)getAllChatPersonWithUserId:(long long)userId {
    if (self.cacheAddressPersons.count) {
        return self.cacheAddressPersons;
    }
    [self.cacheChatPersons addObjectsFromArray:[self dataGetAllChatPersonWithUserId:userId]];
    return self.cacheChatPersons;
}

- (NSArray<MYDBUser *> *)dataGetAllChatPersonWithUserId:(long long)userId {
    NSMutableArray<MYDBUser *> *chatPersons = [NSMutableArray array];
    if (!self.database.isOpen) {
        return chatPersons;
    }
    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@ from %@ where %@ = ?",kUserId,kUserName,kUserAffUserId,kIcon,kUserTable,kUserAffUserId];
    [MYLog debug:@"📚sql = %@",sql];
    FMResultSet *resultSet = [self.database executeQuery:sql, @(userId)];
    while (resultSet.next) {
        MYDBUser *person = [[MYDBUser alloc] init];
        person.userId = [resultSet longLongIntForColumn:kUserId];
        person.name = [resultSet stringForColumn:kUserName];
        person.iconURL = [resultSet stringForColumn:kIcon];
        person.affUserId = [resultSet longLongIntForColumn:kUserAffUserId];
        [chatPersons addObject:person];
    }
    [self resetAddressPersons:chatPersons];
    return chatPersons;
}

- (BOOL)updateChatPersons:(NSArray<MYDBUser *> *)persons fromUserId:(long long)userId {
    [self.database beginTransaction];
    BOOL isSuccess = NO;
    
    @try {
        for (MYDBUser *user in persons) {
            NSString *sql = [NSString stringWithFormat:@"INSERT into "
                             " %@(%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?)",kUserTable,
                             kUserId,kUserName,kIcon,kEmail,kStatus,kUserAffUserId];
            [MYLog debug:@"📚sql = %@",sql];
            isSuccess = [self.database executeUpdate:sql,
                         @(user.userId),
                         user.name,
                         user.iconURL,
                         user.email,
                         @(user.status),
                         @(userId)];
        }
    } @catch (NSException *exception) {
        isSuccess = NO;
        [self.database rollback];
    } @finally {
        if (isSuccess) {
            [self.database commit];
            [self.cacheAddressPersons addObjectsFromArray:persons];
        }
    }
    return isSuccess;
    
}

- (BOOL)updateUser:(MYDBUser *)user inChat:(BOOL)inchat belongUserId:(long long)ownerUserId {
    [self.database beginTransaction];
    BOOL isSuccess;
    @try {
        NSString *sql = [NSString stringWithFormat:@"update %@ SET %@ = ? where %@ = ? and %@ = ?",kUserTable,kIsInChat,kUserId,kUserAffUserId];
        [MYLog debug:@"📚sql = %@",sql];
        NSInteger chat = inchat? 1 : 0;
        isSuccess = [self.database executeUpdate:sql,@(chat),@(user.userId),@(ownerUserId)];
    } @catch (NSException *exception) {
        [self.database rollback];
        NSLog(@"📚 exception = %@",exception);
    } @finally {
        if (isSuccess) {
            [self.database commit];
        }
        return isSuccess;
    }
}

- (void)updateChatPerson:(MYDBUser *)chatPerson {
    //TODO: wmy 判断通讯录是否存在
    [_cacheAddressPersons addObject:chatPerson];
}

- (void)removeChatPerson:(MYDBUser *)chatPerson {
    MYDBUser *findChatPerson;
    for (MYDBUser *removeChatPerson in _cacheAddressPersons) {
        if (removeChatPerson.userId == chatPerson.userId) {
            findChatPerson = removeChatPerson;
            break;
        }
    }
    [_cacheAddressPersons removeObject:findChatPerson];
}

- (void)resetAddressPersons:(NSArray<MYDBUser *> *)chatpersons {
    [_cacheAddressPersons removeAllObjects];
    [_cacheAddressPersons addObjectsFromArray:chatpersons];
}

- (void)resetChatPersons:(NSArray<MYDBUser *> *)chatpersons {
    [_cacheChatPersons removeAllObjects];
    [_cacheChatPersons addObjectsFromArray:chatpersons];
}

- (MYDBUser *)chatPersonWithUserId:(long long)userId {
    for (MYDBUser *chatPerson in _cacheAddressPersons) {
        if (chatPerson.userId == userId) {
            return chatPerson;
        }
    }
    return [self dataUserWithUserId:userId];
}

- (MYDBUser *)dataUserWithUserId:(long long)userId {
    NSString *sql = [NSString stringWithFormat:@"select %@,%@,%@,%@ from %@ where %@ = ?",kUserId,kUserName,kUserAffUserId,kIcon,kUserTable,kUserId];
    [MYLog debug:@"📚sql = %@",sql];
    FMResultSet *resultSet = [self.database executeQuery:sql,@(userId)];
    if (resultSet.next) {
        MYDBUser *person = [[MYDBUser alloc] init];
        person.userId = [resultSet longLongIntForColumn:kUserId];
        person.name = [resultSet stringForColumn:kUserName];
        person.iconURL = [resultSet stringForColumn:kIcon];
        person.affUserId = [resultSet longLongIntForColumn:kUserAffUserId];
        return person;
    }
    return nil;
}

@end

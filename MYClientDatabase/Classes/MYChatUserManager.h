//
//  MYChatUserManager.h
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/21.
//  用于对通讯录用户列表信息等的管理

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "MYDBUser.h"

NS_ASSUME_NONNULL_BEGIN

#define theChatUserManager MYChatUserManager.shared

@interface MYChatUserManager : NSObject

@property (nonatomic, strong) FMDatabase *database;/**< 数据库  */

+ (instancetype)shared;

- (void)resetAddressPersons:(NSArray<MYDBUser *> *)chatpersons;

- (void)updateChatPerson:(MYDBUser *)chatPerson;

- (void)removeChatPerson:(MYDBUser *)chatPerson;

- (BOOL)updateUser:(MYDBUser *)user inChat:(BOOL)inchat belongUserId:(long long)ownerUserId;

/// 获取指定用户所有通讯录中用户的信息
/// - Parameter userId: userId
- (NSArray<MYDBUser *> *)getAllChatPersonWithUserId:(long long)userId;

/// 获取指定用户正在聊天的用户列表
/// - Parameter userId: userId
- (NSArray<MYDBUser *> *)getChatPersonWithUserId:(long long)userId;

- (BOOL)updateChatPersons:(NSArray<MYDBUser *> *)persons fromUserId:(long long)userId;

- (MYDBUser *)chatPersonWithUserId:(long long)userId;

@end

NS_ASSUME_NONNULL_END

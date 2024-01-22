//
//  MYChatUserManager.h
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/21.
//  用于对通讯录用户列表信息等的管理

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "MYDBUser.h"

//FOUNDATION_EXPORT NSString * const CHAT_PERSON_CHANGE;

NS_ASSUME_NONNULL_BEGIN

#define theChatUserManager MYChatUserManager.shared

@interface MYChatUserManager : NSObject

@property (nonatomic, strong) FMDatabase *database;/**< 数据库  */

+ (instancetype)shared;

- (void)resetCaches;

- (void)resetAddressPersons:(NSArray<MYDBUser *> *)chatpersons;

- (void)updateChatPerson:(MYDBUser *)chatPerson;

- (void)removeChatPerson:(MYDBUser *)chatPerson;

- (BOOL)updateUser:(MYDBUser *)user inChat:(BOOL)inchat;



- (MYDBUser *)chatPersonWithUserId:(long long)userId;

@end

NS_ASSUME_NONNULL_END

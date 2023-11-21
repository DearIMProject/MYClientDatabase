//
//  MYChatPersonManager.m
//  MYClientDatabase
//
//  Created by APPLE on 2023/11/21.
//

#import "MYChatPersonManager.h"

@interface MYChatPersonManager ()

@property(nonatomic, strong) NSMutableArray<MYDataChatPerson *> *cacheChatPersons;/**<  通讯录缓存 */

@end

@implementation MYChatPersonManager

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

- (void)updateChatPerson:(MYDataChatPerson *)chatPerson {
    //TODO: wmy 判断通讯录是否存在
    [_cacheChatPersons addObject:chatPerson];
}

- (void)removeChatPerson:(MYDataChatPerson *)chatPerson {
    MYDataChatPerson *findChatPerson;
    for (MYDataChatPerson *removeChatPerson in _cacheChatPersons) {
        if (removeChatPerson.userId == chatPerson.userId) {
            findChatPerson = removeChatPerson;
            break;
        }
    }
    [_cacheChatPersons removeObject:findChatPerson];
}

- (void)resetChatPersons:(NSArray<MYDataChatPerson *> *)chatpersons {
    [_cacheChatPersons removeAllObjects];
    [_cacheChatPersons addObjectsFromArray:chatpersons];
}

- (MYDataChatPerson *)chatPersonWithUserId:(long long)userId {
    for (MYDataChatPerson *chatPerson in _cacheChatPersons) {
        if (chatPerson.userId == userId) {
            return chatPerson;
        }
    }
    return nil;
}
@end

//
//  MYDBUser.h
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//  聊天人模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MYDBUser : NSObject

@property (nonatomic, assign) long long userId;/**<  用户id */
@property (nonatomic, strong) NSString *name;/**<  名称 */
@property (nonatomic, strong) NSString *iconURL;/**<  头像 */
@property (nonatomic, assign) long long affUserId;/**<  属于哪个user */

@end

NS_ASSUME_NONNULL_END

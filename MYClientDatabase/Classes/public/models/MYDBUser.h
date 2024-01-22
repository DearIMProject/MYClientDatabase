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
@property (nonatomic, strong) NSString *email;/**<  邮箱 */
@property (nonatomic, strong) NSString *iconURL;/**<  头像 */
@property (nonatomic, assign) int status;/**<  状态 */
@property (nonatomic, assign) BOOL isInChat;/**< 是否在聊天窗口  */

@end

NS_ASSUME_NONNULL_END

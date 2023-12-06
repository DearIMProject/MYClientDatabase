//
//  MYDataMessage.h
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//  数据库的message

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    MYDataMessageStatus_loading,
    MYDataMessageStatus_Success,
    MYDataMessageStatus_Failure,
} MYDataMessageStatus;

@interface MYDataMessage : NSObject

@property (nonatomic, assign) long msgId;/**<  消息id */
@property (nonatomic, assign) long fromId;/**<  消息发送方 */
@property (nonatomic, assign) int fromEntity;
@property (nonatomic, assign) long toId;/**<  消息接收方 */
@property (nonatomic, assign) int toEntity;
@property (nonatomic, strong) NSString *content;/**<  内容 */
@property (nonatomic, assign) int messageType;/**<  messageType */
@property (nonatomic, assign) long timestamp;
@property (nonatomic, assign) MYDataMessageStatus sendStatus;/**<  是否发送成功 */

@end

NS_ASSUME_NONNULL_END

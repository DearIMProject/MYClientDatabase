//
//  MYDataMessage.m
//  AFNetworking
//
//  Created by APPLE on 2023/11/17.
//

#import "MYDataMessage.h"

@implementation MYDataMessage

- (NSString *)description {
    return [NSString stringWithFormat:@"[MYDataMessage] %p- msgId=%ld,fromId=%ld,fromEntity=%d,toId=%ld,toEntity=%ld,messgeaType=%d,sendStatus=%d,readList=%@, timestamp=%d,content=%@"
            ,self,_msgId,_fromId,_fromEntity,_toId,_toEntity,_messageType,_sendStatus,_readList,_timestamp,_content];
}


@end

//
//  GatewayClass.m
//  molo
//
//  Created by Geoffrey Peterson on 12/16/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "GatewayClass.h"

NSString *const succesfulHandOffToGateway = @"SuccesfulHandOffToGW";

@implementation GatewayClass

// used to implement the singleton design pattern
+ (id) sharedInstance{
    static dispatch_once_t token;
    static GatewayClass *sharedInstance = nil;
    
    dispatch_once(&token, ^{
        sharedInstance = [[GatewayClass alloc] init];
    });
    
    return sharedInstance;
}

// used to push a new message to the outside world
- (NSString *)pushUserMsg: (NSString *) newMsgID{
    NSLog(@"Pushing message ID: %@", newMsgID);
    return (NSString *)succesfulHandOffToGateway;
}

@end

//
//  GatewayClass.h
//  molo
//
//  Created by Geoffrey Peterson on 12/16/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - constants
extern NSString *const succesfulHandOffToGateway;

@interface GatewayClass : NSObject

// used to implement the singleton design pattern
+ (id) sharedInstance;

// used to push a new message to the outside world
- (NSString *)pushUserMsg: (NSString *) newMsgID;

@end

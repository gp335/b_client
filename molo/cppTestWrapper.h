//
//  cppTestWrapper.h
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface cppTestWrapper : NSObject 

-(int)getPrivateInt;
-(int)getPrivateInlineInt;
-(int)getPublicInt;

@end

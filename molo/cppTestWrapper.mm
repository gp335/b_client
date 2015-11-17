//
//  cppTestWrapper.m
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "cppTestWrapper.h"
#import "cppTest.hpp"



@implementation cppTestWrapper{
    testClass *cppInstance;
}

- (id)init {
    if(self = [super init]) {
        cppInstance= new testClass();
    }
    return self;
}

- (void) dealloc {
    if(cppInstance != NULL) delete cppInstance;
    [super dealloc];
}

- (void)callCpp {
    cppInstance->SomeMethod();
}


-(int)getPrivateInt(){
    return cppInstance->getPrivateInt();
}

-(int)getPrivateInlineInt(){
    return cppInstance->getPrivateInlineInt();
}

-(int)getPublicInt(){
    return cppInstance->myInt;
}

@end

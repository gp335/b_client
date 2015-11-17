//
//  cppTestWrapper.m
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "cppTestWrapper.h"
#include "cppTest.hpp"



@implementation cppTestWrapper{
    testClass *cppInstance;
}

- (id)init {
    if(self = [super init]) {
        cppInstance = new testClass();
    }
    return self;
}

- (void) dealloc {
    if(cppInstance != NULL) delete cppInstance;
    // [super dealloc]; // this is provided by the compiler automatically
}



-(int)getPrivateInt {
    return cppInstance->cpp_getPrivateInt();
}

-(int)getPrivateInlineInt{
    return cppInstance->cpp_getInlinePrivateInt();
}

-(int)getPublicInt{
    return cppInstance->cpp_myInt;
}

@end

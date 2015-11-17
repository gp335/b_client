//
//  cppTest.hpp
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#ifndef cppTest_hpp
#define cppTest_hpp

#include <stdio.h>

class testClass{
public:
    int cpp_myInt = 5;
    int cpp_getPrivateInt();
    int cpp_getInlinePrivateInt(){
        return cpp_myPrivateInt;
    }
private:
    int cpp_myPrivateInt = 10;
};

#endif /* cppTest_hpp */

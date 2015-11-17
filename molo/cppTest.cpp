//
//  cppTest.cpp
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#include "cppTest.hpp"

class testObject{
public:
    int myInt = 5;
    int getPrivateInt();
    int getInlinePrivateInt(){
        return myPrivateInt;
    }
private:
    int myPrivateInt = 10;
};

int testObject::getPrivateInt(){
    return myPrivateInt;
}
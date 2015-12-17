//
//  ViewController.h
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageDatabase.h"
#import "GatewayClass.h"

@interface ViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>{
    
    IBOutlet NSView *placeholderView;
}

- (IBAction)sendMsg:(id)sender;
- (IBAction)getUsrMsg:(id)sender;


@property (weak) IBOutlet NSTextFieldCell *usrMsg;


@property NSTableView *_myTableView;



@end


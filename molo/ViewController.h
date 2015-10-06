//
//  ViewController.h
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChatTableView.h"

@interface ViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>{
    
    IBOutlet NSView *placeholderView;
}

- (IBAction)sendMsg:(id)sender;
- (IBAction)getUsrMsg:(id)sender;
- (void) msgToQueue:(NSString *)msg;

@property (weak) IBOutlet NSTextFieldCell *usrMsg;

// TODO1: think about data encapsulation and hiding...
@property NSMutableArray *_tableContents;
@property NSTableView *_myTableView;


@end


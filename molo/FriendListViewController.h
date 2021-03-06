//
//  FriendListViewController.h
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageDatabase.h"
#import "ViewController.h"
#import "ExtendedNSTableView.h"

@interface FriendListViewController : NSViewController <ExtendedNSTableViewDelegate, NSTableViewDelegate, NSTableViewDataSource>{

    IBOutlet NSView *friendListPlaceholderView;
}

@property NSMutableArray *_tableContents;
@property ExtendedNSTableView *_myTableView;

@property (weak, nonatomic) ViewController *conversationViewController;
@property (weak, nonatomic) NSManagedObject *currentContactInFocus;

@end

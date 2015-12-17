//
//  FriendListViewController.h
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageDatabase.h"

@interface FriendListViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>{

    IBOutlet NSView *friendListPlaceholderView;
}

@property NSMutableArray *_tableContents;
@property NSTableView *_myTableView;

@end

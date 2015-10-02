//
//  ChatTableView.h
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChatTableView : NSTableView{
@private
    IBOutlet NSTableView *_tableView;
    NSMutableArray *_tableContents;
}
@end

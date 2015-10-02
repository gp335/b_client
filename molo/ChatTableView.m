//
//  ChatTableView.m
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import "ChatTableView.h"

static NSString *ATTableData[] = {
    @"foo",
    @"bar",
    @"baz"
};

@implementation ChatTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"In the other num rows method!");
    return [_tableContents count];
}

@end

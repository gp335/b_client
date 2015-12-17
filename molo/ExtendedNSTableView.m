//
//  ExtendedNSTableView.m
//  molo
//
//  Created by Geoffrey Peterson on 12/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "ExtendedNSTableView.h"

@implementation ExtendedNSTableView

//-(id) init{
//    self = [super init];
//    self.extendedDelegate = self;
//    return self;
//}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    
    [super mouseDown:theEvent];
    
    if (clickedRow != -1) {
        [self.extendedDelegate tableView:self didClickedRow:clickedRow];
    }
}

@end

//
//  ExtendedNSTableView.h
//  molo
//
//  Created by Geoffrey Peterson on 12/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ExtendedNSTableViewDelegate <NSObject>

- (void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row;

@end

@interface ExtendedNSTableView : NSTableView

@property (nonatomic, weak) id<ExtendedNSTableViewDelegate> extendedDelegate;

@end

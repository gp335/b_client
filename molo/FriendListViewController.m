//
//  FriendListViewController.m
//  molo
//
//  Created by Geoffrey Peterson on 11/17/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "FriendListViewController.h"

@interface FriendListViewController ()

@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self._tableContents =
    [[NSMutableArray alloc] initWithObjects:
     [NSDictionary dictionaryWithObjectsAndKeys:@"Friend #1",@"key1", nil],
     [NSDictionary dictionaryWithObjectsAndKeys:@"Friend #2",@"key1", nil],
     [NSDictionary dictionaryWithObjectsAndKeys:@"Friend #3",@"key1", nil],
     nil];
    [self createTableView];
    self._myTableView.extendedDelegate = self;
}


- (void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row {
    NSLog(@"Got a click at row: %li", row);
}

- (void) createTableView{
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:friendListPlaceholderView.bounds];
    [scrollView setBorderType:NSBezelBorder];
    self._myTableView = [[ExtendedNSTableView alloc] initWithFrame:friendListPlaceholderView.bounds];
    NSTableColumn *tCol;
    int noOfColumns = 1;
    for (int i=0; i<noOfColumns; i++)
    {
        tCol = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"key%d",i+1]];
        // TODO: set width dynamically based on size of the window
        [tCol setWidth:200.0];
        [[tCol headerCell] setStringValue:[NSString stringWithFormat:@"Column %d",i+1]];
        [self._myTableView addTableColumn:tCol];
    }
    
    // TODO: make all of this formatting nicer
    [self._myTableView setUsesAlternatingRowBackgroundColors:NO];
    [self._myTableView setGridStyleMask:NSTableViewSolidVerticalGridLineMask];
    [self._myTableView setGridColor:[NSColor whiteColor]];
    [self._myTableView setRowHeight:23.0];
    [self._myTableView setDelegate:self];
    [self._myTableView setDataSource:self];
    [self._myTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [self._myTableView setAutoresizesSubviews:YES];
    
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutoresizesSubviews:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [scrollView setDocumentView:self._myTableView];
    [friendListPlaceholderView addSubview:scrollView];
}

// TableView Datasource method implementation
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *aString = [[MessageDatabase sharedInstance] contactAtIndex:rowIndex objectForKey:[aTableColumn identifier]];
    return aString;
}

// TableView Datasource method implementation
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //we have only one table in the screen and thus we are not checking the row count based on the target table view
    return [[MessageDatabase sharedInstance] numContactsInMemory];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

@end

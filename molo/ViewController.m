//
//  ViewController.m
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import "ViewController.h"
#import "cppTestWrapper.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // load existing messages
    
    // just some C++ tests...
    NSLog(@"clearly doing something");
    cppTestWrapper *cppObj = [[cppTestWrapper alloc] init];
    NSLog(@" Public val is: %i", [cppObj getPublicInt]);
    NSLog(@" Private val is: %i", [cppObj getPrivateInt]);
    NSLog(@" Private inline val is: %i", [cppObj getPrivateInlineInt]);
    
    [self createTableView];
    [[[self view] window] setInitialFirstResponder:(NSView *)[self usrMsg]];
}



// usr string goes on right, friend string on the left...
- (void) createTableView{
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:placeholderView.bounds];
    [scrollView setBorderType:NSBezelBorder];
    self._myTableView = [[NSTableView alloc] initWithFrame:placeholderView.bounds];
    NSTableColumn *tCol;
    int noOfColumns = 2;
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
    [placeholderView addSubview:scrollView];
}
    
// TableView Datasource method implementation
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *aString = [[MessageDatabase sharedInstance] msgAtIndex:rowIndex objectForKey:[aTableColumn identifier] forContactID:@"1a1a1a"];
    return aString;
}

// TableView Datasource method implementation
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //we have only one table in the screen and thus we are not checking the row count based on the target table view
    NSLog(@"Checking for length, which seems to be: %li", [[MessageDatabase sharedInstance] numMsgsInMemoryForContactID:@"1a1a1a"]);
    return [[MessageDatabase sharedInstance] numMsgsInMemoryForContactID:@"1a1a1a"];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


- (IBAction)sendMsg:(id)sender {
    NSString *recMsg = [self.usrMsg stringValue];
    NSLog(@"Pushed send with: [%@]", recMsg);
    [self processUserString:recMsg];
}

- (IBAction)getUsrMsg:(id)sender {
    NSString *recMsg = [sender stringValue];
    NSLog(@"Hit enter with: [%@]", recMsg);
    [self processUserString:recMsg];
}

// Internal function that handles the logic of accepting a string from the user
// TODO: have it dynamically pull out who to send the message to rather than hardcoding to John's ID
- (void) processUserString:(NSString *)userString{
    // 1 - push message to local store
    NSString *newMsgID = [[MessageDatabase sharedInstance] newMsg:userString toContactID:@"1a1a1a"];
    
    // 2 - trigger push of message to gateway
    if([newMsgID isEqualToString:(NSString *)MessageDatabaseInsertError]){
        //TODO: do something appropriate
        NSLog(@"Error putting new message into BD");
    } else {
        [[GatewayClass sharedInstance] pushUserMsg:newMsgID];
    }
    
    // 3 - refresh the view
    [self.usrMsg setStringValue:@""];
    [self._myTableView reloadData];
}

@end

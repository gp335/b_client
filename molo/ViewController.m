//
//  ViewController.m
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import "ViewController.h"
#import "ChatTableView.h"
#import "cppTestWrapper.h"

static const NSString *ATTableData[] = {
    @"First message",
    @"Second message",
    @"Last message",
    nil};

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *__strong*data = &ATTableData[0];
    while (*data != nil) {
        NSString *name = [[NSString alloc] initWithString:*data];
        NSImage *image = [NSImage imageNamed:name];
        // our model will consist of a dictionary with Name/Image key pairs
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"Name", image, @"Image",nil, nil];
        [self._tableContents addObject:dictionary];
        data++;
    }
    
    self._tableContents =
    [[NSMutableArray alloc] initWithObjects:
     [NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",@"What up dog!",@"key2", nil],
     [NSDictionary dictionaryWithObjectsAndKeys:@"Not much how about you?",@"key1",@"",@"key2", nil],
     [NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",@"Just chilling and watching the game.",@"key2", nil],
     [NSDictionary dictionaryWithObjectsAndKeys:@"Sweet.",@"key1",@"",@"key2", nil],
     nil];
    
    NSLog(@"clearly doing something");
    cppTestWrapper *cppObj = [[cppTestWrapper alloc] init];
    NSLog(@" Public val is: %i", [cppObj getPublicInt]);
    NSLog(@" Private val is: %i", [cppObj getPrivateInt]);
    NSLog(@" Private inline val is: %i", [cppObj getPrivateInlineInt]);
    
    [self createTableView];
    [[[self view] window] setInitialFirstResponder:[self usrMsg]];
}

//-(NSArray *)dataArray
//{
//    NSArray *array = [NSArray arrayWithObjects:
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",@"What up dog!",@"key2", nil],
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"Not much how about you?",@"key1",@"",@"key2", nil],
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",@"Just chilling and watching the game.",@"key2", nil],
//                      [NSDictionary dictionaryWithObjectsAndKeys:@"Sweet.",@"key1",@"",@"key2", nil],
//                      nil];
//    return array;
//}

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
    // NSString *aString = [NSString stringWithFormat:@"%@, Row %ld",[aTableColumn identifier],(long)rowIndex];
    NSString *aString;
    aString = [[self._tableContents objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
    return aString;
}

// TableView Datasource method implementation
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //we have only one table in the screen and thus we are not checking the row count based on the target table view
    long recordCount = [self._tableContents count];
    return recordCount;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)sendMsg:(id)sender {
    NSString *recMsg = [self.usrMsg stringValue];
    NSLog(@"Pushed send with: [%@]", recMsg);
    [self msgToQueue:recMsg];
    [self.usrMsg setStringValue:@""];
}

- (IBAction)getUsrMsg:(id)sender {
    NSString *recMsg = [sender stringValue];
    NSLog(@"Hit enter with: [%@]", recMsg);
    [self msgToQueue:recMsg];
    [sender setStringValue:@""];
}

-(void) msgToQueue:(NSString *)msg{
    NSLog(@"Queuing up the message to send!");
    // actually insert it into a queue structure
    [self._tableContents insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",msg,@"key2", nil] atIndex:0];
    [self._myTableView reloadData];
}

@end

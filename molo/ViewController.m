//
//  ViewController.m
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import "ViewController.h"
#import "ChatTableView.h"

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
    NSLog(@"clearly doing something");
    [self createTableView];

}

-(NSArray *)dataArray
{
    NSArray *array = [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObjectsAndKeys:@"1001",@"key1",@"1002",@"key2",@"1003",@"key3",@"1004",@"key4",@"1005",@"key5",@"1006",@"key6",@"1007",@"key7", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"2001",@"key1",@"2002",@"key2",@"2003",@"key3",@"2004",@"key4",@"2005",@"key5",@"2006",@"key6",@"2007",@"key7", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"3001",@"key1",@"3002",@"key2",@"3003",@"key3",@"3004",@"key4",@"3005",@"key5",@"3006",@"key6",@"3007",@"key7", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:@"4001",@"key1",@"4002",@"key2",@"4003",@"key3",@"4004",@"key4",@"4005",@"key5",@"4006",@"key6",@"4007",@"key7", nil],
                      nil];
    return array;
}

- (void) createTableView{
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:placeholderView.bounds];
    [scrollView setBorderType:NSBezelBorder];
    NSTableView *myTableView = [[NSTableView alloc] initWithFrame:placeholderView.bounds];
    NSTableColumn *tCol;
    int noOfColumns = 7;
    for (int i=0; i<noOfColumns; i++)
    {
        tCol = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"key%d",i+1]];
        [tCol setWidth:100.0];
        [[tCol headerCell] setStringValue:[NSString stringWithFormat:@"Column %d",i+1]];
        [myTableView addTableColumn:tCol];
    }
    
    [myTableView setUsesAlternatingRowBackgroundColors:YES];
    [myTableView setGridStyleMask:NSTableViewSolidVerticalGridLineMask];
    [myTableView setGridColor:[NSColor redColor]];
    [myTableView setRowHeight:23.0];
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    [myTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [myTableView setAutoresizesSubviews:YES];
    
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutoresizesSubviews:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [scrollView setDocumentView:myTableView];
    [placeholderView addSubview:scrollView];
}

// TableView Datasource method implementation
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    // NSString *aString = [NSString stringWithFormat:@"%@, Row %ld",[aTableColumn identifier],(long)rowIndex];
    NSString *aString;
    aString = [[self.dataArray objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
    return aString;
}

// TableView Datasource method implementation
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //we have only one table in the screen and thus we are not checking the row count based on the target table view
    long recordCount = [self.dataArray count];
    return recordCount;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)sendMsg:(id)sender {
    NSString *recMsg = [self.usrMsg stringValue];
    NSLog(@"Pushed send with: [%@]", recMsg);
    // send to message queue
    [self.usrMsg setStringValue:@""];
}

- (IBAction)getUsrMsg:(id)sender {
    NSString *recMsg = [sender stringValue];
    NSLog(@"Hit enter with: [%@]", recMsg);
    // send to message queue
    [sender setStringValue:@""];
}

@end

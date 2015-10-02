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

@synthesize _convoTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self._convoTableView];
    
    self._tableContents = [NSMutableArray new];
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
    [self._convoTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"checking the number of rows!");
    return [self._tableContents count];
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"In the viewforTableColumn area!");
    // Group our "model" object, which is a dictionary
    NSString *blurb = [self._tableContents objectAtIndex:row];
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        // We pass us as the owner so we can setup target/actions into this main controller object
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        cellView.textField.stringValue = blurb;
        return cellView;
    } else {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
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

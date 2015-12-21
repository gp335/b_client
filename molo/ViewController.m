//
//  ViewController.m
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import "ViewController.h"
#import "cppTestWrapper.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController{
    FriendListViewController *friendListViewController;
    NSManagedObject *userObj;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appD = [[NSApplication sharedApplication] delegate];
    appD.messagesViewController = self;
    friendListViewController = appD.friendListViewController;
    assert(nil != friendListViewController);
    self->userObj = [appD retrieveUserObj];
    assert(nil != self->userObj);
    
    // just some C++ tests...
    NSLog(@"clearly doing something");
    cppTestWrapper *cppObj = [[cppTestWrapper alloc] init];
    NSLog(@" Public val is: %i", [cppObj getPublicInt]);
    NSLog(@" Private val is: %i", [cppObj getPrivateInt]);
    NSLog(@" Private inline val is: %i", [cppObj getPrivateInlineInt]);
    
    [self createTableView];
    [[[self view] window] setInitialFirstResponder:(NSView *)[self usrMsg]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange:) name:NSManagedObjectContextDidSaveNotification object:[appD managedObjectContext]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDBDidChange:)name:MessageDatabaseChangeNotification object:nil];
}

// usr string goes on right, friend string on the left...
- (void) createTableView{
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:placeholderView.bounds];
    [scrollView setBorderType:NSBezelBorder];
    self._myTableView = [[NSTableView alloc] initWithFrame:placeholderView.bounds];
    
    NSTableColumn *friendCol = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"key1"]];
    NSTableColumn *userCol = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"key2"]];
    // TODO: set width dynamically based on size of the window
    [friendCol setWidth:200.0];
    [userCol setWidth:200.0];
    [[friendCol headerCell] setStringValue:[self->friendListViewController.currentContactInFocus valueForKey:@"contactName"]];
    // TODO: pull in the user's name here once we have preferences fully functioning
    [[userCol headerCell] setStringValue:[self->userObj valueForKey:@"userName"]];
    [self._myTableView addTableColumn:friendCol];
    [self._myTableView addTableColumn:userCol];

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
    [self->__myTableView scrollRowToVisible:0];
}
    
// TableView Datasource method implementation
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *contactIDInFocus = [self->friendListViewController.currentContactInFocus valueForKey:@"contactLocalID"];
//    NSLog(@"Looking for contact ID: %@", contactIDInFocus);
    NSString *aString = [[MessageDatabase sharedInstance] msgAtIndex:rowIndex objectForKey:[aTableColumn identifier] forContactID:contactIDInFocus];
    return aString;
}

// TableView Datasource method implementation
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSString *contactIDInFocus = [self->friendListViewController.currentContactInFocus valueForKey:@"contactLocalID"];
//    NSLog(@"Checking for length, which seems to be: %li", [[MessageDatabase sharedInstance] numMsgsInMemoryForContactID:contactIDInFocus]);
    return [[MessageDatabase sharedInstance] numMsgsInMemoryForContactID:contactIDInFocus];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


-(void)updateConversationView{
    [[[self->__myTableView tableColumnWithIdentifier:@"key1"] headerCell] setStringValue:[self->friendListViewController.currentContactInFocus valueForKey:@"contactName"]];
    [self->__myTableView reloadData];
    // TODO: instead of scrolling to row zero, remember where the user scrolled to last in the conversation
    [self->__myTableView scrollRowToVisible:0];
}


- (IBAction)sendMsg:(id)sender {
    NSString *recMsg = [self.usrMsg stringValue];
    NSLog(@"Pushed send with: [%@]", recMsg);
    if([self validateStringInput:recMsg]){
        [self processUserString:recMsg];
    }
}

- (IBAction)getUsrMsg:(id)sender {
    NSString *recMsg = [sender stringValue];
    NSLog(@"Hit enter with: [%@]", recMsg);
    if([self validateStringInput:recMsg]){
        [self processUserString:recMsg];
    }
}

// Internal function that handles the logic of accepting a string from the user
- (void) processUserString:(NSString *)userString{
    // 1 - push message to local store
    NSString *contactIDInFocus = [self->friendListViewController.currentContactInFocus valueForKey:@"contactLocalID"];
    NSString *newMsgID = [[MessageDatabase sharedInstance] newMsg:userString toContactID:contactIDInFocus];
    NSLog(@"The message ID we got was: %@", newMsgID);
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

- (BOOL) validateStringInput:(NSString *)str{
    // check to see if it's only whitespace characters
    if([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        return NO;
    }
    return YES;
}

- (void) storeDidChange:(NSNotification *) notification{
    // We only grab changes here that have to do with user info (e.g., the name for the column heading)
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:notification.object];
    @try {
        NSSet *updatedManagedObjects = [[notification valueForKey:@"userInfo"] valueForKey:NSUpdatedObjectsKey];
        for(NSManagedObject *obj in updatedManagedObjects){
            if([[obj entity] isEqual:userEntity]){
                NSLog(@"I have to update the username to: %@", [obj valueForKey:@"userName"]);
                [[[self._myTableView tableColumnWithIdentifier:@"key2"] headerCell] setStringValue:[self->userObj valueForKey:@"userName"]];
                [self._myTableView reloadData];
            }
        }
    }
    @catch(NSException *exception) {
        NSLog(@"Not a username update so threw this exception: %@", exception);
    }
}

- (void) messageDBDidChange:(NSNotification *)notification{
    NSLog(@"Got a notification from MessageDatabase that we have new messages: %@", notification);
    [self._myTableView reloadData];
}

@end

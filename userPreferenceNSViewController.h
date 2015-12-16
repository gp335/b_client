//
//  userPreferenceNSViewController.h
//  molo
//
//  Created by Geoffrey Peterson on 12/12/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface userPreferenceNSViewController : NSViewController
@property (strong) IBOutlet NSTextField *userNameField;
- (IBAction)userNameFieldUpdated:(id)sender;
- (IBAction)okButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (strong) NSString *userName;

@property (weak) NSMenuItem *parentNSMenuItem;

@end

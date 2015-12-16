//
//  userPreferenceNSViewController.m
//  molo
//
//  Created by Geoffrey Peterson on 12/12/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "userPreferenceNSViewController.h"

@interface userPreferenceNSViewController ()

@end

@implementation userPreferenceNSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // pull the object context
    self.userName = @"Floo";
    
}

- (IBAction)userNameFieldUpdated:(id)sender {
    // grab the user name field
    
    NSLog(@"blarg: %@", self.userNameField.stringValue);
    
}

- (IBAction)okButtonPressed:(id)sender {
    // save the name to the managed context
    NSLog(@"Saving the user name: %@", self.userName);
}

- (IBAction)cancelButtonPressed:(id)sender {
    // just exit
    NSLog(@"The presenting view controller: %@", [self presentingViewController]);
    NSLog(@"THe parent view controller: %@", [self parentViewController]);
    NSLog(@"THe parent NSMenuItem: %@", [self parentNSMenuItem]);
    NSLog(@"The parent of the parent is: %@", [[self parentViewController] parentViewController]);
    NSLog(@"The presenting of the parent is: %@", [[self parentViewController] presentingViewController]);
    [self dismissController:self];
}

@end

//
//  userPreferenceNSViewController.m
//  molo
//
//  Created by Geoffrey Peterson on 12/12/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "userPreferenceNSViewController.h"
#import "AppDelegate.h"

@interface userPreferenceNSViewController ()

@end

@implementation userPreferenceNSViewController{
    NSManagedObjectContext *managedObjectContext;
    NSManagedObject *userObj;
}

// TODO: put this stuff somewhere else... it should have to require us loading the preferences window
- (void)viewDidLoad {
    [super viewDidLoad];
    // pull the object context
    
    self->managedObjectContext = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchUserRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self->managedObjectContext];
    [fetchUserRequest setEntity:entity];
    NSError *userError = nil;
    NSArray *userResult = [self->managedObjectContext executeFetchRequest:fetchUserRequest error:&userError];
    if (userError) {
        NSLog(@"Unable to execute user fetch request.");
        NSLog(@"%@, %@", userError, userError.localizedDescription);
    }
    
    // We don't have any user records yet
    if(0 == [userResult count]){
        NSManagedObject *newUser = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self->managedObjectContext];
        [newUser setValue:@"3a3a3a" forKey:@"userLocalID"];
        // don't need to set a name value since that's set in storyboard
        NSError *userError = nil;
        if (![newUser.managedObjectContext save:&userError]) {
            NSLog(@"Unable to save default user in managed object context.");
            NSLog(@"%@, %@", userError, userError.localizedDescription);
        } else {
            NSLog(@"Succesfully saved default user in context: %@", newUser.managedObjectContext);
        }
        self->userObj = newUser;

    // if we got back more than one user, something strange happened and we should flag it
    } else if(1 != [userResult count]){
        NSLog(@"Error: Got an inconsistent number of users (expected just 1, got %lu).", [userResult count]);
        assert(NO);
    
    // there was already the correct number of users in the system (1!)
    } else {
        self->userObj = userResult[0];
    }
    
    self.userNameField.placeholderString = [self->userObj valueForKey:@"userName"];
    self.userNameField.stringValue = [self->userObj valueForKey:@"userName"];
    self.userName = [self->userObj valueForKey:@"userName"];
}

- (IBAction)userNameFieldUpdated:(id)sender {
    // grab the user name field
    NSString *originalName = self.userName;
    NSLog(@"Going to update new name to: %@", self.userNameField.stringValue);
    if([self saveNewUserName:self.userNameField.stringValue]){
        self.userName = self.userNameField.stringValue;
    } else {
        self.userNameField.stringValue = originalName;
    }
}

- (IBAction)okButtonPressed:(id)sender {
    NSString *originalName = self.userName;
    NSLog(@"Saving the user name on OK press: %@", self.userNameField.stringValue);
    if([self saveNewUserName:self.userNameField.stringValue]){
        self.userName = self.userNameField.stringValue;
    } else {
        self.userNameField.stringValue = originalName;
    }
    
    AppDelegate *appD = [[NSApplication sharedApplication] delegate];
    [appD closePreferencesWindow];
}

- (IBAction)cancelButtonPressed:(id)sender {
    AppDelegate *appD = [[NSApplication sharedApplication] delegate];
    [appD closePreferencesWindow];
}

-(BOOL)saveNewUserName:(NSString *) newName{
    if([self validateStringInput:newName]){
        [self->userObj setValue:newName forKey:@"userName"];
        NSError *saveError = nil;
        if (![userObj.managedObjectContext save:&saveError]) {
            NSLog(@"Unable to save managed object context.");
            NSLog(@"%@, %@", saveError, saveError.localizedDescription);
            return NO;
        } else {
            NSLog(@"Succesfully saved user in context: %@", userObj.managedObjectContext);
            return YES;
        }
    } else {
        return NO;
    }
}

- (BOOL) validateStringInput:(NSString *)str{
    // check to see if it's only whitespace characters
    if([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        return NO;
    }
    return YES;
}

@end

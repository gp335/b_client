//
//  AppDelegate.h
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"
#import "FriendListViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // DB scheme
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // workspace for our objects
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // objects we manipulate

// We hold references to the two primary view controllers in the AppDelegate so
// that the two classes (which are really singletons) can communicate with
// each other
@property (weak, nonatomic) ViewController *messagesViewController;
@property (weak, nonatomic) FriendListViewController *friendListViewController;

@end


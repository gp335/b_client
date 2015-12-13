//
//  AppDelegate.h
//  molo
//
//  Created by Geoffrey Peterson on 6/11/15.
//  Copyright (c) 2015 GLP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // DB scheme
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // workspace for our objects
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // objects we manipulate


@end


//
//  MessageDatabase.h
//  molo
//
//  Created by Geoffrey Peterson on 12/16/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

#pragma mark - constants
extern NSInteger const initialNumMsgsToLoad;
extern NSString *const MessageDatabaseInsertError;
extern NSString *const msgStateUnsent;
extern NSString *const msgStateToGateway;
extern NSString *const msgStateQueuedAtGateway;
extern NSString *const msgStateToServer;
extern NSString *const msgStateQueuedAtServer;
extern NSString *const msgStateReceivedByContact;

extern NSString *const MessageDatabaseChangeNotification;

@interface MessageDatabase : NSObject

// used to implement the singleton design pattern
+ (id) sharedInstance;

// Used to pull in messages in sequential order for view controllers
- (NSString *) msgAtIndex:(NSInteger)index objectForKey:(NSString *)key forContactID:(NSString *)cID;

// Used to pull in the list of friends for view controllers
- (NSString *) contactNameAtIndex:(NSInteger)index;

// Used to pull in the list of friends for view controllers
- (NSManagedObject *) contactObjectAtIndex:(NSInteger)index;

// Used to see how many messages we have stored in memory
- (NSInteger) numMsgsInMemoryForContactID: (NSString *)cID;

// Used to see how many contacts we have stored in memory
- (NSInteger) numContactsInMemory;

// Used to push a new message into the database from the sender
- (NSString *) newMsg:(NSString *)msgString toContactID:(NSString *) cID;

// Used to create a new message ID
- (NSString *)genMsgID;

@end

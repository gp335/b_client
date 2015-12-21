//
//  MessageDatabase.m
//  molo
//
//  Created by Geoffrey Peterson on 12/16/15.
//  Copyright © 2015 GLP. All rights reserved.
//

// here is where I should pull messages regarding DB updates.  and then this is where the notifications happen.

#import "MessageDatabase.h"
#include <stdlib.h>
@import AppKit;
@import CoreData;

NSInteger const initialNumMsgsToLoad = 100;
NSString *const MessageDatabaseInsertError = @"MDBInsertError";

NSString *const msgStateUnsent = @"MsgStateUnsent";
NSString *const msgStateToGateway = @"msgStateToGateway";
NSString *const msgStateQueuedAtGateway = @"msgStateQueuedAtGateway";
NSString *const msgStateToServer = @"msgStateToServer";
NSString *const msgStateQueuedAtServer = @"msgStateQueuedAtServer";
NSString *const msgStateReceivedByContact = @"msgStateReceivedByContact";
NSString *const msgStateReadByContact = @"msgStateReadByContact";

NSString *const MessageDatabaseChangeNotification = @"MessageDatabaseChangeNotification";
NSString *const MessageDatabaseContactAlertNotification = @"MessageDatabaseContactAlertNotification";

@implementation MessageDatabase {
    NSManagedObjectContext *managedObjectContext;
    // _allMsgsInMemory maps from contactLocalID -> an array of messages in that conversation
    NSMutableDictionary *_allMsgsInMemory;
    // same as above, but just holds the message ID of the most recent INBOUND message
    NSMutableDictionary *_allMostRecentMsgsInMemory;
    // dictionary that maps from contactLocalID to the managed object contacts
    NSMutableDictionary *_managedObjectContacts;
}


+ (id) sharedInstance{
    static dispatch_once_t token;
    static MessageDatabase *sharedInstance = nil;
    dispatch_once(&token, ^{
        sharedInstance = [[MessageDatabase alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        self->managedObjectContext = [[[NSApplication sharedApplication] delegate] managedObjectContext];

        self->_managedObjectContacts = [[NSMutableDictionary alloc] init];
        NSFetchRequest *fetchContactsRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self->managedObjectContext];
        [fetchContactsRequest setEntity:entity];
        NSError *contactsError = nil;
        NSArray *contactsResult = [self->managedObjectContext executeFetchRequest:fetchContactsRequest error:&contactsError];
        if (contactsError) {
            NSLog(@"Unable to execute contacts fetch request.");
            NSLog(@"%@, %@", contactsError, contactsError.localizedDescription);
        } else {
            NSLog(@"Contacts result: %@", contactsResult);
            // TODO: remove before shipping :)
            // The below clause is so that we can start the database with a few examples....
            if(0 == [contactsResult count]){
                [self populateTestMDB];
                contactsResult = [self->managedObjectContext executeFetchRequest:fetchContactsRequest error:&contactsError];
                if (contactsError) {
                    NSLog(@"Unable to execute contacts fetch request after populating the testDB.");
                    NSLog(@"%@, %@", contactsError, contactsError.localizedDescription);
                }
            }
            // Hold onto the contacts we got from the database
            for(NSManagedObject *contactObject in contactsResult){
                [self->_managedObjectContacts setObject:contactObject forKey:[contactObject valueForKey:@"contactLocalID"]];
            }
        }

        self->_allMsgsInMemory = [[NSMutableDictionary alloc] init];
        self->_allMostRecentMsgsInMemory = [[NSMutableDictionary alloc] init];

        [self loadMessages];
        
        // Listen for any new messages that are inserted into the DB
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMsgInDB:) name:NSManagedObjectContextDidSaveNotification object:self->managedObjectContext];
    }
    NSLog(@"Finished initializing the message database");
    return self;
}


- (NSString *) msgAtIndex:(NSInteger)index objectForKey:(NSString *)key forContactID:(NSString *)cID{
    NSString *returnString = [[[self->_allMsgsInMemory objectForKey:cID] objectAtIndex:index] objectForKey:key];
//    NSLog(@"About to return string %@ for index %li, key: %@, and contactID: %@", returnString, index, key, cID);
//    NSLog(@"The full message index is: %@", self->_allMsgsInMemory);
    return returnString;
}


// Function assumes it's given an index that is within the number of contacts
- (NSManagedObject *) contactObjectAtIndex:(NSInteger)index{
    NSArray *sortedContactArray = [self sortedContactObjects];
    assert(index < [sortedContactArray count] && index >= 0);
    return sortedContactArray[index];
}

- (NSString *) contactNameAtIndex:(NSInteger)index{
    return [[self contactObjectAtIndex:index] valueForKey:@"contactName"];
}

- (NSNumber *) indexForContactID:(NSString *)cID{
    NSArray *sortedContactArray = [self sortedContactObjects];
    NSInteger index = 0;
    for(NSManagedObject *curContactObj in sortedContactArray){
        if([cID isEqualToString:[curContactObj valueForKey:@"contactLocalID"]]){
            return [[NSNumber alloc] initWithInteger:index];
        }
        index++;
    }
    return [[NSNumber alloc] initWithInteger:-1];
}

// This is the method to always use to return a sorted list of contact objects
-(NSArray *)sortedContactObjects{
    NSArray *contactArray = [self->_managedObjectContacts allValues];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: [[NSSortDescriptor alloc] initWithKey:@"contactName" ascending:YES], nil];
    NSArray *sortedContactArray = [contactArray sortedArrayUsingDescriptors:sortDescriptors];
    return sortedContactArray;
}


// call this if we need to pull messages into the store
- (void) loadMessages {
    // Run through all the contacts and pull their messages
    for(NSManagedObject *contactObj in [self->_managedObjectContacts allValues]){
        NSLog(@"Loading messages for contact name: %@ and ID: %@", [contactObj valueForKey:@"contactName"], [contactObj valueForKey:@"contactLocalID"]);
        NSMutableSet *msgSet = [contactObj mutableSetValueForKey:@"messages"];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: [[NSSortDescriptor alloc] initWithKey:@"msgTimeSent" ascending:YES], nil];
        NSArray *sortedMsgArray = [msgSet sortedArrayUsingDescriptors:sortDescriptors];
        
        NSMutableArray *cummArray = [[NSMutableArray alloc] init];
        NSManagedObject *mostRecentObj;
        for(NSManagedObject *msgObj in sortedMsgArray){
            if([[msgObj valueForKey:@"isInbound"] isEqual: @YES]){
                [cummArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:[msgObj valueForKey:@"msgContent"],@"key1",@"",@"key2",nil] atIndex:0];
                mostRecentObj = msgObj;
            } else {
                [cummArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",[msgObj valueForKey:@"msgContent"],@"key2",nil] atIndex:0];
            }
        }
        [self->_allMsgsInMemory setObject:cummArray forKey:[contactObj valueForKey:@"contactLocalID"]];
        [self->_allMostRecentMsgsInMemory setObject:[mostRecentObj valueForKey:@"msgLocalID"] forKey:[contactObj valueForKey:@"contactLocalID"]];
    }
}


- (NSInteger) numMsgsInMemoryForContactID:(NSString *)cID{
    return [[self->_allMsgsInMemory objectForKey:cID] count];
}

// Used to see how many contacts we have stored in memory
- (NSInteger) numContactsInMemory{
    return [self->_managedObjectContacts count];
}


- (NSString *) newMsg:(NSString *)msgString toContactID:(NSString *) cID{
    
    NSEntityDescription *entityMessageDescription = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self->managedObjectContext];
    NSManagedObject *newMessage = [[NSManagedObject alloc] initWithEntity:entityMessageDescription insertIntoManagedObjectContext:self->managedObjectContext];
    
    [newMessage setValue:msgString forKey:@"msgContent"];
    [newMessage setValue:[NSDate date] forKey:@"msgTimeSent"];
    [newMessage setValue:[self genMsgID] forKey:@"msgLocalID"];
    [newMessage setValue:@NO forKey:@"isInbound"];
    [newMessage setValue:msgStateUnsent forKey:@"msgState"];
    
    // add to existing messages
    NSManagedObject *contact = [self->_managedObjectContacts objectForKey:cID];
    NSMutableSet *msgs = [contact mutableSetValueForKey:@"messages"];
    [msgs addObject:newMessage];
    [contact setValue:msgs forKey:@"messages"];
     
    // save it all to the persistent store
    NSError *msgError = nil;
    if (![newMessage.managedObjectContext save:&msgError]) {
        NSLog(@"Unable to save managed object context for new message.");
        NSLog(@"%@, %@", msgError, msgError.localizedDescription);
        return MessageDatabaseInsertError;
    } else {
//        NSLog(@"Succesfully saved message in context: %@", newMessage.managedObjectContext);
    }
    NSError *contactError = nil;
    if (![contact.managedObjectContext save:&contactError]) {
        NSLog(@"Unable to save managed object context for new message at contact.");
        NSLog(@"%@, %@", contactError, contactError.localizedDescription);
        return MessageDatabaseInsertError;
    } else {
//        NSLog(@"Succesfully saved new set of messages in context: %@", contact.managedObjectContext);
    }
    
    return [newMessage valueForKey:@"msgLocalID"];
}


// You should check to make sure that this guy is only called when the database has no contacts... otherwise undefined behavior can occur.
- (void) populateTestMDB{
    // 1a - The contacts we'll populate the db with first
    NSString *contact1Name = @"John";
    NSString *contact1LocalID = @"1a1a1a";
    
    NSString *contact2Name = @"Ethel";
    NSString *contact2LocalID = @"2b2b2b";
    
    // 1c - Push the contact into the persistent store
    NSEntityDescription *entityContactDescription = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self->managedObjectContext];
    NSManagedObject *newContact1 = [[NSManagedObject alloc] initWithEntity:entityContactDescription insertIntoManagedObjectContext:self->managedObjectContext];
    [newContact1 setValue:contact1Name forKey:@"contactName"];
    [newContact1 setValue:contact1LocalID forKey:@"contactLocalID"];

    NSManagedObject *newContact2 = [[NSManagedObject alloc] initWithEntity:entityContactDescription insertIntoManagedObjectContext:self->managedObjectContext];
    [newContact2 setValue:contact2Name forKey:@"contactName"];
    [newContact2 setValue:contact2LocalID forKey:@"contactLocalID"];
    
    // 2a - The messages we'll populate the db with first
    NSArray *msgStrings1 = [[NSArray alloc] initWithObjects: @"What up dog!", @"Not much how about you?", @"Just netflix and cooling.", @"Sweet.", nil];
    NSArray *msgStrings2 = [[NSArray alloc] initWithObjects: @"O hai!", @"Hai back", @"Looking good.", @"KTHNXSBAI.", nil];
    NSDate *dateNow = [NSDate date];
    NSArray *dateArray = [[NSArray alloc] initWithObjects:  dateNow, [dateNow dateByAddingTimeInterval:-10],
                                                            [dateNow dateByAddingTimeInterval:-20],
                                                            [dateNow dateByAddingTimeInterval:-30], nil];
    NSLog(@"Initializing DB with contact 1 messages: %@", msgStrings1);
    NSLog(@"Initializing DB with contact 2 messages: %@", msgStrings2);
    // 2b - Push the messages into the persistent store
    NSMutableSet *msgSet1 = [[NSMutableSet alloc] init];
    NSMutableSet *msgSet2 = [[NSMutableSet alloc] init];
    NSEntityDescription *entityMessageDescription = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self->managedObjectContext];
    for(int i = 0; i < 4; i++){
        NSManagedObject *newMessage1 = [[NSManagedObject alloc] initWithEntity:entityMessageDescription insertIntoManagedObjectContext:self->managedObjectContext];
        [newMessage1 setValue:msgStrings1[i] forKey:@"msgContent"];
        [newMessage1 setValue:dateArray[i] forKey:@"msgTimeSent"];
        [newMessage1 setValue:[dateArray[i] dateByAddingTimeInterval:-2] forKey:@"msgTimeReceived"];
        [newMessage1 setValue:[self genMsgID] forKey:@"msgLocalID"];
        [newMessage1 setValue:msgStateReceivedByContact forKey:@"msgState"];
        if(i % 2 == 0){
            [newMessage1 setValue:@YES forKey:@"isInbound"];
        } else {
            [newMessage1 setValue:@NO forKey:@"isInbound"];
        }
        [msgSet1 addObject:newMessage1];

        NSManagedObject *newMessage2 = [[NSManagedObject alloc] initWithEntity:entityMessageDescription insertIntoManagedObjectContext:self->managedObjectContext];
        [newMessage2 setValue:msgStrings2[i] forKey:@"msgContent"];
        [newMessage2 setValue:dateArray[i] forKey:@"msgTimeSent"];
        [newMessage2 setValue:[dateArray[i] dateByAddingTimeInterval:-2] forKey:@"msgTimeReceived"];
        [newMessage2 setValue:[self genMsgID] forKey:@"msgLocalID"];
        [newMessage2 setValue:msgStateReceivedByContact forKey:@"msgState"];
        if(i % 2 == 0){
            [newMessage2 setValue:@YES forKey:@"isInbound"];
        } else {
            [newMessage2 setValue:@NO forKey:@"isInbound"];
        }
        [msgSet2 addObject:newMessage2];

    }
    NSLog(@"Have new set of 1 messages: %@", msgSet1);
    NSLog(@"Have new set of 2 messages: %@", msgSet2);
    
    // 3 - Link the messages to the contact
    [newContact1 setValue:[NSSet setWithSet:msgSet1] forKey:@"messages"];
    [newContact2 setValue:[NSSet setWithSet:msgSet2] forKey:@"messages"];
    
    // 4 - Save it all
    NSError *error = nil;
    if (![newContact1.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"Succesfully saved message in context: %@", newContact1.managedObjectContext);
    }
    if (![newContact2.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"Succesfully saved message in context: %@", newContact2.managedObjectContext);
    }

}

- (NSString *)genMsgID{
    return [NSString stringWithFormat:@"%X%X%X%X", arc4random_uniform(INT_MAX), arc4random_uniform(INT_MAX), arc4random_uniform(INT_MAX), arc4random_uniform(INT_MAX)];
}

- (void) newMsgInDB:(NSNotification *) notification{
    NSLog(@"Got notification in DB: %@", notification);
    NSMutableDictionary *old_allMostRecentMsgsInMemory = [self->_allMostRecentMsgsInMemory mutableCopy];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:notification.object];
    BOOL aContactHasANewMessage = NO;
    @try {
        NSSet *insertedManagedObjects = [[notification valueForKey:@"userInfo"] valueForKey:NSInsertedObjectsKey];
        // For now we don't really have any use here for updated objects... but that may change in the future
        // We will want these once we start working with updating message status
//        NSSet *updatedManagedObjects = [[notification valueForKey:@"userInfo"] valueForKey:NSUpdatedObjectsKey];
        for(NSManagedObject *obj in insertedManagedObjects){
            if([[obj entity] isEqual:messageEntity]){
                NSLog(@"We have at least one new message: %@", [obj valueForKey:@"msgContent"]);
                // TODO: this is really overkill...there are better ways to get new messages into memory
                // but I'll deal with that once it becomes an issue
                [self loadMessages];
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageDatabaseChangeNotification object:nil];
                aContactHasANewMessage = YES;
                break; // once we've found one new message, [self loadMessages] will have caught all of them
            }
        }
    }
    @catch(NSException *exception) {
        NSLog(@"Threw this exception in the handling of a [MESSAGE] notification from store to DB: %@", exception);
    }
    // with the copy of the contact database, we move through it and delete items that haven't changed
    // and then pass on to the friendListViewController just those key/value pairs that have changed
    // the below assumes that loadMessages has already occurred and therefore that _allMostRecentMsgsInMemory was changed
    if(aContactHasANewMessage){
        @try{
            for(NSString *currContactLocalID in [self->_managedObjectContacts allKeys]){
                NSLog(@"checking on contactID: %@ which has current: %@ and past: %@", currContactLocalID, [self->_allMostRecentMsgsInMemory valueForKey:currContactLocalID], [old_allMostRecentMsgsInMemory valueForKey:currContactLocalID]);
                if([[self->_allMostRecentMsgsInMemory valueForKey:currContactLocalID] isEqualToString:[old_allMostRecentMsgsInMemory valueForKey:currContactLocalID]]){
                    [old_allMostRecentMsgsInMemory removeObjectForKey:currContactLocalID];
                }
            }
            if([old_allMostRecentMsgsInMemory count] > 0){
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageDatabaseContactAlertNotification object:self userInfo:old_allMostRecentMsgsInMemory];
            }
        }
        @catch (NSException *exception){
            NSLog(@"Threw this exception in the handling of a [CONTACT] notification from store to DB: %@", exception);
        }
    }
}


@end

//
//  MessageDatabase.m
//  molo
//
//  Created by Geoffrey Peterson on 12/16/15.
//  Copyright © 2015 GLP. All rights reserved.
//

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


@implementation MessageDatabase {
    NSManagedObjectContext *managedObjectContext;
    NSMutableDictionary *_allMsgsInMemory;
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

        [self loadMessages];
    }
    NSLog(@"Finished initializing the message database");
    return self;
}

// Used to pull in messages in sequential order for view controllers
- (NSString *) msgAtIndex:(NSInteger)index objectForKey:(NSString *)key forContactID:(NSString *)cID{
    return [[[self->_allMsgsInMemory objectForKey:cID] objectAtIndex:index] objectForKey:key];
}

// call this if we need to pull more messages into the store
- (void) loadMessages {
    
    // Run through all the contacts
    for(NSManagedObject *contactObj in [self->_managedObjectContacts allValues]){
        NSLog(@"Loading messages for contact name: %@ and ID: %@", [contactObj valueForKey:@"contactName"], [contactObj valueForKey:@"contactLocalID"]);
        NSMutableSet *msgSet = [contactObj mutableSetValueForKey:@"messages"];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: [[NSSortDescriptor alloc] initWithKey:@"msgTimeReceived" ascending:NO], nil];
        NSArray *sortedMsgArray = [msgSet sortedArrayUsingDescriptors:sortDescriptors];
        NSLog(@"Sorted msg array came back as: %@", sortedMsgArray);
        [self->_allMsgsInMemory setObject:[msgSet sortedArrayUsingDescriptors:sortDescriptors] forKey:[contactObj valueForKey:@"contactLocalID"]];
        
        NSMutableArray *cummArray = [[NSMutableArray alloc] init];
        for(NSManagedObject *msgObj in sortedMsgArray){
            if([[msgObj valueForKey:@"isInbound"] isEqual: @NO]){
                [cummArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",[msgObj valueForKey:@"msgContent"],@"key2",nil] atIndex:0];
            } else {
                [cummArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:[msgObj valueForKey:@"msgContent"],@"key1",@"",@"key2",nil] atIndex:0];
            }
        }
        [self->_allMsgsInMemory setObject:cummArray forKey:[contactObj valueForKey:@"contactLocalID"]];
    }
    
    NSLog(@"All messages are now: %@", self->_allMsgsInMemory);
}


- (NSInteger) numMsgsInMemoryForContactID:(NSString *)cID{
    return [[self->_allMsgsInMemory objectForKey:cID] count];
}


- (NSString *) newMsg:(NSString *)msgString toContactID:(NSString *) cID{
    
    NSEntityDescription *entityMessageDescription = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self->managedObjectContext];
    NSManagedObject *newMessage = [[NSManagedObject alloc] initWithEntity:entityMessageDescription insertIntoManagedObjectContext:self->managedObjectContext];
    
    [newMessage setValue:msgString forKey:@"msgContent"];
    [newMessage setValue:[NSDate date] forKey:@"msgTimeSent"];
    [newMessage setValue:[NSNumber numberWithInt:arc4random_uniform(4098)] forKey:@"msgLocalID"];
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
        NSLog(@"Succesfully saved message in context: %@", newMessage.managedObjectContext);
    }
    NSError *contactError = nil;
    if (![contact.managedObjectContext save:&contactError]) {
        NSLog(@"Unable to save managed object context for new message at contact.");
        NSLog(@"%@, %@", contactError, contactError.localizedDescription);
        return MessageDatabaseInsertError;
    } else {
        NSLog(@"Succesfully saved new set of messages in context: %@", contact.managedObjectContext);
    }
    
    // also insert it into the in-memory object
    [[self->_allMsgsInMemory objectForKey:cID] insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",msgString,@"key2", nil] atIndex:0];
    return [[newMessage valueForKey:@"msgLocalID"] stringValue];
}


- (void) populateTestMDB{
    // 1a - The contacts we'll populate the db with first
    NSString *contactName = @"John";
    NSString *contactLocalID = @"1a1a1a";
    
    // 1b - Check to make sure that the DB hasn't already been initialized
    // TODO - implement this
    
    // 1c - Push the contact into the persistent store
    NSEntityDescription *entityContactDescription = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self->managedObjectContext];
    NSManagedObject *newContact = [[NSManagedObject alloc] initWithEntity:entityContactDescription insertIntoManagedObjectContext:self->managedObjectContext];
    [newContact setValue:contactName forKey:@"contactName"];
    [newContact setValue:contactLocalID forKey:@"contactLocalID"];
    
    // 2a - The messages we'll populate the db with first
    NSArray *msgStrings = [[NSArray alloc] initWithObjects: @"What up dog!", @"Not much how about you?", @"Just netflix and cooling.", @"Sweet.", nil];
    NSDate *dateNow = [NSDate date];
    NSArray *dateArray = [[NSArray alloc] initWithObjects:  [dateNow dateByAddingTimeInterval:-30],
                                                            [dateNow dateByAddingTimeInterval:-20],
                                                            [dateNow dateByAddingTimeInterval:-10],
                                                            dateNow, nil];
    NSLog(@"Initializing DB with messages: %@", msgStrings);
    
    // 2b - Push the messages into the persistent store
    NSMutableSet *msgSet = [[NSMutableSet alloc] init];
    NSEntityDescription *entityMessageDescription = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self->managedObjectContext];
    for(int i = 0; i < 4; i++){
        NSManagedObject *newMessage = [[NSManagedObject alloc] initWithEntity:entityMessageDescription insertIntoManagedObjectContext:self->managedObjectContext];
        [newMessage setValue:msgStrings[i] forKey:@"msgContent"];
        [newMessage setValue:dateArray[i] forKey:@"msgTimeSent"];
        [newMessage setValue:[dateArray[i] dateByAddingTimeInterval:-2] forKey:@"msgTimeReceived"];
        [newMessage setValue:[NSNumber numberWithInt:arc4random_uniform(4098)] forKey:@"msgLocalID"];
        [newMessage setValue:msgStateReceivedByContact forKey:@"msgState"];
        if(i % 2 == 0){
            [newMessage setValue:@YES forKey:@"isInbound"];
        } else {
            [newMessage setValue:@NO forKey:@"isInbound"];
        }
        [msgSet addObject:newMessage];
    }
    NSLog(@"Have new set of messages: %@", msgSet);
    
    // 3 - Link the messages to the contact
    [newContact setValue:[NSSet setWithSet:msgSet] forKey:@"messages"];
    
    // 4 - Save it all
    NSError *error = nil;
    if (![newContact.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"Succesfully saved message in context: %@", newContact.managedObjectContext);
    }
}

@end

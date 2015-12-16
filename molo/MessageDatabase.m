//
//  MessageDatabase.m
//  molo
//
//  Created by Geoffrey Peterson on 12/16/15.
//  Copyright © 2015 GLP. All rights reserved.
//

#import "MessageDatabase.h"
@import AppKit;

NSInteger const initialNumMsgsToLoad = 100;
NSString *const MessageDatabaseInsertError = @"MDBInsertError";


@implementation MessageDatabase {
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *_msgsInMemory;
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
        managedObjectContext = [[[NSApplication sharedApplication] delegate] managedObjectContext];
        // pull in the first set of messages
        self->_msgsInMemory = [[NSMutableArray alloc] init];
        [self loadMoreMessages: initialNumMsgsToLoad];
    }
    NSLog(@"Finished initializing the message database");
    return self;
}

// Used to pull in messages in sequential order for view controllers
- (NSString *) msgAtIndex:(NSInteger)index objectForKey:(NSString *)key{
    NSLog(@"Looking for index %li with key: %@", index, key);
    return [[self->_msgsInMemory objectAtIndex:index] objectForKey:key];
}

// call this if we need to pull more messages into the store
- (void) loadMoreMessages:(NSInteger) numMsgsToLoad {
    [self->_msgsInMemory insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",@"What up dog!",@"key2", nil] atIndex:0];
    [self->_msgsInMemory insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Not much how about you?",@"key1",@"",@"key2", nil] atIndex:0];
    [self->_msgsInMemory insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",@"Just netflix and cooling.",@"key2", nil] atIndex:0];
    [self->_msgsInMemory insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Sweet.",@"key1",@"",@"key2", nil] atIndex:0];
}

- (NSInteger) numMsgsInMemory{
    return [self->_msgsInMemory count];
}

- (NSString *) newMsg:(NSString *)msgString{
    [self->_msgsInMemory insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"key1",msgString,@"key2", nil] atIndex:0];
    return @"TESTID";
}

@end

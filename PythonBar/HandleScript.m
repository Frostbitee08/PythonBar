//
//  Script.m
//  PythonBar
//
//  Created by Rocco Del Priore on 8/29/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "HandleScript.h"
#import "AppDelegate.h"
#import <CoreServices/CoreServices.h>


@implementation HandleScript
@synthesize title, timesRan, path, shortCut, isSubscript, methods, index;

static NSString *serializationKey = @"PythonBarKey";
static NSString *indexKey = @"index";
static NSString *pathKey = @"path";
static NSString *titleKey = @"title";
static NSString *shortcutKey = @"shortcutdata";
static NSString *timesRanKey = @"timesRan";
static NSString *isSubscriptKey = @"isSubscript";

#pragma mark - Initializers

//Initializers
- (id)init {
    self = [super init]; //always call the superclass init method when your class inherit from other class
    if (self) { // checking if the superclass initialization was fine
        cxt = [[AppDelegate sharedAppDelegate] managedObjectContext];
        title = @"No Title";
        timesRan = 0;
        isSubscript = false;
        shortCut = [[NSDictionary alloc] init];
    }
    return self;
}

//For addding a new script via path
- (void)setPathURL:(NSString *)givenPath isSubscript:(BOOL)aIsSubscript {
    //Set up initial Variables
    NSURL *givenURL = [[NSURL alloc] initWithString:givenPath];
    NSMutableString *scriptPath = [NSMutableString stringWithString:givenPath];
    
    if (floor(kCFCoreFoundationVersionNumber) > kCFCoreFoundationVersionNumber10_8) {
        [scriptPath deleteCharactersInRange:NSMakeRange(0, 7)];
    }
    else {
        [scriptPath deleteCharactersInRange:NSMakeRange(0, 16)];
    }

    //Get rid of %20
    NSRange twenty = [scriptPath rangeOfString:@"%20"];
    while (twenty.location != NSNotFound) {
        [scriptPath replaceCharactersInRange:twenty withString:@" "];
        twenty = [scriptPath rangeOfString:@"%20"];
    }

    path = scriptPath;
    methods = [[NSMutableArray alloc] init];
    isSubscript = aIsSubscript;
    
    //Create Title
    NSMutableString *filename = [[[givenURL absoluteString] lastPathComponent] mutableCopy];
    if ([filename length] > 3) {
        [filename deleteCharactersInRange:NSMakeRange(([filename length]-3), 3)];
    }
    
    twenty = [filename rangeOfString:@"%20"];
    while (twenty.location != NSNotFound) {
        [filename replaceCharactersInRange:twenty withString:@" "];
        twenty = [filename rangeOfString:@"%20"];
    }
    
    title = filename;
    [self getMethods];
    
    //Add to Core Data
    if (!isSubscript) {
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:shortCut forKey:serializationKey];
        [archiver finishEncoding];
        
        //Insert into context
        managedScript = [NSEntityDescription insertNewObjectForEntityForName:@"Script" inManagedObjectContext:cxt];
        [self save];
    }
}

//For adding script via core data
- (void)setManagedScript:(Script *)givenManagedScript {
    //Statics
    managedScript = givenManagedScript;
    path = [managedScript valueForKey:pathKey];
    title = [managedScript valueForKey:titleKey];
    NSNumber *browse = [managedScript valueForKey:isSubscriptKey];
    isSubscript = [browse boolValue];
    timesRan = [managedScript valueForKey:timesRanKey];
    shortCut = [managedScript valueForKey:shortcutKey];
    index = [managedScript valueForKey:indexKey];
    [self getMethods];
}

//Retrieve Methods from script
- (void)getMethods {
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    for (unsigned int i = 0; i<[lines count]; i++) {
        NSString *thisLine = [lines objectAtIndex:i];
        if ([thisLine length] >= 3) {
            NSString *prefix = [thisLine substringToIndex:3];
            if ([prefix isEqualToString:@"def"] && [thisLine rangeOfString:@"("].location != NSNotFound) {
                NSString *methodName = [thisLine substringToIndex:[thisLine rangeOfString:@"("].location];
                methodName = [methodName substringFromIndex:4];
                [methods addObject:methodName];
            }
        }
    }
}

#pragma mark - Accessors

- (NSString *)getPath {
    return path;
}

- (NSString *)getTitle {
    return title;
}

- (int)getTimesRan {
    int tr = [timesRan intValue];
    return tr;
}

- (bool)doesExist {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
        return true;
    }
    return false;
}

- (NSString *)getParentPath {
    NSString *parent = [path substringToIndex:[path rangeOfString:@"/" options:NSBackwardsSearch].location];
    parent = [parent stringByAppendingString:@"/"];
    return parent;
}

-(NSDictionary *)getShortCut {
    return shortCut;
}

#pragma mark - Modifiers

- (void)updateIndex:(int)newIndex {
    index = [NSNumber numberWithInt:newIndex];
    [self save];
}

- (void)changeShortcut:(NSDictionary*)aShortcut {
    shortCut = aShortcut;
    [self save];
}

- (void)addRun {
    int value = [timesRan intValue];
    timesRan = [NSNumber numberWithInt:value + 1];
    [self save];
}

- (void)removeFromContext {
    [[AppDelegate sharedAppDelegate] deleteManagedObject:managedScript];
}

- (void)save {
    if (!isSubscript) {
        //Update values
        [managedScript setValue:index forKey:indexKey];
        [managedScript setValue:path forKey:pathKey];
        [managedScript setValue:title forKey:titleKey];
        [managedScript setValue:[NSNumber numberWithBool:isSubscript] forKey:isSubscriptKey];
        [managedScript setValue:timesRan forKey:timesRanKey];
        [managedScript setValue:shortCut forKey:shortcutKey];
        
        //Save context
        [[AppDelegate sharedAppDelegate] saveContext];
    }
}

@end


//
//  Script.m
//  PythonBar
//
//  Created by Rocco Del Priore on 8/29/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "HandelScript.h"
#import "AppDelegate.h"


@implementation HandelScript
@synthesize title, timesRan, path, shortCut, isSubscript, methods;

static NSString *serializationKey = @"PythonBarKey";
static NSString *pathKey = @"path";
static NSString *titleKey = @"title";
static NSString *shortcutKey = @"shortcutdata";
static NSString *timesRanKey = @"timesRan";
static NSString *isSubscriptKey = @"isSubscript";

#pragma mark - initializers

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
- (void)setPathURL:(NSString *)givenPath {
    //Set up initial Variables
    NSURL *givenURL = [[NSURL alloc] initWithString:givenPath];
    NSMutableString *scriptPath = [NSMutableString stringWithString:givenPath];
    [scriptPath deleteCharactersInRange:NSMakeRange(0, 16)];
    
    //Get rid of %20
    NSRange twenty = [scriptPath rangeOfString:@"%20"];
    while (twenty.location != NSNotFound) {
        [scriptPath replaceCharactersInRange:twenty withString:@" "];
        twenty = [scriptPath rangeOfString:@"%20"];
    }
    path = scriptPath;
    methods = [[NSMutableArray alloc] init];
    
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
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:shortCut forKey:serializationKey];
    [archiver finishEncoding];
    
    //Insert into context
    managedScript = [NSEntityDescription insertNewObjectForEntityForName:@"Script" inManagedObjectContext:cxt];
    [managedScript setValue:path forKey:pathKey];
    [managedScript setValue:title forKey:titleKey];
    [managedScript setValue:[NSNumber numberWithBool:isSubscript] forKey:isSubscriptKey];
    [managedScript setValue:timesRan forKey:timesRanKey];
    [managedScript setValue:shortCut forKey:shortcutKey];
    
    //Save Context
    [[AppDelegate sharedAppDelegate] saveContext];
}

//For adding script via core data
- (void)setManagedScript:(Script *)givenManagedScript {
    //Statics
    managedScript = givenManagedScript;
    path = [managedScript valueForKey:pathKey];
    title = [managedScript valueForKey:titleKey];
    isSubscript = [managedScript valueForKey:isSubscriptKey];
    timesRan = [NSNumber numberWithInt:[managedScript valueForKey:timesRanKey]];
    shortCut = [managedScript valueForKey:shortcutKey];
}

- (void)getMethods {
    NSString *fileContents = [NSString stringWithContentsOfFile:path];
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


//Accessors
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

-(NSDictionary *)getShortCut {
    return shortCut;
}

//Modifiers

- (void)changeShortcut:(NSDictionary*)aShortcut {
    shortCut = aShortcut;
    [self save];
}

- (void)addRun {
    int value = [timesRan intValue];
    timesRan = [NSNumber numberWithInt:value + 1];
}

- (void)save {
    //Update values
    [managedScript setValue:path forKey:pathKey];
    [managedScript setValue:title forKey:titleKey];
    [managedScript setValue:[NSNumber numberWithBool:isSubscript] forKey:isSubscriptKey];
    [managedScript setValue:timesRan forKey:timesRanKey];
    [managedScript setValue:shortCut forKey:shortcutKey];
    
    //Save context
    [[AppDelegate sharedAppDelegate] saveContext];
}

@end


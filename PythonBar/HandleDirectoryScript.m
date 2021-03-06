//
//  DirectoryScript.m
//  PythonBar
//
//  Created by Rocco Del Priore on 9/1/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "HandleDirectoryScript.h"
#import <CoreServices/CoreServices.h>
#import "AppDelegate.h"

@implementation HandleDirectoryScript
@synthesize title, subScripts, path, shortCut, timesRan, index;

static NSString *serializationKey = @"PythonBarKey";
static NSString *indexKey = @"index";
static NSString *pathKey = @"path";
static NSString *titleKey = @"title";
static NSString *shortcutKey = @"shortcutdata";
static NSString *timesRanKey = @"timesRan";

#pragma mark - Initializers

- (id)init {
    self = [super init]; //always call the superclass init method when your class inherit from other class
    if (self) { // checking if the superclass initialization was fine
        cxt = [[AppDelegate sharedAppDelegate] managedObjectContext];
        title = @"No Title";
        timesRan = 0;
        subScripts = [[NSMutableArray alloc] init];
        shortCut = [[NSDictionary alloc] init];
    }
    return self;
}

//For adding from GUI
- (void)setPathURL:(NSString *)givenPath {
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
    
    //Create Title
    NSString *filenames = [[givenURL absoluteString] lastPathComponent];
    NSMutableString *filename = [NSMutableString stringWithString:filenames];
    twenty = [filename rangeOfString:@"%20"];
    while (twenty.location != NSNotFound) {
        [filename replaceCharactersInRange:twenty withString:@" "];
        twenty = [filename rangeOfString:@"%20"];
    }
    
    //Set Title & Path
    title = filename;
    path = scriptPath;

    //Fill with subscripts
    //Loop Through and add each corresponding python file
    NSArray *filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableString *mutTemp;
    NSString *temp;
    
    //Fill Subscripts
    for (unsigned int i = 0; i < [filelist count]; i++) {
        temp = [filelist objectAtIndex: i];
        mutTemp = [NSMutableString stringWithString:temp];
        if ([mutTemp length] > 3) {
            [mutTemp deleteCharactersInRange:NSMakeRange(0, ([temp length]-3))];
        }
        NSMutableString *tempScriptPath = [[NSMutableString alloc] init];
        if([mutTemp isEqualToString:@".py"]) {
            tempScriptPath = [NSMutableString stringWithString:givenPath];
            NSString *space = [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempScriptPath appendString:space];
            
            HandleScript *script = [[HandleScript alloc] init];
            [script setPathURL:tempScriptPath isSubscript:true];
            
            //Add Script to subScripts
            [subScripts addObject:script];
        }
    }
    
    managedDirectoryScript = [NSEntityDescription insertNewObjectForEntityForName:@"DirectoryScript" inManagedObjectContext:cxt];
    [self save];
}

//For adding script via core data
- (void)setManagedDirectroyScript:(DirectoryScript *)givenManagedDirectoryScript {
    //Statics
    managedDirectoryScript = givenManagedDirectoryScript;
    path = [managedDirectoryScript valueForKey:pathKey];
    title = [managedDirectoryScript valueForKey:titleKey];
    timesRan = [NSNumber numberWithInt:[managedDirectoryScript valueForKey:timesRanKey]];
    index = [NSNumber numberWithInt:[managedDirectoryScript valueForKey:indexKey]];
    shortCut = [managedDirectoryScript valueForKey:shortcutKey];

    //Fill
    [self fill];
}

#pragma mark - Accessors

- (NSString *)getPath {
    return path;
}

- (NSString *)getTitle {
    return title;
}

- (NSMutableArray *)getSubScripts {
    return subScripts;
}

- (bool)doesExist {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark - Modifiers

- (void)removeFromContext {
    [[AppDelegate sharedAppDelegate] deleteManagedObject:managedDirectoryScript];
}

- (void)changeShortcut:(NSDictionary*)aShortcut {
    shortCut = aShortcut;
    [self save];
}

- (void)updateIndex:(int)newIndex {
    index = [NSNumber numberWithInt:newIndex];
    [self save];
}

- (void)fill {
    NSArray *filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableString *mutTemp;
    NSString *temp;
    NSString *givenPath = [@"file://localhost" stringByAppendingString:path];

    //Fill Subscripts
    for (unsigned int i = 0; i < [filelist count]; i++) {
        temp = [filelist objectAtIndex: i];
        mutTemp = [NSMutableString stringWithString:temp];
        if ([mutTemp length] > 3) {
            [mutTemp deleteCharactersInRange:NSMakeRange(0, ([temp length]-3))];
        }
        NSMutableString *tempScriptPath = [[NSMutableString alloc] init];
        if([mutTemp isEqualToString:@".py"]) {
            tempScriptPath = [NSMutableString stringWithString:givenPath];
            NSString *space = [tempScriptPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            space = [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempScriptPath appendString:space];
            
            HandleScript *script = [[HandleScript alloc] init];
            [script setPathURL:tempScriptPath isSubscript:true];
            
            //Add Script to subScripts
            [subScripts addObject:script];
        }
    }
}

- (void)save {
    [managedDirectoryScript setValue:index forKey:indexKey];
    [managedDirectoryScript setValue:path forKey:pathKey];
    [managedDirectoryScript setValue:title forKey:titleKey];
    [managedDirectoryScript setValue:timesRan forKey:timesRanKey];
    [managedDirectoryScript setValue:shortCut forKey:shortcutKey];
    
    [[AppDelegate sharedAppDelegate] saveContext];
}

@end

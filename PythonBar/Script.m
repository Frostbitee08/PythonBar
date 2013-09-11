//
//  Script.m
//  PythonBar
//
//  Created by Rocco Del Priore on 8/29/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "Script.h"


@implementation Script
@synthesize title, timesRan, path, shortCut;

//Modifiers
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

//Accessors
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
    //NSLog(@"%@", scriptPath);

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
    
    timesRan = 0;
}

@end


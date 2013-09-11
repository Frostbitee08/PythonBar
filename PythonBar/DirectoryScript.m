//
//  DirectoryScript.m
//  PythonBar
//
//  Created by Rocco Del Priore on 9/1/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "DirectoryScript.h"

@implementation DirectoryScript
@synthesize title, subScripts, path;

//Modifiers
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
    
    //Initialize Subscripts
    subScripts = [[NSMutableArray alloc] init];
    
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
            
            Script *script = [[Script alloc] init];
            [script setPathURL:tempScriptPath];
            
            //Add Script to subScripts
            [subScripts addObject:script];
        }
    }

}

@end

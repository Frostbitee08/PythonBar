//
//  DirectoryScript.h
//  PythonBar
//
//  Created by Rocco Del Priore on 9/1/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandleScript.h"
#import "DirectoryScript.h"

@interface HandleDirectoryScript : NSObject {
    //Stored
    NSString *path;
    NSString *title;
    NSNumber *timesRan;
    DirectoryScript *managedDirectoryScript;
    
    //Generated
    NSDictionary *shortCut;
    NSMutableArray *subScripts;
    
    //Core Data
    NSManagedObjectContext *cxt;
    SInt32 minor;
}

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDictionary *shortCut;
@property (nonatomic, retain) NSMutableArray *subScripts;
@property (nonatomic, retain) NSNumber * timesRan;

//Modifiers
- (void)setPathURL:(NSString *)givenPathURL;
- (void)setManagedDirectroyScript:(DirectoryScript *)givenManagedDirectoryScript;
- (void)changeShortcut:(NSDictionary*)aShortcut;
- (void)removeFromContext;

//Accessors
- (NSString *)getPath;
- (NSString *)getTitle;
- (NSMutableArray *)getSubScripts;
- (bool)doesExist;

@end

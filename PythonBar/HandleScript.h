//
//  Script.h
//  PythonBar
//
//  Created by Rocco Del Priore on 8/29/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Script.h"

@interface HandleScript : NSObject {
    //Stored
    NSString *path;
    NSString *title;
    NSNumber *timesRan;
    NSNumber *index;
    bool isSubscript;
    Script *managedScript;
    
    //Generated
    NSDictionary *shortCut;
    NSMutableArray *methods;
    
    //Core Data
    NSManagedObjectContext *cxt;
}

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDictionary *shortCut;
@property (nonatomic, retain) NSMutableArray *methods;
@property (nonatomic, retain) NSNumber * timesRan;
@property (nonatomic, readwrite) bool isSubscript;

//Initialzers
- (void)setPathURL:(NSString *)givenPath isSubscript:(BOOL)aIsSubscript;
- (void)setManagedScript:(Script *)givenManagedScript;

//Modifiers
- (void)changeShortcut:(NSDictionary*)aShortcut;
- (void)addRun;
- (void)removeFromContext;
- (void)setIsSubscript:(bool)aIsSubscript;
- (void)updateIndex:(int)newIndex;

//Accessors
- (NSString *)getPath;
- (NSString *)getTitle;
- (NSString *)getParentPath;
- (NSDictionary *)getShortCut;
- (int)getTimesRan;
- (bool)doesExist;

@end
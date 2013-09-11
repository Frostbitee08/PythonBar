//
//  DirectoryScript.h
//  PythonBar
//
//  Created by Rocco Del Priore on 9/1/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Script.h"

@interface DirectoryScript : NSObject {
    NSString *path;
    NSString *title;
    NSMutableArray *subScripts;
}

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSMutableArray *subScripts;

//Modifiers
- (void)setPathURL:(NSString *)givenPathURL;

//Accessors
- (NSString *)getPath;
- (NSString *)getTitle;
- (NSMutableArray *)getSubScripts;
- (bool)doesExist;

@end

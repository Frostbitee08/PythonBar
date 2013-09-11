//
//  Script.h
//  PythonBar
//
//  Created by Rocco Del Priore on 8/29/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Script : NSObject {
    NSString *path;
    NSString *title;
    NSString *shortCut;
    NSNumber *timesRan;
}

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * shortCut;
@property (nonatomic, retain) NSNumber * timesRan;

//Modifiers
- (void)setPathURL:(NSString *)givenPathURL;
- (void)setShortCut:(NSString *)shortCut;

//Accessors
- (NSString *)getPath;
- (NSString *)getTitle;
- (int)getTimesRan;
- (bool)doesExist;

@end

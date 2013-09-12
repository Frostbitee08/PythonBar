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
    NSDictionary *shortCut;
    NSNumber *timesRan;
}

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDictionary *shortCut;
@property (nonatomic, retain) NSNumber * timesRan;

//Modifiers
- (void)setPathURL:(NSString *)givenPathURL;
- (void)setShortCut:(NSDictionary *)shortCut;

//Accessors
- (NSString *)getPath;
- (NSString *)getTitle;
- (NSDictionary *)getShortCut;
- (int)getTimesRan;
- (bool)doesExist;

@end

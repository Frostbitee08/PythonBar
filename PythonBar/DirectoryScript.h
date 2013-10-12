//
//  DirectoryScript.h
//  PythonBar
//
//  Created by Rocco Del Priore on 10/9/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DirectoryScript : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSDictionary *shortcutdata;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * timesRan;

@end

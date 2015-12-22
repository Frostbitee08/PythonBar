//
//  Script.h
//  PythonBar
//
//  Created by Rocco Del Priore on 10/11/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Script : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * isSubscript;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSDictionary * shortcutdata;
@property (nonatomic, retain) NSNumber * timesRan;
@property (nonatomic, retain) NSString * title;

@end

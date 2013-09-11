//
//  runStuff.h
//  PythonBar
//
//  Created by Rocco Del Priore on 9/10/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface runStuff : NSObject {
    NSAlert *findAlert;
    
    //Data
    NSUInteger *_tempIndex;
    NSMutableArray *scriptPaths;
    NSMutableArray *scripts;
    NSString *savePath;
}

@end

//
//  RunSuff.h
//  PythonBar
//
//  Created by Rocco Del Priore on 9/11/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandleScript.h"
#import "HandleDirectoryScript.h"

@interface RunSuff : NSObject <NSUserNotificationCenterDelegate> {
    //IBObjects
    NSMenu *statusMenu;
    NSButton *notificationCheck;
    NSAlert *findAlert;
    
    //Data
    NSUserDefaults *defaults;
    NSMutableArray *scripts;
    NSImage *pythonDocument;
    
    //Temporary Data stored in Defaults
    NSMutableDictionary *preferences;
}

@property(readwrite, nonatomic) NSMutableArray *scripts;
@property(readwrite, nonatomic) NSMenu *statusMenu;
@property(readwrite, nonatomic) NSButton *notificationCheck;

//Actions
-(void)runAllInDirectory:(id)sender;
-(void)replaceScript:(id)sender;
-(void)findScript:(id)sender;
-(void)runScript:(id)sender;

@end

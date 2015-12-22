//
//  ScriptsTableController.h
//  PythonBar
//
//  Created by Rocco Del Priore on 9/1/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandleScript.h"
#import "HandleDirectoryScript.h"
#import "RunSuff.h"
#import "DeleteTableView.h"

//ShortCut
#import "ShortcutRecorder/ShortcutRecorder.h"
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>

@protocol ScriptsTableControllerDelegate <NSObject>

- (void)updateMenu;

@end

@interface ScriptsTableController : NSObject <NSTableViewDataSource, NSTableViewDelegate, SRRecorderControlDelegate> {
    DeleteTableView *ScriptTable;
    NSMutableArray *scripts;
    NSMenu *statusMenu;
    NSUserDefaults *defaults;
    NSButton *removeButton;
    SRValidator *validator;
    RunSuff *runner;
}

@property(nonatomic, retain, readwrite) NSMutableArray *scripts;
@property(nonatomic, retain, readwrite) NSMenu *statusMenu;
@property(nonatomic, retain, readwrite) RunSuff *runner;
@property (nonatomic, assign) id<ScriptsTableControllerDelegate> delegate;

- (void)setUp:(DeleteTableView *)aTableView;
- (void)removeAction;

@end

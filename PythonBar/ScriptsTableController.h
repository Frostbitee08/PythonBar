//
//  ScriptsTableController.h
//  PythonBar
//
//  Created by Rocco Del Priore on 9/1/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Script.h"
#import "DirectoryScript.h"
#import "RunSuff.h"

//ShortCut
#import "ShortcutRecorder/ShortcutRecorder.h"
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>

@interface ScriptsTableController : NSObject <NSTableViewDataSource, NSTableViewDelegate, SRRecorderControlDelegate> {
    NSTableView *ScriptTable;
    NSMutableArray *scripts;
    NSMutableDictionary *scriptsPaths;
    NSMenu *statusMenu;
    NSUserDefaults *defaults;
    SRValidator *validator;
    RunSuff *runner;
}

@property(nonatomic, retain, readwrite) NSMutableArray *scripts;
@property(nonatomic, retain, readwrite) NSMenu *statusMenu;
@property(nonatomic, retain, readwrite) RunSuff *runner;

@end

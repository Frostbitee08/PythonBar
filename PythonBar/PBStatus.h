//
//  PBStatus.h
//  PythonBar
//
//  Created by Rocco Del Priore on 5/30/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Script.h"
#import "DirectoryScript.h"
#import "ScriptsTableController.h"
#import "RunSuff.h"

@interface PBStatus:  NSView <NSMenuDelegate> {
    //IBOutlets
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSWindow *preferencesWindow;
    IBOutlet NSButton *notificationCheck;
    IBOutlet NSTableView *scriptTable;
    IBOutlet NSButton *removeButton;
    
    //Objects
    ScriptsTableController *stc;
    RunSuff *runner;
    NSPopover *popover;
    NSWindow *popoverWindow;
    NSAlert *findAlert;
    
    //Data
    NSUserDefaults *defaults;
    NSUInteger *_tempIndex;
    NSMutableArray *scripts;
    NSImage *pythonDocument;
    
    //Temporary Data stored in Defaults
    NSMutableDictionary *scriptPaths;
    NSMutableDictionary *preferences;
}

//Actions
-(void)prePopulate;
-(void)addBarItem:(NSURL *)path;
-(void)addBarDiretory:(NSURL *)path;
-(IBAction)remove:(id)sender;

//Show Windows
-(IBAction)quit:(id)sender;
-(IBAction)addItem:(id)sender;
-(IBAction)showPreferences:(id)sender;

@end

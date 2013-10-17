//
//  PBStatus.h
//  PythonBar
//
//  Created by Rocco Del Priore on 5/30/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandelScript.h"
#import "HandelDirectoryScript.h"
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
    NSMutableArray *scripts;
    NSImage *pythonDocument;
    
    //Temporary Data stored in Defaults
    NSMutableDictionary *preferences;
}

//Actions
-(void)addBarItem:(NSURL *)path;
-(void)addBarDiretory:(NSURL *)path;
-(IBAction)remove:(id)sender;

//Windows
-(IBAction)quit:(id)sender;
-(IBAction)addItem:(id)sender;
-(IBAction)showPreferences:(id)sender;

@end

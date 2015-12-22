//
//  PBStatus.h
//  PythonBar
//
//  Created by Rocco Del Priore on 5/30/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandleScript.h"
#import "HandleDirectoryScript.h"
#import "ScriptsTableController.h"
#import "RunSuff.h"
#import "DeleteTableView.h"

@interface PBStatus:  NSView <NSMenuDelegate, ScriptsTableControllerDelegate> {
    //IBOutlets
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSWindow *preferencesWindow;
    IBOutlet NSButton *notificationCheck;
    IBOutlet NSButton *removeButton;
    IBOutlet DeleteTableView *scriptTable;
    
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

//Windows
-(IBAction)quit:(id)sender;
-(IBAction)addItem:(id)sender;
-(IBAction)showPreferences:(id)sender;

@end

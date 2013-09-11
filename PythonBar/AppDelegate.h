//
//  AppDelegate.h
//  PythonBar
//
//  Created by Rocco Del Priore on 5/5/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBStatus.h"
#import "PopUpViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    //IBOutlets
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSButton *checkBox;
    IBOutlet NSButton *launchButton;
    
    //Test
    PBStatus *testThis;
    
    //Data
    NSStatusItem * statusItem;
    NSString *savePath;
    NSMutableDictionary *preferences;
}

@property (assign) IBOutlet NSWindow *window;

//Actions
- (IBAction) CheckBoxStatus:(id) send;

//Test
- (IBAction)showPopover:(id)sender;
- (IBAction)hidePopover:(id)sender;

@end

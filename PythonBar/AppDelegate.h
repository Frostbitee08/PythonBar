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
    NSString* libraryPath;
    NSStatusItem * statusItem;
    NSURL *savePath;
    NSMutableDictionary *preferences;
}

@property (assign) IBOutlet NSWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Actions
- (IBAction)CheckBoxStatus:(id) send;
- (void)saveContext;
- (void)deleteManagedObject:(NSManagedObject *)aManagedObject;
+ (AppDelegate *)sharedAppDelegate;

//Test
- (IBAction)showPopover:(id)sender;
- (IBAction)hidePopover:(id)sender;

@end

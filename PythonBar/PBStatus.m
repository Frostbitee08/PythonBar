//
//  PBStatus.m
//  PythonBar
//
//  Created by Rocco Del Priore on 5/30/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "PBStatus.h"
#import "PopUpViewController.h"
#import "AppDelegate.h"
#import "Script.h"
#import "DirectoryScript.h"

//ShortCut
#import "ShortcutRecorder/ShortcutRecorder.h"
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>

@implementation PBStatus

//Keys
static NSString *notificationKey = @"notfication";
static NSString *preferencesPathKey = @"preferencesPath";
static NSString *preferencesKey = @"preferences";

#pragma mark - Initial setup

- (id)init {
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    self = [super initWithFrame:NSMakeRect(0, 0, 20, height)];
    if (self) {
        //Initial Varibales
        NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PythonBar/"];
        NSString *preferencesPath = [libraryPath stringByAppendingString:@"/Settings.plist"];
        preferences = [[NSMutableDictionary alloc] init];
        scripts = [[NSMutableArray alloc] init];
        pythonDocument = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"python_document" ofType:@"png"]];
        
        //Defaults
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:preferencesPath forKey:preferencesPathKey];
    }
    return self;
}

-(void)awakeFromNib {
    [self getCoreData];
}

-(void)getCoreData {
    //Scripts
    NSManagedObjectContext* cxt = [[AppDelegate sharedAppDelegate] managedObjectContext];
    NSFetchRequest* scripts_request = [[NSFetchRequest alloc] initWithEntityName:@"Script"];
    for (unsigned int i = 0; i< [[cxt executeFetchRequest:scripts_request error:nil] count]; i++) {
        Script *tempScript = [[cxt executeFetchRequest:scripts_request error:nil] objectAtIndex:i];
        HandleScript *tempHandleScript = [[HandleScript alloc] init];
        [tempHandleScript setManagedScript:tempScript];
        if (![tempHandleScript isSubscript]) {
            [scripts addObject:tempHandleScript];
        }
    }
    
    //Script Directories
    NSFetchRequest* scriptsDirectory_request = [[NSFetchRequest alloc] initWithEntityName:@"DirectoryScript"];
    for (unsigned int i = 0; i< [[cxt executeFetchRequest:scriptsDirectory_request error:nil] count]; i++) {
        DirectoryScript *tempScript = [[cxt executeFetchRequest:scriptsDirectory_request error:nil] objectAtIndex:i];
        HandleDirectoryScript *tempHandleScript = [[HandleDirectoryScript alloc] init];
        [tempHandleScript setManagedDirectroyScript:tempScript];
        [scripts addObject:tempHandleScript];
    }
    [self setUp];
    [self prePopulate];
}

-(void)setUp {
    //Runner
    runner = [[RunSuff alloc] init];
    runner.scripts = scripts;
    runner.statusMenu = statusMenu;
    runner.notificationCheck = notificationCheck;
    
    //TableController
    stc = [[ScriptsTableController alloc] init];
     [scriptTable setDelegate:stc];
     [scriptTable setDataSource:stc];
     stc.runner = runner;
     stc.statusMenu = statusMenu;
     stc.scripts = scripts;
    
    //Fill Preferences
    NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:[defaults objectForKey:preferencesPathKey]];
    if ([[tempDict allKeys] count] > 0) {
        NSArray *keys = [tempDict allKeys];
        for (unsigned int g = 0; g<[keys count]; g++ ) {
            [preferences setObject:[tempDict objectForKey:[keys objectAtIndex:g]] forKey:[keys objectAtIndex:g]];
        }
    }
    [defaults setObject:preferences forKey:preferencesKey];
    
    [notificationCheck setState:[[[defaults objectForKey:preferencesKey] objectForKey:notificationKey] boolValue]];
}

-(void)prePopulate {
    //Loop through scripts and add all menuItems
    for (unsigned int i = 0; i<[scripts count]; i++) {
        if ([[scripts objectAtIndex:i] isMemberOfClass:[HandleScript class]]) {
            //Create NSMenuItem
            NSMenuItem *tempMenuItem = [[NSMenuItem alloc] init];
            [tempMenuItem setTarget:runner];
            [tempMenuItem setRepresentedObject:[scripts objectAtIndex:i]];
            [tempMenuItem setImage:pythonDocument];
            
            //Add color
            NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:i] getTitle]];
            [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:i] getTitle].length)];
            if ([[scripts objectAtIndex:i] doesExist]) {
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0,[[scripts objectAtIndex:i] getTitle].length)];
                [tempMenuItem setAction:@selector(runScript:)];
                
            }
            else {
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,[[scripts objectAtIndex:i] getTitle].length)];
                [tempMenuItem setAction:@selector(findScript:)];
            }
            [tempMenuItem setAttributedTitle:attributedTitle];
            
            if ([[[[scripts objectAtIndex:i] getShortCut] allKeys] count] > 0) {
                NSString *identifier = [NSString stringWithFormat:@"PythonBar-%@-%@", [[[scripts objectAtIndex:i] shortCut] valueForKey:SRShortcutKeyCode], [[[scripts objectAtIndex:i] shortCut] valueForKey:SRShortcutCharacters]];
                
                PTHotKeyCenter *hotKeyCenter = [PTHotKeyCenter sharedCenter];
                PTHotKey *oldHotKey = [hotKeyCenter hotKeyWithIdentifier:identifier];
                [hotKeyCenter unregisterHotKey:oldHotKey];
                
                PTHotKey *newHotKey = [PTHotKey hotKeyWithIdentifier:identifier
                                                            keyCombo:[[scripts objectAtIndex:i] getShortCut]
                                                              target:runner
                                                              action:tempMenuItem.action];
                
                [newHotKey setRepresentedObject:tempMenuItem];
                [hotKeyCenter registerHotKey:newHotKey];
                
                [tempMenuItem setKeyEquivalent:[[[scripts objectAtIndex:i] shortCut] valueForKey:SRShortcutCharacters   ]];
                
            }
            
            //Add NSMenuItem to StatusMenu
            [statusMenu insertItem:tempMenuItem atIndex:[statusMenu numberOfItems]-4];
        }
        else if ([[scripts objectAtIndex:i] isMemberOfClass:[HandleDirectoryScript class]]) {
            //Get DirectoryScript
            HandleDirectoryScript *tempDir = [scripts objectAtIndex:i];
            
            //Create Sub-Menu
            NSMenuItem *directoryMenuItem = [[NSMenuItem alloc] init];
            [directoryMenuItem setTitle:[tempDir getTitle]];
            [directoryMenuItem setRepresentedObject:tempDir];
            NSMenu *submenu = [[NSMenu alloc] init];
            
            //Add color
            NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:i] getTitle]];
            [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:i] getTitle].length)];
            if ([[scripts objectAtIndex:i] doesExist]) {
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0,[[scripts objectAtIndex:i] getTitle].length)];
                
                //Add Sub-Menus
                NSArray *subscript = [tempDir getSubScripts];
                for (unsigned int f = 0; f < [subscript count]; f++) {
                    //Get Script
                    HandleScript *tempScript = [subscript objectAtIndex:f];
                    
                    //Create submenu
                    NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
                    [tempMenuItem setTarget:runner];
                    [tempMenuItem setRepresentedObject:tempScript];
                    [tempMenuItem setImage:pythonDocument];
                    [submenu addItem:tempMenuItem];
                }
                
                //Add Run all
                [submenu addItem:[NSMenuItem separatorItem]];
                NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:@"Run All" action:@selector(runAllInDirectory:) keyEquivalent:@""];
                [tempMenuItem setTarget:runner];
                [tempMenuItem setRepresentedObject:tempDir];
                [submenu addItem:tempMenuItem];
                
                [directoryMenuItem setSubmenu:submenu];
            }
            else {
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,[[scripts objectAtIndex:i] getTitle].length)];
                [directoryMenuItem setTarget:runner];
                [directoryMenuItem setAction:@selector(findScript:)];
            }
            [directoryMenuItem setAttributedTitle:attributedTitle];
            
            //Add subMenu to StatusMenu
            [statusMenu insertItem:directoryMenuItem atIndex:[statusMenu numberOfItems]-4];
            
        }
    }
}

#pragma mark - Actions

-(void)addBarItem:(NSURL *)path {
    //Set Up Script
    HandleScript *tempScript = [[HandleScript alloc] init];
    [tempScript setPathURL:[path absoluteString] isSubscript:false];
    [tempScript setIsSubscript:false];
    [scripts addObject:tempScript];

    //Create NSMenuItem
    NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
    [tempMenuItem setTarget:runner];
    [tempMenuItem setRepresentedObject:tempScript];
    [tempMenuItem setImage:pythonDocument];

    //Add NSMenuItem to StatusMenu
    [statusMenu insertItem:tempMenuItem atIndex:[statusMenu numberOfItems]-4];
    
    //Update Preferences
    [scriptTable reloadData];
}

-(void)addBarDiretory:(NSURL *)path {
    //Set Up DirectoryScript
    HandleDirectoryScript *dirScript = [[HandleDirectoryScript alloc] init];
    [dirScript setPathURL:[path absoluteString]];
    [scripts addObject:dirScript];
    
    //Create Sub-Menu
    NSMenuItem *directoryMenuItem = [[NSMenuItem alloc] init];
    [directoryMenuItem setTitle:[dirScript getTitle]];
    NSMenu *submenu = [[NSMenu alloc] init];
    
    //Add Sub-Menus
    NSArray *subscript = [dirScript getSubScripts];
    for (unsigned int f = 0; f < [subscript count]; f++) {
        //Get Script
        HandleScript *tempScript = [subscript objectAtIndex:f];
        
        //Create submenu
        NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
        [tempMenuItem setTarget:runner];
        [tempMenuItem setRepresentedObject:tempScript];
        [tempMenuItem setImage:pythonDocument];
        [submenu addItem:tempMenuItem];
    }
    
    //Add Run all
    [submenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:@"Run All" action:@selector(runAllInDirectory:) keyEquivalent:@""];
    [tempMenuItem setTarget:runner];
    [tempMenuItem setRepresentedObject:dirScript];
    [submenu addItem:tempMenuItem];
    
    //Add subMenu to StatusMenu
    [directoryMenuItem setSubmenu:submenu];
    [directoryMenuItem setRepresentedObject:dirScript];
    [statusMenu insertItem:directoryMenuItem atIndex:[statusMenu numberOfItems]-4];
    
    //Update Preferences
    [scriptTable reloadData];
}

#pragma mark - Windows

//Show FileBrowser
-(IBAction)addItem:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    NSArray  *fileTypes = [NSArray arrayWithObject:@"py"];
    [panel setAllowedFileTypes:fileTypes];
    [panel setCanChooseDirectories:true];
    
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
        
            //Check to see if the script already exist
            bool contains = false;
            NSString *docString = [[theDoc absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            for (unsigned int i = 0; i<[scripts count]; i++) {
                NSString *t = [@"file://localhost" stringByAppendingString:[[scripts objectAtIndex:i] getPath]];
                if ([docString isEqualToString:t]) {
                    contains = true;
                    break;
                }
            }
            
            if (!contains) {
                NSString *temp = [[theDoc absoluteString] lastPathComponent];
                NSMutableString *filename = [NSMutableString stringWithString:temp];
                if([filename length] > 3) {
                    [filename deleteCharactersInRange:NSMakeRange(0, ([filename length]-3))];
                }
                if ([filename isEqual: @".py"]) {
                    [self addBarItem:theDoc];
                }
                else {
                    [self addBarDiretory:theDoc];
                }

            }
            else {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Duplicate Entry" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The script or directory that you have selected has already been added to PythonBar"];
                [alert runModal];
            }
        }
    }];
}

-(IBAction)showPreferences:(id)sender {
    [scriptTable reloadData];
    [preferencesWindow setIsVisible:true];
    [NSApp activateIgnoringOtherApps:YES]; //Make sure the prefence window is at front
}

-(IBAction)quit:(id)sender {
    [[AppDelegate sharedAppDelegate] saveContext];
    [NSApp terminate:self];
}


@end

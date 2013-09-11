//
//  PBStatus.m
//  PythonBar
//
//  Created by Rocco Del Priore on 5/30/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "PBStatus.h"
#import "PopUpViewController.h"

@implementation PBStatus

static NSString *notification = @"notfication";

//GIVEN
//
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)prePopulate {
    //Loop through scripts and add all menuItems
    for (unsigned int i = 0; i<[scripts count]; i++) {
        if ([[scripts objectAtIndex:i] isMemberOfClass:[Script class]]) {
            //Create NSMenuItem
            NSMenuItem *tempMenuItem = [[NSMenuItem alloc] init];
            [tempMenuItem setTarget:runner];
            [tempMenuItem setRepresentedObject:[[scripts objectAtIndex:i] getPath]];
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
            
            //Add NSMenuItem to StatusMenu
            [statusMenu insertItem:tempMenuItem atIndex:[statusMenu numberOfItems]-4];
        }
        else if ([[scripts objectAtIndex:i] isMemberOfClass:[DirectoryScript class]]) {
            //Get DirectoryScript
            DirectoryScript *tempDir = [scripts objectAtIndex:i];
            
            //Create Sub-Menu
            NSMenuItem *directoryMenuItem = [[NSMenuItem alloc] init];
            [directoryMenuItem setTitle:[tempDir getTitle]];
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
                    Script *tempScript = [subscript objectAtIndex:f];
                    
                    //Create submenu
                    NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
                    [tempMenuItem setTarget:runner];
                    [tempMenuItem setRepresentedObject:[tempScript getPath]];
                    [tempMenuItem setImage:pythonDocument];
                    [submenu addItem:tempMenuItem];
                }
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

-(void)awakeFromNib {
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
    
    if ([scripts count] > 0) {
        [self prePopulate];
    }
    [notificationCheck setState:[[[defaults objectForKey:@"preferences"] objectForKey:notification] boolValue]];
}

- (id)init {
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    self = [super initWithFrame:NSMakeRect(0, 0, 20, height)];
    if (self) {
        //Initial Varibales
        NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PythonBar/"];
        NSString *preferencesPath = [libraryPath stringByAppendingString:@"/Settings.plist"];
        NSString *savePath = [libraryPath stringByAppendingString:@"/Scripts.plist"];
        scriptPaths = [[NSMutableArray alloc] init];
        preferences = [[NSMutableDictionary alloc] init];
        
        //Defaults
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:savePath forKey:@"savePath"];
        [defaults setObject:preferencesPath forKey:@"preferencesPath"];
        
        scripts = [[NSMutableArray alloc] init];
        pythonDocument = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"python_document" ofType:@"png"]];
        
        //Fill Preferences
        NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:[defaults objectForKey:@"preferencesPath"]];
        if ([[tempDict allKeys] count] > 0) {
            NSArray *keys = [tempDict allKeys];
            for (unsigned int g = 0; g<[keys count]; g++ ) {
                [preferences setObject:[tempDict objectForKey:[keys objectAtIndex:g]] forKey:[keys objectAtIndex:g]];
            }
        }
        [defaults setObject:preferences forKey:@"preferences"];
        
        //Fill scriptPaths and scripts
        NSArray *temp =  [[NSArray alloc] initWithContentsOfFile:[defaults objectForKey:@"savePath"]];
        if ([temp count] > 0) {
            for (unsigned int i = 0; i<[temp count]; i++) {
                //Get File Type
                NSMutableString *mutTemp = [NSMutableString stringWithString:[temp objectAtIndex:i]];
                [mutTemp deleteCharactersInRange:NSMakeRange(0, ([mutTemp length]-3))];
                
                //If Python File
                if([mutTemp isEqualToString:@".py"]) {
                    Script *tempScript = [[Script alloc] init];
                    [tempScript setPathURL:[temp objectAtIndex:i]];
                    [scripts addObject:tempScript];
                }
                
                //If Directory
                else {
                    DirectoryScript *dirScript = [[DirectoryScript alloc] init];
                    [dirScript setPathURL:[temp objectAtIndex:i]];
                    [scripts addObject:dirScript];
                }
                
                //Add Path
                [scriptPaths addObject:[temp objectAtIndex:i]];
            }
        }
        [defaults setObject:scriptPaths forKey:@"scriptsPath"];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}


//
//Delegates
//

-(IBAction)remove:(id)sender {
    NSInteger *index = [scriptTable selectedRow];
    scriptPaths = [defaults objectForKey:@"scriptsPaths"];
    
    [scriptTable beginUpdates];
    [scriptTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectFade];
    [scriptTable endUpdates];
    [scripts removeObjectAtIndex:index];
    [scriptPaths removeObjectAtIndex:index];
    [defaults setObject:scriptPaths forKey:@"scriptsPaths"];
    [[defaults objectForKey:@"scriptsPaths"] writeToFile:[defaults objectForKey:@"savePath"] atomically:YES];
    [removeButton setHidden:TRUE];
    
    //Remove NSMenuItem
    [statusMenu removeItemAtIndex:index];
}


-(void)addBarItem:(NSURL *)path {
    //Set Up Script
    Script *tempScript = [[Script alloc] init];
    [tempScript setPathURL:[path absoluteString]];
  
    //Add to scripts and scriptPaths
    NSString *jap = [[NSString alloc] initWithString:[path absoluteString]];
    NSMutableArray *scriptsPath = [defaults objectForKey:@"scriptsPaths"];
    [scriptsPath addObject:jap];
    [scripts addObject:tempScript];

    //Create NSMenuItem
    NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
    [tempMenuItem setTarget:runner];
    [tempMenuItem setRepresentedObject:[tempScript getPath]];
    [tempMenuItem setImage:pythonDocument];

    //Add NSMenuItem to StatusMenu
    [statusMenu insertItem:tempMenuItem atIndex:[statusMenu numberOfItems]-4];

    //Save
    [defaults setObject:scriptsPath forKey:@"scriptsPaths"];
    [[defaults objectForKey:@"scriptsPaths"] writeToFile:[defaults objectForKey:@"savePath"] atomically:YES];
}

-(void)addBarDiretory:(NSURL *)path {
    //Set Up DirectoryScript
    DirectoryScript *dirScript = [[DirectoryScript alloc] init];
    [dirScript setPathURL:[path absoluteString]];
    
    //Create Sub-Menu
    NSMenuItem *directoryMenuItem = [[NSMenuItem alloc] init];
    [directoryMenuItem setTitle:[dirScript getTitle]];
    NSMenu *submenu = [[NSMenu alloc] init];
    
    //Add Sub-Menus
    NSArray *subscript = [dirScript getSubScripts];
    for (unsigned int f = 0; f < [subscript count]; f++) {
        //Get Script
        Script *tempScript = [subscript objectAtIndex:f];
        
        //Create submenu
        NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
        [tempMenuItem setTarget:runner];
        [tempMenuItem setRepresentedObject:[tempScript getPath]];
        [tempMenuItem setImage:pythonDocument];
        [submenu addItem:tempMenuItem];
    }
    
    //Add subMenu to StatusMenu
    [directoryMenuItem setSubmenu:submenu];
    [statusMenu insertItem:directoryMenuItem atIndex:[statusMenu numberOfItems]-4];
    
    //UpdateArrays
    NSString *jap = [[NSString alloc] initWithString:[path absoluteString]];
    scriptPaths = [defaults objectForKey:@"scriptsPaths"];
    [scriptPaths addObject:jap];
    [scripts addObject:dirScript];
    
    //Save
    [defaults setObject:scriptPaths forKey:@"scriptsPaths"];
    [[defaults objectForKey:@"scriptsPaths"] writeToFile:[defaults objectForKey:@"savePath"] atomically:YES];
}

//
//Show Windows
//

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
            if (![[defaults objectForKey:@"scriptsPaths"] containsObject:[theDoc absoluteString]]) {
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
    [NSApp terminate:self];
}


@end

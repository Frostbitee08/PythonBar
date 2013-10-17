//
//  RunSuff.m
//  PythonBar
//
//  Created by Rocco Del Priore on 9/11/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "RunSuff.h"
#import <Python/Python.h>

@implementation RunSuff
@synthesize scripts,notificationCheck,statusMenu;

static NSString *savePathKey = @"savePath";
static NSString *scriptsPathKey = @"scripts";

#pragma mark - Initial setup
- (id)init {
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
        pythonDocument = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"python_document" ofType:@"png"]];
    }
    return self;
}

#pragma mark - Run

-(void)runAllInDirectory:(id)sender {
    //Get the subMenuItems
    HandleDirectoryScript *runAll = (HandleDirectoryScript *)[sender representedObject];
    NSMenuItem *directoryMenuItem = [statusMenu itemWithTitle:[runAll getTitle]];
    NSMenu *directoryMenu = directoryMenuItem.submenu;
    NSArray *subitems = [directoryMenu itemArray];
    
    //Loop through scripts and run them
    for (unsigned int i = 0; i<[subitems count]-2; i++) {
        [self runScript:[subitems objectAtIndex:i]];
    }
}

-(void)runScript:(id)sender {
    //Make sure we have the right type
    if (![sender isMemberOfClass:[NSMenuItem class]]) {
        sender = [sender representedObject];
    }
    
    //Make sure we have Script
    NSMenuItem *tempItem = (NSMenuItem *)sender;
    HandleScript *runningScript = (HandleScript *)[tempItem representedObject];
    
    //Make sure Script exist
    if (![runningScript doesExist]) {
        //If Part of Directory
        if ([runningScript isSubscript]) {
            //Get Directory
            NSMenuItem *runAll = [tempItem.menu itemWithTitle:@"Run All"];
            HandleDirectoryScript *directoryScript = (HandleDirectoryScript *)[runAll representedObject];
            
            //Check if Directory exist
            if ([directoryScript doesExist]) {
                //Loop through all subscripts
                int count = 0;
                NSString *name = [runningScript getTitle];
                for (unsigned int i = 0; i <[directoryScript.subScripts count]; i++) {
                    HandleScript *tempScript = [directoryScript.subScripts objectAtIndex:i];
                    if (![tempScript doesExist]) {
                        [tempItem.menu removeItem:[tempItem.menu itemWithTitle:[tempScript getTitle]]];
                        [directoryScript.subScripts removeObject:tempScript];
                        i--;
                        count++;
                    }
                }
                //Run the Alert
                if (count > 1) {
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Script Missing" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"%@ and %i other scripts have been moved from their directory", name]];
                    [alert runModal];
                }
                else {
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Script Missing" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"%@ has been moved from the directory", name]];
                    [alert runModal];
                }
                return;
            }
            else {
                //Get MenuItem to modifiy
                NSMenuItem *missingDir = [statusMenu itemWithTitle:[directoryScript getTitle]];
                NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[directoryScript getTitle]];
                [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [directoryScript getTitle].length)];
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,[directoryScript getTitle].length)];
                [missingDir setAction:@selector(findScript:)];
                [missingDir setAttributedTitle:attributedTitle];
                [missingDir setSubmenu:nil];
                
                //Find Directory
                return [self findScript:runAll];
            }
        }
        else {
            //Change text color to red
            NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:index] getTitle]];
            [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:index] getTitle].length)];
            [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,[[scripts objectAtIndex:index] getTitle].length)];
            [sender setAction:@selector(findScript:)];
            [sender setAttributedTitle:attributedTitle];
            
            //Find document
            return [self findScript:sender];
        }
    }
    
    //Create Task
    NSString *scriptPath = [runningScript getPath];
    NSString *print = @" > ~/Desktop/MyLog.txt";
    NSTask* python = [[NSTask alloc] init];
    
    //Add properties
    NSPipe *scriptOutput = [NSPipe pipe];
    NSFileHandle *outFile; //this sets up a temp file
    python.launchPath = @"/usr/bin/python";
    python.arguments = [NSArray arrayWithObjects: scriptPath, print, nil];
    [python setStandardInput:[NSPipe pipe]];
    [python setStandardOutput:scriptOutput];
    outFile = [scriptOutput fileHandleForReading];
    
    //Run Script
    [python launch];
    [python waitUntilExit];
    
    //Get output
    NSData *outputData = [[scriptOutput fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    //If notifications is turned on
    NSString *ifOn = ([notificationCheck state] ? @"On" : @"Off");
    if ([ifOn isEqual: @"On"]){
        //Get title
        NSMutableString *title = [NSMutableString stringWithString:[sender title]];
        [title appendString:@" Finished Running!"];
        
        //Create Notification and add properties
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        if ([outputString length] > 0) {
            notification.informativeText = outputString;
        }
        else {
            notification.informativeText = nil;
        }
        notification.soundName = NSUserNotificationDefaultSoundName;
        
        //Create NotificationCenter and add notification
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center setDelegate:self];
        [center deliverNotification:notification];
    }
    
    //Increment
    [runningScript addRun];
}

#pragma mark - Missing

-(void)findScript:(id)sender {
    //Build Alert
    if ([[sender representedObject] isMemberOfClass:[HandleScript class]]) {
        findAlert = [NSAlert alertWithMessageText:@"Script Missing" defaultButton:@"Yes" alternateButton:nil otherButton:@"No" informativeTextWithFormat:@"PythonBar cannot find this script. Would you like to relocate it?"];
    }
    else if ([[sender representedObject] isMemberOfClass:[HandleDirectoryScript class]]) {
        findAlert = [NSAlert alertWithMessageText:@"Directory Missing" defaultButton:@"Yes" alternateButton:nil otherButton:@"No" informativeTextWithFormat:@"PythonBar cannot find this Directory. Would you like to relocate it?"];
    }

    
    //Set alert actions
    NSArray *buttonArray = [findAlert buttons];
    NSButton *myBtn = [buttonArray objectAtIndex:0];
    [myBtn setAction:@selector(replaceScript:)];
    [myBtn setTarget:self];
    [myBtn setTag:[scripts indexOfObject:[sender representedObject]]];

    //Run Alert
    [findAlert runModal];
}

-(void)replaceScript:(id)sender {
    [NSApp endSheet:[findAlert window]];
    
    //Open File browser
    NSButton *button = (NSButton *)sender;
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    NSArray  *fileTypes;
    if ([[scripts objectAtIndex:button.tag] isMemberOfClass:[HandleScript class]]) {
        fileTypes = [NSArray arrayWithObject:@"py"];
        [panel setAllowedFileTypes:fileTypes];
    }
    else {
        fileTypes = [NSArray arrayWithObject:@"thiswillnevershowup"];
        [panel setAllowedFileTypes:fileTypes];
    }

    [panel setCanChooseDirectories:true];
    
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
                if ([[scripts objectAtIndex:button.tag] isMemberOfClass:[HandleScript class]]) {
                    //Set Up Script
                    HandleScript *tempScript = [[HandleScript alloc] init];
                    [tempScript setPathURL:[theDoc absoluteString] isSubscript:false];
                    
                    //Replace NSMenuItem
                    NSMenuItem *tempMenuItem = [statusMenu itemWithTitle:[[scripts objectAtIndex:button.tag] getTitle]];
                    [tempMenuItem setTitle:[tempScript getTitle]];
                    [tempMenuItem setRepresentedObject:tempScript];
                    [tempMenuItem setAction:@selector(runScript:)];
                    NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:button.tag] getTitle]];
                    [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:button.tag] getTitle].length)];
                    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0,[[scripts objectAtIndex:button.tag] getTitle].length)];
                    [tempMenuItem setAttributedTitle:attributedTitle];
                    
                    //Replace in Array
                    [[scripts objectAtIndex:[button tag]] removeFromContext];
                    [scripts replaceObjectAtIndex:[button tag] withObject:tempScript];
                }
                else {
                    //Set Up DirectoryScript
                    HandleDirectoryScript *dirScript = [[HandleDirectoryScript alloc] init];
                    [dirScript setPathURL:[theDoc absoluteString]];
                    
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
                        [tempMenuItem setTarget:self];
                        [tempMenuItem setRepresentedObject:tempScript];
                        [tempMenuItem setImage:pythonDocument];
                        [submenu addItem:tempMenuItem];
                    }
                    
                    //Add Run all
                    [submenu addItem:[NSMenuItem separatorItem]];
                    NSMenuItem *runall = [[NSMenuItem alloc] initWithTitle:@"Run All" action:@selector(runAllInDirectory:) keyEquivalent:@""];
                    [runall setTarget:self];
                    [runall setRepresentedObject:dirScript];
                    [submenu addItem:runall];
                    
                    //Replace NSMenuItem
                    NSMenuItem *tempMenuItem = [statusMenu itemWithTitle:[[scripts objectAtIndex:button.tag] getTitle]];
                    [tempMenuItem setTitle:[dirScript getTitle]];
                    [tempMenuItem setRepresentedObject:dirScript];
                    [tempMenuItem setAction:@selector(runScript:)];
                    NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:button.tag] getTitle]];
                    [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:button.tag] getTitle].length)];
                    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0,[[scripts objectAtIndex:button.tag] getTitle].length)];
                    [tempMenuItem setAttributedTitle:attributedTitle];
                    [tempMenuItem setSubmenu:submenu];
                    
                    //UpdateArrays
                    [[scripts objectAtIndex:[button tag]] removeFromContext];
                    [scripts replaceObjectAtIndex:[button tag] withObject:dirScript];
                }
                
            }
            else {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Duplicate Entry" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"%@ has already been added to PythonBar", [[scripts objectAtIndex:[button tag]] getTitle]]];
                [alert runModal];
            }
        }
    }];
}

#pragma mark - Delegates

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark - Run by method

-(void)testPython {
    /*Py_Initialize();
     
     PyObject *sysModule = PyImport_ImportModule("sys");
     PyObject *sysModuleDict = PyModule_GetDict(sysModule);
     PyObject *pathObject = PyDict_GetItemString(sysModuleDict, "path");
     
     NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources"];*/
    
}


@end

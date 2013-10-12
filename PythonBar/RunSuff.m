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

#pragma mark - actions
-(void)replaceScript:(id)sender {
    /*[NSApp endSheet:[findAlert window]];
    
    //Open File browser
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    NSArray  *fileTypes = [NSArray arrayWithObject:@"py"];
    [panel setAllowedFileTypes:fileTypes];
    [panel setCanChooseDirectories:true];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
            scriptPaths = [defaults objectForKey:scriptsPathKey];
            if (![[scriptPaths allKeys] containsObject:[theDoc absoluteString]]) {
                NSString *temp = [[theDoc absoluteString] lastPathComponent];
                NSMutableString *filename = [NSMutableString stringWithString:temp];
                
                if([filename length] > 3) {
                    [filename deleteCharactersInRange:NSMakeRange(0, ([filename length]-3))];
                }
                if ([filename isEqual: @".py"]) {
                    //Set Up Script
                    HandelScript *tempScript = [[HandelScript alloc] init];
                    [tempScript setPathURL:[theDoc absoluteString]];
                    
                    //Replace in scripts and scriptPaths
                    NSString *jap = [[NSString alloc] initWithString:[theDoc absoluteString]];
                    id tempKey = [[scriptPaths allKeys] objectAtIndex:_tempIndex];
                    [scriptPaths setObject:[scriptPaths objectForKey:tempKey] forKey:jap];
                    [scriptPaths removeObjectForKey:tempKey];
                    [scripts replaceObjectAtIndex:_tempIndex withObject:tempScript];
                    
                    //Replace NSMenuItem
                    NSMenuItem *tempMenuItem = [statusMenu itemAtIndex:_tempIndex];
                    [tempMenuItem setTitle:[tempScript getTitle]];
                    [tempMenuItem setRepresentedObject:[tempScript getPath]];
                    [tempMenuItem setAction:@selector(runScript:)];
                    NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:_tempIndex] getTitle]];
                    [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:_tempIndex] getTitle].length)];
                    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0,[[scripts objectAtIndex:_tempIndex] getTitle].length)];
                    [tempMenuItem setAttributedTitle:attributedTitle];
                    
                    //Save
                    [defaults setObject:scriptPaths forKey:scriptsPathKey];
                    [[defaults objectForKey:scriptsPathKey] writeToFile:[defaults objectForKey:savePathKey] atomically:YES];
                }
                else {
                    //Set Up DirectoryScript
                    HandelDirectoryScript *dirScript = [[HandelDirectoryScript alloc] init];
                    [dirScript setPathURL:[theDoc absoluteString]];
                    
                    //Create Sub-Menu
                    NSMenuItem *directoryMenuItem = [[NSMenuItem alloc] init];
                    [directoryMenuItem setTitle:[dirScript getTitle]];
                    NSMenu *submenu = [[NSMenu alloc] init];
                    
                    //Add Sub-Menus
                    NSArray *subscript = [dirScript getSubScripts];
                    for (unsigned int f = 0; f < [subscript count]; f++) {
                        //Get Script
                        HandelScript *tempScript = [subscript objectAtIndex:f];
                        
                        //Create submenu
                        NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
                        [tempMenuItem setTarget:self];
                        [tempMenuItem setRepresentedObject:[tempScript getPath]];
                        [tempMenuItem setImage:pythonDocument];
                        [submenu addItem:tempMenuItem];
                    }
                    
                    //Replace NSMenuItem
                    NSMenuItem *tempMenuItem = [statusMenu itemAtIndex:_tempIndex];
                    [tempMenuItem setTitle:[dirScript getTitle]];
                    [tempMenuItem setRepresentedObject:[dirScript getPath]];
                    [tempMenuItem setAction:@selector(runScript:)];
                    NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:_tempIndex] getTitle]];
                    [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:_tempIndex] getTitle].length)];
                    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0,[[scripts objectAtIndex:_tempIndex] getTitle].length)];
                    [tempMenuItem setAttributedTitle:attributedTitle];
                    [tempMenuItem setSubmenu:submenu];
                    
                    //UpdateArrays
                    NSString *jap = [[NSString alloc] initWithString:[theDoc absoluteString]];
                    id tempKey = [[scriptPaths allKeys] objectAtIndex:_tempIndex];
                    [scriptPaths setObject:[scriptPaths objectForKey:tempKey] forKey:jap];
                    [scriptPaths removeObjectForKey:tempKey];
                    [scripts replaceObjectAtIndex:_tempIndex withObject:dirScript];
                    
                    //Save
                    [defaults setObject:scriptPaths forKey:scriptsPathKey];
                    [[defaults objectForKey:scriptsPathKey] writeToFile:[defaults objectForKey:savePathKey] atomically:YES];
                }
                
            }
            else {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Duplicate Entry" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"%@ has already been added to PythonBar", [[scripts objectAtIndex:_tempIndex] getTitle]]];
                [alert runModal];
            }
        }
    }];*/
}

-(void)testPython {
    /*Py_Initialize();
    
	PyObject *sysModule = PyImport_ImportModule("sys");
	PyObject *sysModuleDict = PyModule_GetDict(sysModule);
	PyObject *pathObject = PyDict_GetItemString(sysModuleDict, "path");
    
	NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources"];*/

}

-(void)findScript:(id)sender {
    //Get Index
    _tempIndex = [statusMenu indexOfItem:sender];
    
    //Build Alert
    if ([[sender representedObject] isMemberOfClass:[HandelScript class]]) {
        findAlert = [NSAlert alertWithMessageText:@"Script Missing" defaultButton:@"Yes" alternateButton:nil otherButton:@"No" informativeTextWithFormat:@"PythonBar cannot find this script. Would you like to relocate it?"];
    }
    else if ([[sender representedObject] isMemberOfClass:[HandelDirectoryScript class]]) {
        findAlert = [NSAlert alertWithMessageText:@"Directory Missing" defaultButton:@"Yes" alternateButton:nil otherButton:@"No" informativeTextWithFormat:@"PythonBar cannot find this Directory. Would you like to relocate it?"];
    }
    
    //Set alert actions
    NSArray *buttonArray = [findAlert buttons];
    NSButton *myBtn = [buttonArray objectAtIndex:0];
    [myBtn setAction:@selector(replaceScript:)];
    [myBtn setTarget:self];
    
    //Run Alert
    [findAlert runModal];
}

-(void)runAllInDirectory:(id)sender {
    //Get the subMenuItems
    HandelDirectoryScript *runAll = (HandelDirectoryScript *)[sender representedObject];
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
    HandelScript *runningScript = (HandelScript *)[tempItem representedObject];
    
    //Make sure Script exist
    if (![runningScript doesExist]) {
        //If Part of Directory
        if ([runningScript isSubscript]) {
            //Run the Alert
            NSAlert *alert = [NSAlert alertWithMessageText:@"Script Missing" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"%@ has been moved from the directory", [runningScript getTitle]]];
            [alert runModal];
            
            //Find a way to check the folder
            /*int z = 0;
            
            //Loop through and check for missing scripts
            while(z<[subscripts count]) {
                if(![[subscripts objectAtIndex:z] doesExist]) {
                    [subscripts removeObjectAtIndex:z];
                    z--;
                }
                else {
                    //Get Script
                    Script *tempScript = [subscripts objectAtIndex:z];
                    
                    //Create submenu
                    NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:[tempScript getTitle] action:@selector(runScript:) keyEquivalent:@""];
                    [tempMenuItem setTarget:self];
                    [tempMenuItem setRepresentedObject:tempScript];
                    [tempMenuItem setImage:pythonDocument];
                    [submenu addItem:tempMenuItem];
                    z++;
                }
            }
            NSMenuItem *tempMenuItem = [statusMenu itemAtIndex:folderIndex];
            [tempMenuItem setSubmenu:submenu];*/
            
            return;
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
        
        /*[notification setHasActionButton: YES];
         [notification setActionButtonTitle: @"Action Button"];
         [notification setOtherButtonTitle: @"Other Button"];*/
        
        //Create NotificationCenter and add notification
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center setDelegate:self];
        [center deliverNotification:notification];
    }
    
    //Increment
    [runningScript addRun];
}

#pragma mark - Delegates

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}


@end

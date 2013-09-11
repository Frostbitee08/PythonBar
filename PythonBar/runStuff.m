//
//  runStuff.m
//  PythonBar
//
//  Created by Rocco Del Priore on 9/10/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "runStuff.h"

@implementation runStuff

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

-(void)testThisAlert:(id)sender {
    [NSApp endSheet:[findAlert window]];
    
    //Open File browser
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    NSArray  *fileTypes = [NSArray arrayWithObject:@"py"];
    [panel setAllowedFileTypes:fileTypes];
    [panel setCanChooseDirectories:true];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
            if (![scriptPaths containsObject:[theDoc absoluteString]]) {
                NSString *temp = [[theDoc absoluteString] lastPathComponent];
                NSMutableString *filename = [NSMutableString stringWithString:temp];
                if([filename length] > 3) {
                    [filename deleteCharactersInRange:NSMakeRange(0, ([filename length]-3))];
                }
                if ([filename isEqual: @".py"]) {
                    //Set Up Script
                    Script *tempScript = [[Script alloc] init];
                    [tempScript setPathURL:[theDoc absoluteString]];
                    
                    //Replace in scripts and scriptPaths
                    NSString *jap = [[NSString alloc] initWithString:[theDoc absoluteString]];
                    [scriptPaths replaceObjectAtIndex:_tempIndex withObject:jap];
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
                    [scriptPaths writeToFile:savePath atomically:YES];
                }
                else {
                    //Set Up DirectoryScript
                    DirectoryScript *dirScript = [[DirectoryScript alloc] init];
                    [dirScript setPathURL:[theDoc absoluteString]];
                    
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
                    [scriptPaths replaceObjectAtIndex:_tempIndex withObject:jap];
                    [scripts replaceObjectAtIndex:_tempIndex withObject:dirScript];
                    
                    //Save
                    [scriptPaths writeToFile:savePath atomically:YES];
                }
                
            }
            else {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Duplicate Entry" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The script or directory that you have selected has already been added to PythonBar"];
                [alert runModal];
            }
        }
    }];
}

-(void)findScript:(id)sender {
    //Get Index
    _tempIndex = [statusMenu indexOfItem:sender];
    if ([[scripts objectAtIndex:_tempIndex] isMemberOfClass:[Script class]]) {
        findAlert = [NSAlert alertWithMessageText:@"Script Missing" defaultButton:@"Yes" alternateButton:nil otherButton:@"No" informativeTextWithFormat:@"PythonBar cannot find this script. Would you like to relocate it?"];
    }
    else if ([[scripts objectAtIndex:_tempIndex] isMemberOfClass:[DirectoryScript class]]) {
        findAlert = [NSAlert alertWithMessageText:@"Directory Missing" defaultButton:@"Yes" alternateButton:nil otherButton:@"No" informativeTextWithFormat:@"PythonBar cannot find this Directory. Would you like to relocate it?"];
    }
    
    NSArray *buttonArray = [findAlert buttons];
    
    NSButton *myBtn = [buttonArray objectAtIndex:0];
    [myBtn setAction:@selector(testThisAlert:)];
    [myBtn setTarget:self];
    [findAlert runModal];
}

-(void)runScript:(id)sender {
    //Make sure Script exist
    NSString *tempString = [@"file://localhost" stringByAppendingString:[sender representedObject]];
    tempString = [tempString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger *index = [scriptPaths indexOfObject:tempString];
    
    //I have got to get a better way of doing this
    int intIndex = index;
    if (intIndex == -1) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempString]){
            //Get Corresponding Folder
            NSURL *folderURL = [NSURL URLWithString:tempString];
            NSRange fragmentRange = [tempString rangeOfString:[folderURL lastPathComponent] options:NSBackwardsSearch];
            NSString *folderString = [tempString substringToIndex:fragmentRange.location];
            NSUInteger *folderIndex = [scriptPaths indexOfObject:folderString];
            
            if ([[scripts objectAtIndex:folderIndex] doesExist]) {
                NSMutableArray *subscripts = [[scripts objectAtIndex:folderIndex] getSubScripts];
                NSMenu *submenu = [[NSMenu alloc] init];
                NSAlert *alert = [NSAlert alertWithMessageText:@"Script Missing" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"This Script has been moved from the directory"];
                [alert runModal];
                int z = 0;
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
                        [tempMenuItem setRepresentedObject:[tempScript getPath]];
                        [tempMenuItem setImage:pythonDocument];
                        [submenu addItem:tempMenuItem];
                    }
                    z++;
                }
                NSMenuItem *tempMenuItem = [statusMenu itemAtIndex:folderIndex];
                [tempMenuItem setSubmenu:submenu];
                
                return;
            }
            else {
                return [self findScript:[statusMenu itemAtIndex:folderIndex]];
            }
        }
    }
    else if (![[scripts objectAtIndex:index] doesExist]) {
        NSMutableAttributedString *attributedTitle=[[NSMutableAttributedString alloc] initWithString:[[scripts objectAtIndex:index] getTitle]];
        [attributedTitle addAttribute:NSFontAttributeName value:[NSFont menuFontOfSize:14.0] range:NSMakeRange(0, [[scripts objectAtIndex:index] getTitle].length)];
        [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,[[scripts objectAtIndex:index] getTitle].length)];
        [sender setAction:@selector(findScript:)];
        [sender setAttributedTitle:attributedTitle];
        
        return [self findScript:sender];
    }
    
    //Create Task
    NSString *scriptPath = [sender representedObject];
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
        if ([outputString length] == 0) {
            notification.informativeText = @"No output";
        }
        else {
            notification.informativeText = outputString;
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
    [preferences setObject:[NSNumber numberWithBool:[notificationCheck state]] forKey:notification];
    [preferences writeToFile:preferencesPath atomically:YES];
}


@end

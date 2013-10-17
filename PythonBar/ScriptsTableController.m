//
//  ScriptsTableController.m
//  PythonBar
//
//  Created by Rocco Del Priore on 9/1/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "ScriptsTableController.h"

@implementation ScriptsTableController
@synthesize scripts, statusMenu, runner;


static NSString *savePathKey = @"savePath";

-(id)init {
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    ScriptTable = aTableView;
    return [scripts count];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    if ([[tableColumn identifier] isEqualToString:@"title"]) {
        cellView.textField.stringValue = [[scripts objectAtIndex:row] getTitle];
        return cellView;
    }
    else if ([[tableColumn identifier] isEqualToString:@"hotkey"]) {
        SRRecorderControl *shortCutRecorder = (SRRecorderControl *)[cellView.subviews objectAtIndex:0];
        [shortCutRecorder setDelegate:self];
        if ([[[[scripts objectAtIndex:row] shortCut] allKeys] count] > 0) {
            shortCutRecorder.objectValue = [[scripts objectAtIndex:row] shortCut];
        }
        
        return cellView;
    }
    else if ([[tableColumn identifier] isEqualToString:@"path"]) {
        cellView.textField.stringValue = [[scripts objectAtIndex:row] getPath];
        return cellView;
    }
    return nil;
}

#pragma mark SRRecorderControlDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut {
    NSError *error;
    BOOL isTaken = [validator isKeyCode:[aShortcut[SRShortcutKeyCode] unsignedShortValue] andFlagsTaken:[aShortcut[SRShortcutModifierFlagsKey] unsignedIntegerValue] error:&error];
    
    if (isTaken)
    {
        /*NSBeep();
        [self presentError:error
            modalForWindow:self.window
                  delegate:nil
        didPresentSelector:NULL
               contextInfo:NULL];*/
        NSLog(@"TAKEN");
    }
    else {
        //Define the Variables
        NSInteger row = [ScriptTable rowForView:[aRecorder superview]];
        HandelScript *tempScript = [scripts objectAtIndex:row];
        NSMenuItem *menuIem = [statusMenu itemWithTitle:[tempScript getTitle]];
        NSString *identifier = [NSString stringWithFormat:@"PythonBar-%@-%@", [aShortcut valueForKey:SRShortcutKeyCode], [aShortcut valueForKey:SRShortcutCharacters]];
        
        //Set up hotkey
        PTHotKeyCenter *hotKeyCenter = [PTHotKeyCenter sharedCenter];
        PTHotKey *oldHotKey = [hotKeyCenter hotKeyWithIdentifier:identifier];
        [hotKeyCenter unregisterHotKey:oldHotKey];
        
        PTHotKey *newHotKey = [PTHotKey hotKeyWithIdentifier:identifier
                                                    keyCombo:aShortcut
                                                      target:runner
                                                      action:menuIem.action];
        [newHotKey setRepresentedObject:menuIem ];
        [hotKeyCenter registerHotKey:newHotKey];
        
        //Save information
        [tempScript changeShortcut:aShortcut];
    }
    
    return !isTaken;
}

- (BOOL)shortcutRecorderShouldBeginRecording:(SRRecorderControl *)aRecorder {
    [[PTHotKeyCenter sharedCenter] pause];
    return YES;
}

- (void)shortcutRecorderDidEndRecording:(SRRecorderControl *)aRecorder {
    [[PTHotKeyCenter sharedCenter] resume];
}

-(BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    NSLog(@"2");
    /*if ([info draggingSource] == aTableView) {
        if (operation == NSTableViewDropOn){
            [aTableView setDropRow:row dropOperation:NSTableViewDropAbove];
        }
        return NSDragOperationMove;
    }
    else {
        return NSDragOperationNone;
    }*/
    return NSDragOperationEvery;    
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    return YES;
}

@end

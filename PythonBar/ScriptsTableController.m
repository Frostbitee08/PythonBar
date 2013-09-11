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
        NSInteger row = [ScriptTable rowForView:[aRecorder superview]];
        NSMenuItem *menuIem = [statusMenu itemAtIndex:row];
        
        PTHotKeyCenter *hotKeyCenter = [PTHotKeyCenter sharedCenter];
        PTHotKey *oldHotKey = [hotKeyCenter hotKeyWithIdentifier:menuIem.representedObject];
        [hotKeyCenter unregisterHotKey:oldHotKey];
        
        PTHotKey *newHotKey = [PTHotKey hotKeyWithIdentifier:menuIem.representedObject
                                                    keyCombo:aShortcut
                                                      target:runner
                                                      action:menuIem.action];
        [newHotKey setRepresentedObject:menuIem];
        [hotKeyCenter registerHotKey:newHotKey];
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

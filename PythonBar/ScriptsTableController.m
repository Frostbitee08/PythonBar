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

#define BasicTableViewDragAndDropDataType @"BasicTableViewDragAndDropDataType"

#pragma mark - Initializers

-(id)init {
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)setUp:(DeleteTableView *)aTableView {
    ScriptTable = aTableView;
    removeButton = [ScriptTable.superview.superview.superview viewWithTag:101];
    [removeButton setAction:@selector(removeAction)];
    [removeButton setTarget:self];
}

#pragma mark - TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [scripts count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    if ([[tableColumn identifier] isEqualToString:@"title"]) {
        cellView.textField.stringValue = [[scripts objectAtIndex:row] getTitle];
        return cellView;
    }
    else if ([[tableColumn identifier] isEqualToString:@"timesRan"]) {
        NSString *stringexample = [NSString stringWithFormat:@"%i", [[scripts objectAtIndex:row] getTimesRan]];
        cellView.textField.stringValue = stringexample;
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

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([ScriptTable selectedRow] >= 0) {
        [removeButton setHidden:false];
    }
    else {
        [removeButton setHidden:true];
    }
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if (operation == NSTableViewDropAbove) {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:BasicTableViewDragAndDropDataType] owner:self];
    [pboard setData:data forType:BasicTableViewDragAndDropDataType];
    return YES;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSData *data = [[info draggingPasteboard] dataForType:BasicTableViewDragAndDropDataType];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    NSArray *tArr = [scripts objectsAtIndexes:rowIndexes];
    [scripts removeObjectsAtIndexes:rowIndexes];
    if (row > scripts.count) {
        [scripts insertObject:[tArr objectAtIndex:0] atIndex:row-1];
    }
    else {
        [scripts insertObject:[tArr objectAtIndex:0] atIndex:row];
    }
    
    for (int i = 0; i < [scripts count]; i++) {
        [[scripts objectAtIndex:i] updateIndex:i];
    }
    
    NSArray *menuItems = [statusMenu.itemArray copy];
    for (NSMenuItem *item in menuItems) {
        if ([item.representedObject isKindOfClass:[HandleScript class]] || [item.representedObject isKindOfClass:[HandleDirectoryScript class]]) {
            [statusMenu removeItemAtIndex:[statusMenu indexOfItem:item]];
        }
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"representedObject.index" ascending:YES];
    menuItems = [menuItems sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (NSMenuItem *item in menuItems) {
        if ([item.representedObject isKindOfClass:[HandleScript class]] || [item.representedObject isKindOfClass:[HandleDirectoryScript class]]) {
            HandleScript *script = (HandleScript *)item.representedObject;
            [statusMenu insertItem:item atIndex:script.index.integerValue];
        }
    }
    
    [tableView reloadData];
    [tableView deselectAll:nil];

    return YES;
}

#pragma mark SRRecorderControlDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut {
    NSError *error;
    BOOL isTaken = [validator isKeyCode:[aShortcut[SRShortcutKeyCode] unsignedShortValue] andFlagsTaken:[aShortcut[SRShortcutModifierFlagsKey] unsignedIntegerValue] error:&error];
    
    if (isTaken) {
        NSLog(@"The script is taken, replace this with an error");
    }
    else {
        //Define the Variables
        NSInteger row = [ScriptTable rowForView:[aRecorder superview]];
        HandleScript *tempScript = [scripts objectAtIndex:row];
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
        [newHotKey setObject:menuIem];
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

#pragma mark - Actions

- (void)removeAction {
    [[scripts objectAtIndex:[ScriptTable selectedRow]] removeFromContext];
    [scripts removeObjectAtIndex:[ScriptTable selectedRow]];
    [self.delegate updateMenu];
    [ScriptTable reloadData];
    [removeButton setHidden:true];
}

@end

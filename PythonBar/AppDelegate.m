//
//  AppDelegate.m
//  PythonBar
//
//  Created by Rocco Del Priore on 5/5/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import <CoreServices/CoreServices.h>

#define BasicTableViewDragAndDropDataType @"BasicTableViewDragAndDropDataType"

@implementation AppDelegate

static NSString *blackandwhite = @"bw";
static NSString *startatlaunch = @"launch";
static NSString *notificationKey = @"notfication";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Initial Set up

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString* tempLibPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PythonBar/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempLibPath isDirectory:NO]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:tempLibPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PythonBar/"];
    NSURL *liburl = [NSURL URLWithString:libraryPath];
    savePath = [liburl URLByAppendingPathComponent:@"Scripts.sqlite"];
}

-(void)awakeFromNib {
    //SetUp Values
    preferences = [[NSMutableDictionary alloc] init];
    
    //Fill Preferences
    NSString *preferencesPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PythonBar/"] stringByAppendingString:@"/Settings.plist"];
    NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
    if ([[tempDict allKeys] count] > 0) {
        NSArray *keys = [tempDict allKeys];
        for (unsigned int g = 0; g<[keys count]; g++ ) {
            [preferences setObject:[tempDict objectForKey:[keys objectAtIndex:g]] forKey:[keys objectAtIndex:g]];
        }
    }
    
    //Create Status Item, and set the menu
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    
    //Set statusItems atributes
    [statusItem setHighlightMode:YES];
    [checkBox setState:[[preferences objectForKey:blackandwhite] boolValue]];
    [launchButton setState:[[preferences objectForKey:startatlaunch] boolValue]];
    [self CheckBoxStatus:nil];
    [self toggleLaunchAtLogin:nil];
    
    testThis = [[PBStatus alloc] init];
}

#pragma mark - Toggles

-(IBAction)toggleNotification:(id)sender {
    NSButton *temp = (NSButton *)sender;
    [preferences setObject:[NSNumber numberWithBool:[temp state]] forKey:notificationKey];
    [preferences writeToFile:[libraryPath stringByAppendingString:@"/Settings.plist"] atomically:YES];
}

- (BOOL)isLaunchAtStartup {
    // See if the app is currently in LoginItems.
    LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
    // Store away that boolean.
    BOOL isInList = itemRef != nil;
    // Release the reference if it exists.
    if (itemRef != nil) CFRelease(itemRef);
    
    return isInList;
}

- (IBAction)toggleLaunchAtLogin:(id)sender {
    // Toggle the state.
    BOOL shouldBeToggled = ![self isLaunchAtStartup];
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return;
    if (shouldBeToggled) {
        // Add the app to the LoginItems list.
        CFURLRef appUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, appUrl, NULL, NULL);
        if (itemRef) CFRelease(itemRef);
    }
    else {
        // Remove the app from the LoginItems list.
        LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
        LSSharedFileListItemRemove(loginItemsRef,itemRef);
        if (itemRef != nil) CFRelease(itemRef);
    }
    CFRelease(loginItemsRef);
    
    [preferences setObject:[NSNumber numberWithBool:[launchButton state]] forKey:startatlaunch];
    [preferences writeToFile:[libraryPath stringByAppendingString:@"Settings.plist"] atomically:YES];
}

- (LSSharedFileListItemRef)itemRefInLoginItems {
    LSSharedFileListItemRef itemRef = nil;
    NSURL *itemUrl = nil;
    
    // Get the app's URL.
    NSURL *appUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return nil;
    // Iterate over the LoginItems.
    NSArray *loginItems = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItemsRef, nil);
    for (int currentIndex = 0; currentIndex < [loginItems count]; currentIndex++) {
        // Get the current LoginItem and resolve its URL.
        LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItems objectAtIndex:currentIndex];
        if (LSSharedFileListItemResolve(currentItemRef, 0, (__bridge CFURLRef) itemUrl, NULL) == noErr) {
            // Compare the URLs for the current LoginItem and the app.
            if ([itemUrl isEqual:appUrl]) {
                // Save the LoginItem reference.
                itemRef = currentItemRef;
            }
        }
    }
    // Retain the LoginItem reference.
    if (itemRef != nil) CFRetain(itemRef);
    CFRelease(loginItemsRef);
    
    return itemRef;
}

- (IBAction)CheckBoxStatus:(id) sender {
    //code to change the Icon to black and white when called
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *pythonImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"pythonIcon" ofType:@"png"]];
    NSImage *pythonImageBW = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"pythonIconBW" ofType:@"png"]];
    
    NSString *ifOn = ([checkBox state] ? @"On" : @"Off");
    if ([ifOn isEqual: @"On"]){
        [statusItem setImage:pythonImageBW];
    }
    else {
        [statusItem setImage:pythonImage];
    }
    
    [preferences setObject:[NSNumber numberWithBool:[checkBox state]] forKey:blackandwhite];
}

#pragma mark - Test

- (IBAction)showPopover:(id)sender
{
    /*if (testThis != nil) {
        [testThis showPopoverWithViewController:[[PopUpViewController alloc] initWithNibName:@"PopUpView" bundle:nil]];
    }*/
}

- (IBAction)hidePopover:(id)sender
{
    /*if (_statusView != nil) {
        [_statusView hidePopover];
    }*/
}

#pragma mark - Core Data Save

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [NSApplication sharedApplication].delegate;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
// Added for Core Data
// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.razeware.ScaryBugsApp" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"PythonBar"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Scripts" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties valueForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Scripts.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

- (void)deleteManagedObject:(NSManagedObject *)aManagedObject {
    [self.managedObjectContext deleteObject:aManagedObject];
    [self saveContext];
}

@end


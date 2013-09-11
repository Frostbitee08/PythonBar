//
//  AppDelegate.m
//  PythonBar
//
//  Created by Rocco Del Priore on 5/5/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation AppDelegate

static NSString *blackandwhite = @"bw";
static NSString *startatlaunch = @"launch";

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString* libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PythonBar/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:libraryPath isDirectory:NO]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:libraryPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
}

-(void)awakeFromNib {
    //SetUp Values
    NSString* libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PythonBar/"];
    savePath = [libraryPath stringByAppendingString:@"/Settings.plist"];
    preferences = [[NSMutableDictionary alloc] init];
    
    //Fill Preferences
    NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:savePath];
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

-(IBAction)toggleLaunchAtLogin:(id)sender
{
    NSInteger clickedSegment = [launchButton state];
    if (clickedSegment == 0) { // ON
        
        // Turn on launch at login
        if (!SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.frostbitee08.PythonBar", YES)) {
            //NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Couldn't add PythonBar to launch at login item list."];
            //[alert runModal];
        }
        
    }
    if (clickedSegment == 1) { // OFF
        
        // Turn off launch at login
        if (!SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.frostbitee08.PythonBar", NO)) {
            //NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Couldn't remove PythonBar from launch at login item list."];
            //[alert runModal];
        }
        
    }
    [preferences setObject:[NSNumber numberWithBool:[launchButton state]] forKey:startatlaunch];
    [preferences writeToFile:savePath atomically:YES];
}

- (IBAction) CheckBoxStatus:(id) sender {
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
    [preferences writeToFile:savePath atomically:YES];
}

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



@end


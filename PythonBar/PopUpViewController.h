//
//  PopUpViewController.h
//  PythonBar
//
//  Created by Rocco Del Priore on 5/30/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PopUpViewController : NSViewController {
    IBOutlet NSTextView *outText;
    NSUserDefaults* defaults;
}

//- (IBAction)copy;
//- (IBAction)save;

@end

//
//  PopUpViewController.m
//  PythonBar
//
//  Created by Rocco Del Priore on 5/30/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "PopUpViewController.h"

@interface PopUpViewController ()

@end

@implementation PopUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

    - (IBAction)copy {
    NSString *text = [[outText textStorage] string];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:text  forType:NSStringPboardType];
}
- (IBAction)save {
    
}

@end

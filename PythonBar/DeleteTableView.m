//
//  DeleteTableView.m
//  PythonBar
//
//  Created by Rocco Del Priore on 10/18/13.
//  Copyright (c) 2013 Rocco Del Priore. All rights reserved.
//

#import "DeleteTableView.h"
#import "ScriptsTableController.h"

@implementation DeleteTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)keyDown:(NSEvent *)event {
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        if([self selectedRow] == -1)
        {
            NSBeep();
        }
        
        [(ScriptsTableController *)self.delegate removeAction];
        
        return;
        
    }
    
    [super keyDown:event];
}


@end

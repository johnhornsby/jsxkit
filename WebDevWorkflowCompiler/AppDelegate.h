//
//  AppDelegate.hab
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/10/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesViewController.h"
#import "ProjectViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (retain) ProjectViewController *projectViewController;
@property (retain) PreferencesViewController *preferencesViewController;
@property (retain) IBOutlet NSView *rootView;
@property (retain) IBOutlet NSToolbar *toolBar;

-(IBAction)showPreferences:(id)sender;
-(IBAction)showProject:(id)sender;


@end

//
//  AppDelegate.m
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/10/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "AppDelegate.h"
#import "ProjectViewController.h"
#import "PreferencesViewController.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize projectViewController;
@synthesize preferencesViewController;
@synthesize rootView;
@synthesize toolBar;

- (void)dealloc
{
    [super dealloc];
    [projectViewController release];
    [preferencesViewController release];
    [rootView release];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ProjectViewController *pvc = [[ProjectViewController alloc]initWithNibName:@"ProjectViewController" bundle:nil];
    self.projectViewController = pvc;
    
    PreferencesViewController *prefvc = [[PreferencesViewController alloc]initWithNibName:@"PreferencesViewController" bundle:nil];
    self.preferencesViewController = prefvc;
    
    if([self.preferencesViewController arePreferencesSet]){
        [projectViewController.view setFrame:rootView.bounds];
        [rootView addSubview:projectViewController.view];
        [toolBar setSelectedItemIdentifier:@"project"];
    }else{
        [preferencesViewController.view setFrame:rootView.bounds];
        [rootView addSubview:preferencesViewController.view];
        [toolBar setSelectedItemIdentifier:@"preferences"];
    }
    
    
    [pvc release];
    [prefvc release];
    
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [projectViewController terminate];
}

- (void)awakeFromNib {
    NSLog( @"%s" , __PRETTY_FUNCTION__ );
    return;
}

-(IBAction)showPreferences:(id)sender{
    [projectViewController.view removeFromSuperview];
    [preferencesViewController.view setFrame:rootView.bounds];
    [rootView addSubview:preferencesViewController.view];
}
-(IBAction)showProject:(id)sender{
    [preferencesViewController.view removeFromSuperview];
    [projectViewController.view setFrame:rootView.bounds];
    [rootView addSubview:projectViewController.view];
}

@end

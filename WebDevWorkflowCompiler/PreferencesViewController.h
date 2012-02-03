//
//  PreferencesViewController.h
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 17/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesViewController : NSViewController

@property (readonly) NSString *coffeeScriptFilePath;
@property (readonly) NSString *pathEnvironmentVariable;
@property (readonly) NSString *nodePathEnvironmentVariable;
@property (readonly) NSString *javaExecutableFilePath;
@property (readonly) NSString *googleClosureCompilerFilePath;

-(BOOL)arePreferencesSet;
@end

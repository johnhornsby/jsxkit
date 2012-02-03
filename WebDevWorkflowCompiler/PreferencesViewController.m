//
//  PreferencesViewController.m
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 17/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "PreferencesViewController.h"

@interface PreferencesViewController () {
@private
    
}

@property (nonatomic, retain) IBOutlet NSTextField *coffeeScriptFilePathTextField;
@property (nonatomic, retain) IBOutlet NSTextField *pathEnvironmentVariableTextField;
@property (nonatomic, retain) IBOutlet NSTextField *nodePathEnvironmentVariableTextField;
@property (nonatomic, retain) IBOutlet NSTextField *googleClosureCompilerFilePathTextField;
@property (nonatomic, retain) IBOutlet NSTextField *javaExecutableFilePathTextField;
@end


@implementation PreferencesViewController

@synthesize coffeeScriptFilePath;
@synthesize coffeeScriptFilePathTextField;
@synthesize pathEnvironmentVariable;
@synthesize pathEnvironmentVariableTextField;
@synthesize nodePathEnvironmentVariable;
@synthesize nodePathEnvironmentVariableTextField;
@synthesize javaExecutableFilePath;
@synthesize javaExecutableFilePathTextField;
@synthesize googleClosureCompilerFilePath;
@synthesize googleClosureCompilerFilePathTextField;

-(void)dealloc {
    [coffeeScriptFilePath release];
    [coffeeScriptFilePathTextField release];
    [pathEnvironmentVariable release];
    [pathEnvironmentVariableTextField release];
    [nodePathEnvironmentVariable release];
    [nodePathEnvironmentVariableTextField release];
    [javaExecutableFilePath release];
    [javaExecutableFilePathTextField release];
    [googleClosureCompilerFilePath release];
    [googleClosureCompilerFilePathTextField release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)awakeFromNib {
    NSLog( @"%s" , __PRETTY_FUNCTION__);
    return;
}

-(NSString *) coffeeScriptFilePath {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"coffeeScriptExecutableFilePath"];
}

-(NSString *) pathEnvironmentVariable {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"pathEnvironmentVariable"];
}

-(NSString *) nodePathEnvironmentVariable {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"nodePathEnvironmentVariable"];
}

-(NSString *) javaExecutableFilePath {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"javaExecutableFilePath"];
}

-(NSString *) googleClosureCompilerFilePath {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"googleClosureExecutableFilePath"];
}



-(BOOL)arePreferencesSet {
    int p = 0;
    if([[self coffeeScriptFilePath] length] > 0){
        p++;
    }
    if([[self pathEnvironmentVariable] length] > 0){
        p++;
    }
    if([[self nodePathEnvironmentVariable] length] > 0){
        p++;
    }
    if([[self javaExecutableFilePath] length] > 0){
        p++;
    }
    if([[self googleClosureCompilerFilePath] length] > 0){
        p++;
    }
    if(p==5){
        return YES;
    }else{
        return NO;
    }
}



@end

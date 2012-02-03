//
//  AddJoinedFileViewController.m
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 02/02/2012.
//  Copyright (c) 2012 Interactive Labs. All rights reserved.
//

#import "AddJoinedFileViewController.h"

@interface AddJoinedFileViewController()
-(void)reset;
@end


@implementation AddJoinedFileViewController
@synthesize relativeJoinedFilePathTextField;
@synthesize headerTextField;
@synthesize footerTextField;
@synthesize relativeJoinedFileName, headerText, footerText;

-(void)dealloc {
    [relativeJoinedFileName release];
    [headerText release];
    [footerText release];
    [super dealloc];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)onSaveClick:(id)sender {
    self.relativeJoinedFileName = [relativeJoinedFilePathTextField stringValue];
    self.headerText = [headerTextField stringValue];
    self.footerText = [footerTextField stringValue];
    [NSApp endSheet:self.window];
    [self reset];
}

- (IBAction)onCancelClick:(id)sender {
    self.relativeJoinedFileName = nil;
    self.headerText = nil;
    self.footerText = nil;
    [NSApp endSheet:self.window];
    [self reset];
}

- (IBAction)onDeleteClick:(id)sender {
}

-(void)setRelativeJoinedFileName:(NSString *)relativeJoinedFileName setHeaderText:(NSString *)headerText setFooterText:(NSString *)footerText {
    self.relativeJoinedFilePathTextField.stringValue = relativeJoinedFileName;
    self.headerTextField.stringValue = headerText;
    self.footerTextField.stringValue = footerText;
}

#pragma mark - PRIVATE

-(void)reset {
    relativeJoinedFilePathTextField.stringValue = @"";
    headerTextField.stringValue = @"";
    footerTextField.stringValue = @"";
}
@end

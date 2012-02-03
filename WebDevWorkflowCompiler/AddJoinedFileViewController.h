//
//  AddJoinedFileViewController.h
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 02/02/2012.
//  Copyright (c) 2012 Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddJoinedFileViewController : NSWindowController
@property (retain) NSString *relativeJoinedFileName;
@property (retain) NSString *headerText;
@property (retain) NSString *footerText;
@property (assign) IBOutlet NSTextField *relativeJoinedFilePathTextField;
@property (assign) IBOutlet NSTextField *headerTextField;
@property (assign) IBOutlet NSTextField *footerTextField;

- (IBAction)onSaveClick:(id)sender;
- (IBAction)onCancelClick:(id)sender;
- (IBAction)onDeleteClick:(id)sender;
- (void)setRelativeJoinedFileName:(NSString *)relativeJoinedFileName setHeaderText:(NSString *)headerText setFooterText:(NSString *)footerText;
@end

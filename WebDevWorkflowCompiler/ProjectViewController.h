//
//  ProjectViewController.h
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 17/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OutlineViewItem.h"
#import "BuildManager.h"
#import "AddJoinedFileViewController.h"

@interface ProjectViewController : NSViewController <NSComboBoxCellDataSource, NSOutlineViewDataSource, NSOutlineViewDelegate, BuildManagerDelegate> {
    BOOL isWatchingFiles;
    NSString *sourcePath;
    NSString *buildPath;
}

@property (retain) NSString *projectPath;
@property (nonatomic, retain) IBOutlet NSTextField *projectPathTextField;
@property (nonatomic, retain) IBOutlet NSTextField *sourcePathTextField;
@property (nonatomic, retain) IBOutlet NSTextField *buildPathTextField;
//@property (nonatomic, retain) IBOutlet NSTextField *joinedFileName;
@property (nonatomic, retain) IBOutlet NSTextView *outputText;
@property (nonatomic, retain) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSMutableDictionary *filesDictionary;
@property (nonatomic, retain) OutlineViewItem *outlineRoot;
@property (nonatomic, retain) BuildManager *buildManager;
@property (nonatomic, retain) AddJoinedFileViewController *addJoinedFileViewController;
@property BOOL areProjectPathsSet;
@property (copy) NSString *sourcePath;
@property (copy) NSString *buildPath;
@property (assign) IBOutlet NSButton *minusButton;
@property (assign) IBOutlet NSButton *settingsButton;

-(void)terminate;
-(void)saveToUserDefaults:(NSString*)myString;
-(NSString*)retrieveFromUserDefaults;
-(IBAction)selectProjectFolder:(id)sender;
-(void)setProjectFilePath:(NSString *)string;
-(IBAction)selectSourcePath:(id)sender;
-(void)setSourcePath:(NSString *)string;
-(IBAction)selectBuildPath:(id)sender;
-(void)setBuildPath:(NSString *)string;
-(void)updateProjectPath;
-(void)resolveProjectPath;

-(IBAction)compileClick:(id)sender;

-(void)updateFileModificationDates;
-(BOOL)scanCoffeeFiles;
-(IBAction)toggleWatchFiles:(id)sender;
-(void)onTimer:(NSTimer*)timer;
-(void)checkResumeTimer;

-(NSMutableArray *)createBuildCategoriesArray;
-(void)compile;
-(void)appendConsoleMessage:(NSString *)string withDate:(BOOL)withDate;
- (IBAction)onAddJoinedFile:(id)sender;
- (IBAction)onDeleteJoinFile:(id)sender;
- (IBAction)onEditJoinFile:(id)sender;

@end

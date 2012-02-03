//
//  ProjectViewController.m
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 17/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "ProjectViewController.h"
#import "FileDataContainer.h"
#import "OutlineViewItem.h"
#import "BuildManager.h"
#import "BuildCategory.h"
#import "BuildFile.h"
#import "AppDelegate.h"
#import "AddJoinedFileViewController.h"

@interface ProjectViewController (additional)

-(void)logItemInfo:(NSDictionary *)item;
-(NSDictionary *)generateFlatFileDictionary;

@end


@implementation ProjectViewController
@synthesize minusButton;
@synthesize settingsButton;

@synthesize projectPath;
@synthesize projectPathTextField;
@synthesize sourcePathTextField;
@synthesize buildPathTextField;
@synthesize outputText;
@synthesize timer;
@synthesize outlineView;
@synthesize filesDictionary;
@synthesize outlineRoot;
@synthesize buildManager;
@synthesize areProjectPathsSet;
@synthesize addJoinedFileViewController;
//@synthesize sourcePath;
//@synthesize buildPath;

- (void)dealloc {
    [super dealloc];
    [projectPath release];
    [projectPathTextField release];
    [sourcePathTextField release];
    [buildPathTextField release];
    [outputText release];
    [timer release];
    [outlineView release];
    [filesDictionary release];
    [outlineRoot release];
    [buildManager release];
    [sourcePath release];
    [buildPath release];
    [addJoinedFileViewController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
        
    }
    
    return self;
}

-(void)terminate {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if(areProjectPathsSet){
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:self.outlineRoot forKey:@"outlineRoot"];
        [archiver finishEncoding];
        NSString *savePath = [[NSString alloc]initWithFormat:@"%@/.webdevworkflow",projectPath];
        [data writeToFile:savePath atomically:YES];
        [archiver release];
        [data release];
        [savePath release];
        [self.outlineRoot release];
    }
    self.buildManager = nil;
}



- (void)awakeFromNib {
    //NSLog(@"%@",__PRETTY_FUNCTION__);
    isWatchingFiles = NO;
    self.outlineRoot = [OutlineViewItem outlineViewItemForLabel:@"root" andType:@"root" andParent:nil];
    [outlineRoot appendChild:[OutlineViewItem outlineViewItemForLabel:@"copy" andType:@"folder" andParent:outlineRoot]];
    [outlineRoot appendChild:[OutlineViewItem outlineViewItemForLabel:@"ignore" andType:@"folder" andParent:outlineRoot]];
	//OutlineViewItem *scriptsFolderOutlineViewItem = [OutlineViewItem outlineViewItemForLabel:@"scripts.js" andType:@"folder" andParent:outlineRoot];
	//scriptsFolderOutlineViewItem.childrenAreOrderable = YES;
    //[outlineRoot appendChild:scriptsFolderOutlineViewItem];
    
    areProjectPathsSet = NO;
    //TODO
    /*
     check for sourcePath and buildPath in NSUserDefaults
     */
    /*
    NSString *savedProjectPath = [self retrieveFromUserDefaults];
    if(savedProjectPath != nil){
        [self setProjectPath:savedProjectPath];
    }
    */
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sourcePath"]!= nil){
        self.sourcePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"sourcePath"];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"buildPath"]!= nil){
        self.buildPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"buildPath"];
    }
    
    
    self.filesDictionary = (NSMutableDictionary *)[self generateFlatFileDictionary];
    
    [outlineView reloadData];
    return;
}


-(void)saveToUserDefaults:(NSString*)myString {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		[standardUserDefaults setObject:myString forKey:@"Prefs"];
		[standardUserDefaults synchronize];
	}
}

-(NSString*)retrieveFromUserDefaults {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	if (standardUserDefaults) {
		val = [standardUserDefaults objectForKey:@"Prefs"];
	}
	return val;
}

/**
 * update file dictionary with the file modification dates and reset the fileDataContainer
 * can't remember why this is needed to be done!
 * files isModified is set to No, this feature is a flag for when watching for changes, reset back to No once compiled.
 * modification dates are also updated so can be checked against in the future.
 *TODO, compiling takes a little while and so multiple file saves may be obsured and may go undetected.
 **/
-(void)updateFileModificationDates{
    //NSString *sourceDirectoryPath = [[NSString alloc]initWithFormat:@"%@%@",[self.projectPathTextField stringValue],@"/src/js"]; 
    NSURL *sourceDirectoryURL = [NSURL fileURLWithPath:sourcePath isDirectory:YES];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *sourceDirectoryEnumerator = [localFileManager enumeratorAtURL:sourceDirectoryURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLContentModificationDateKey, NSURLNameKey,NSURLIsDirectoryKey,nil] options:NSDirectoryEnumerationSkipsPackageDescendants errorHandler:nil];
    NSMutableDictionary *prospectiveFilesModifcationDatesDictionary = [[NSMutableDictionary alloc]init];        //temporary dictionary populated with paths as keys and dictionary for object containing nsdate and nsurl
    FileDataContainer *fileDataContainer;
    for (NSURL *theURL in sourceDirectoryEnumerator) {
        NSDate *date;
        [theURL getResourceValue:&date forKey:NSURLContentModificationDateKey error:NULL];
        if([[theURL pathExtension] isEqualToString:@"coffee"] || [[theURL pathExtension] isEqualToString:@"js"]){
            [prospectiveFilesModifcationDatesDictionary setObject:date forKey:[theURL path]];
        }
    }
    NSDate *fileDate;
    for(NSString *key in self.filesDictionary){
        fileDate = (NSDate *)[prospectiveFilesModifcationDatesDictionary objectForKey:key];
        fileDataContainer = (FileDataContainer *)[self.filesDictionary objectForKey:key];
        if([fileDate compare:fileDataContainer.modificationDate] != NSOrderedSame){
            fileDataContainer.modificationDate = fileDate;                              //update modication date
        }
        fileDataContainer.isModified = NO;   
    }
    
    //[sourceDirectoryPath release];
    [localFileManager release];
    [prospectiveFilesModifcationDatesDictionary release];
}

static NSString* resolveRelativePath(NSString *projectPath, NSString *filePath){
    NSRange range = [filePath rangeOfString:projectPath];
    NSString *projectPathWithTrailingSlash = [NSString stringWithFormat:@"%@/",projectPath,nil];
    if(range.location == NSNotFound){
       return @""; 
    }else{
        return [filePath stringByReplacingOccurrencesOfString:projectPathWithTrailingSlash withString:@""];
    }
}


-(BOOL)scanCoffeeFiles {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    BOOL filesModified = NO;
    //BOOL areFilesAddedOrRemoved = NO;
    
    //Dictionary used to collect modification dates from valid files
    //NSMutableDictionary *scannedModificationDatesDictionary = [[NSMutableDictionary alloc]init];
    //NSString *sourceDirectoryPath = [[NSString alloc]initWithFormat:@"%@%@",[self.projectPathTextField stringValue],@"/src/js"];
    //NSString *sourceDirectoryPath = [[NSString alloc]initWithFormat:@"%@%@",[self.projectPathTextField stringValue],@"/src/js"];
    NSURL *sourceDirectoryURL = [NSURL fileURLWithPath:sourcePath isDirectory:YES];
    
    // Create a local file manager instance
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    // Enumerate the directory (specified elsewhere in your code)
    // Request the two properties the method uses, name and isDirectory
    // Ignore hidden files
    // The errorHandler: parameter is set to nil. Typically you'd want to present a panel
    NSDirectoryEnumerator *sourceDirectoryEnumerator = [localFileManager enumeratorAtURL:sourceDirectoryURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLContentModificationDateKey, NSURLNameKey,NSURLIsDirectoryKey,nil] options:NSDirectoryEnumerationSkipsPackageDescendants errorHandler:nil];
    
    // An array to store the all the enumerated file names in
    //NSMutableArray *theArray=[NSMutableArray array];
    
    NSMutableDictionary *prospectiveFilesDictionary = [[NSMutableDictionary alloc]init];        //temporary dictionary populated with paths as keys and dictionary for object containing nsdate and nsurl
    FileDataContainer *fileDataContainer;
    // Enumerate the dirEnumerator results, each value is stored in allURLs 
    for (NSURL *theURL in sourceDirectoryEnumerator) {
        // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        // Retrieve whether a directory. From NSURLIsDirectoryKey, also
        // cached during the enumeration.
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        NSDate *date;
        
        [theURL getResourceValue:&date forKey:NSURLContentModificationDateKey error:NULL];
        if([[theURL pathExtension] isEqualToString:@"coffee"] || [[theURL pathExtension] isEqualToString:@"js"]){
            fileDataContainer = [FileDataContainer fileDataContainerForURL:(NSURL*)theURL andDate:(NSDate *)date andParent:nil];
            [prospectiveFilesDictionary setObject:fileDataContainer forKey:[theURL path]];
        }
    }
    
    /*
     iterate through prospective and add from files any not found in file
     */
    OutlineViewItem *copyFolder = [outlineRoot childForLabel:@"copy"];
    for(NSString *key in prospectiveFilesDictionary){
        if([self.filesDictionary objectForKey:key] == nil){
            fileDataContainer = [prospectiveFilesDictionary objectForKey:key];
            [self.filesDictionary setObject:fileDataContainer forKey:key];                         //add to files
            
            //create relative string for OutlineViewItem label
            NSString *relativePath = resolveRelativePath(sourcePath, fileDataContainer.path);
            if([relativePath isEqualToString:@""]){
                NSLog(@"ERROR");
            }
            
            
            //OutlineViewItem *fileItem = [OutlineViewItem outlineViewItemForLabel:fileDataContainer.path andType:@"file" andParent:copyFolder];
            OutlineViewItem *fileItem = [OutlineViewItem outlineViewItemForLabel:relativePath andType:@"file" andParent:copyFolder];
            fileItem.data = fileDataContainer;
            [copyFolder appendChild:fileItem];                                      //add to outlineView
            fileItem.parent = copyFolder;                                           //establish parent when adding, this could probably do with some refactoring
            filesModified = YES;                                                    //no real need to flasg this here, as a new fileDataContainer.isModified = YES and will be picked up when checking modification later on.
        }
    }
    
    /*
     interate through files and remove any not present in prospective
     */
    for(NSString *key in self.filesDictionary){
        if([prospectiveFilesDictionary objectForKey:key] == nil){
            fileDataContainer = [self.filesDictionary objectForKey:key];
            [fileDataContainer removeFromParent];                                   //remove from outlineView
            [self.filesDictionary removeObjectForKey:key];                                         //remove from files
            filesModified = YES;
        }
    }
    
    /*
     interate through files and check modification dates and update if needing update
     */
    FileDataContainer *propectiveFileDataContainer;
    for(NSString *key in self.filesDictionary){
        propectiveFileDataContainer = (FileDataContainer *)[prospectiveFilesDictionary objectForKey:key];
        fileDataContainer = (FileDataContainer *)[self.filesDictionary objectForKey:key];
        if([propectiveFileDataContainer.modificationDate compare:fileDataContainer.modificationDate] != NSOrderedSame){
            fileDataContainer.modificationDate = propectiveFileDataContainer.modificationDate;                              //update modication date
            fileDataContainer.isModified = YES;                                                                           //update isModified BOOL
        }
    }
    
    //TODO
    //iterate over self.filesDictionary and check if any are modified, a the moment filesModified still == NO
    for(NSString *key in self.filesDictionary){
        fileDataContainer = (FileDataContainer *)[self.filesDictionary objectForKey:key];
        if(fileDataContainer.isModified == YES){
            filesModified = YES;
        }
    }
    
    
    if(filesModified==YES){
        NSLog(@"Date Difference in files");
        [outlineView reloadData]; 
    }
    
    // Release the localFileManager.
    [prospectiveFilesDictionary release];
    [localFileManager release];
    //[sourceDirectoryPath release];
    
    return filesModified;
}

-(void)onTimer:(NSTimer *)timer{
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if([self scanCoffeeFiles] == YES){
        [self compile];
    }else{
        [self checkResumeTimer];
    }
}

-(void)checkResumeTimer {
    if(isWatchingFiles){
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
    }
}

-(void)cleanTimer {
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
}


-(IBAction)toggleWatchFiles:(id)sender{
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    //if([[self.projectPathTextField stringValue] isNotEqualTo:@""]){
    if(areProjectPathsSet){
        if([(NSButton *)sender state] == 0){
            isWatchingFiles = NO;
            if(timer != nil){
                [timer invalidate];
                timer = nil;
            }
        }else{
            isWatchingFiles = YES; 
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
        }
    }else{
        //NSRunAlertPanel(@"Error", @"Please select a Project Path",@"Ok", nil, nil);
        
        
        NSBeginAlertSheet(@"Error", @"Ok", nil,nil,[(AppDelegate *)[[NSApplication sharedApplication] delegate] window],nil,nil,nil,nil,@"Please select a Project Path");
        [(NSButton *)sender setState:0];
    }
}

-(IBAction)selectProjectFolder:(id)sender{
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        [self setProjectPath:[files objectAtIndex:0]];
    }
}

-(IBAction)selectSourcePath:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO]; // Enable the selection of files in the dialog.
    [openDlg setCanChooseDirectories:YES];// Enable the selection of directories in the dialog.
    [openDlg setAllowsMultipleSelection:NO];
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton ){// Display the dialog.  If the OK button was pressed
        NSArray* files = [openDlg filenames];// Get an array containing the full filenames of all files and directories selected.
        //[self setSourcePath:[files objectAtIndex:0]];
        self.sourcePath = [files objectAtIndex:0];
    }
}

-(NSString *)sourcePath {
    return self.sourcePath;
}

-(void)setSourcePath:(NSString *)string {
    if(sourcePath != string){
        [sourcePath release];
        sourcePath = [string copy];
        [[NSUserDefaults standardUserDefaults] setObject:sourcePath forKey:@"sourcePath"];
        [sourcePathTextField setStringValue:sourcePath];
        [self updateProjectPath];
    }
}

-(IBAction)selectBuildPath:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO]; // Enable the selection of files in the dialog.
    [openDlg setCanChooseDirectories:YES];// Enable the selection of directories in the dialog.
    [openDlg setAllowsMultipleSelection:NO];
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton ){// Display the dialog.  If the OK button was pressed
        NSArray* files = [openDlg filenames];// Get an array containing the full filenames of all files and directories selected.
        [self setBuildPath:[files objectAtIndex:0]];
    }
}

-(NSString *)buildPath {
    return self.buildPath;
}

-(void)setBuildPath:(NSString *)string {
    if(buildPath != string){
        [buildPath release];
        buildPath = [string copy];
        [[NSUserDefaults standardUserDefaults] setObject:buildPath forKey:@"buildPath"];
        [buildPathTextField setStringValue:buildPath];
        [self updateProjectPath];
    }
}

-(void)updateProjectPath {
    if([sourcePath isNotEqualTo:@""] && [buildPath isNotEqualTo:@""]){
        areProjectPathsSet = YES;
        [self resolveProjectPath];
    }else{
        areProjectPathsSet = NO;
    }
}

-(void)resolveProjectPath {
    NSArray *buildComponents = [buildPath pathComponents];
    NSArray *sourceComponenets = [sourcePath pathComponents];
    //interate through path and check where they diverge
    NSMutableArray *projectPathComponents = [[NSMutableArray alloc]init];
    for(int i=0; i < [sourceComponenets count]; i++){
        if([[sourceComponenets objectAtIndex:i] isEqualToString:[buildComponents objectAtIndex:i]]){
            [projectPathComponents addObject:[sourceComponenets objectAtIndex:i]];
        }else{
            break;
        }
    }
    self.projectPath = [NSString pathWithComponents:projectPathComponents];
    [self setProjectFilePath:projectPath];
}

/**
 * sets the project project directory
 * creates an instance of BuildManager
 * checks project directory hidden file
 * if project directory hidden file then unarchive outlineRoot
 * else scan project directory
 **/
-(void)setProjectFilePath:(NSString *)string {
    /*
    NSString *buildLaunchPath;
    if (kCFCoreFoundationVersionNumber <= 550.190000) {
        buildLaunchPath = @"/usr/bin/coffee";
    }else{
        buildLaunchPath = @"/usr/local/bin/coffee";
    }
    
    NSDictionary *environmentDictionary;
    if (kCFCoreFoundationVersionNumber == 550.190000) {
        environmentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"/usr/lib/node_modules", @"NODE_PATH", @"/usr/bin", @"PATH", nil];
    }else{
        environmentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"/usr/local/lib/node_modules", @"NODE_PATH", @"/usr/local/bin", @"PATH", nil];
    }*/
    //self.buildManager = [[BuildManager alloc]initWithCoffeeScriptPath:buildLaunchPath andPathEnvironmentVariable:[environmentDictionary objectForKey:@"PATH"] andNodePathEnvironmentVariable:[environmentDictionary objectForKey:@"NODE_PATH"] andProjectPath:string];
    
    self.buildManager = [[BuildManager alloc]initWithBuildPath:buildPath];
    buildManager.delegate = self;
    
    
    [self.projectPathTextField setStringValue:string];
    [self saveToUserDefaults:string];
    
    
    NSString *savePath = [[NSString alloc]initWithFormat:@"%@/.webdevworkflow",string];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:savePath]) {
        [self.outlineRoot release];
        self.outlineRoot = nil;
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:savePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.outlineRoot = [unarchiver decodeObjectForKey:@"outlineRoot"];
        [unarchiver finishDecoding];
        [unarchiver release];
        [data release];
        [savePath release];
        [self updateFileModificationDates];
        [self.outlineView reloadData];
    }else{
        [self scanCoffeeFiles];
    }
    
}

-(void)buildSendsMessage:(NSString *)message {
    NSLog(message);
    [self appendConsoleMessage:message withDate:YES];
}
-(void)buildHasCompleted {
    [self updateFileModificationDates];
    [self checkResumeTimer];
}
-(void)buidHasAborted{
    [self updateFileModificationDates];
    [self checkResumeTimer];
}

-(IBAction)compileClick:(id)sender {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    //if([self scanCoffeeFiles] == YES){
    [self compile];
    //}
}

-(NSMutableArray *)createBuildCategoriesArray {
    NSMutableArray *categories = [NSMutableArray array];
    NSMutableArray *files;
    BuildCategory *category;
    BuildFile *buildFile;
    NSString *action;
    NSString *destination = nil;
    for (OutlineViewItem *categoryViewItem in outlineRoot.children) {
        if([categoryViewItem.label isEqualToString:@"ignore"] == NO){
            if(categoryViewItem.hasChildren){
                if([categoryViewItem.label isEqualToString:@"copy"]){
                    action = [NSString stringWithString:categoryViewItem.label]; 
                }else{
                    action = @"join";
                    destination = [NSString stringWithFormat:@"%@",categoryViewItem.label];
                }
                files = [NSMutableArray array];
                for(OutlineViewItem *file in categoryViewItem.children){
                    
                    buildFile = [[BuildFile alloc] init];
                    buildFile.sourceFilePath = [[file.data path] copy];
                    buildFile.shouldMinify = file.shouldMinify;
                    
                    [files addObject:buildFile];
                    
                    [buildFile release];
                }
                category = [[[BuildCategory alloc]initWithAction:action andChildren:files andDestination:destination]autorelease];
                [categories addObject:category];
            }
        }
    }
    return categories;
}

-(void)compile {
    [self cleanTimer];
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if(areProjectPathsSet){
        NSMutableArray *categoriesArray = [self createBuildCategoriesArray];
        [buildManager buildWithBuildCategories:categoriesArray];
    }else{
        NSBeginAlertSheet(@"Error", @"Ok", nil,nil,[(AppDelegate *)[[NSApplication sharedApplication] delegate] window],nil,nil,nil,nil,@"Please select a Project Path");
    }
}

-(void)appendConsoleMessage:(NSString *)string withDate:(BOOL)withDate {
    NSDate *now = [[NSDate alloc]init];
    NSString *date = @"";
    if(withDate==YES){
        date =[now descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S " timeZone:nil locale:nil];
    }
    NSString *formattedText;
    formattedText = [[NSString alloc]initWithFormat:@"%@%@\n",date,string];
    NSAttributedString *appendText;
    appendText = [[NSAttributedString alloc]initWithString:formattedText]; 
    NSTextStorage *textStorage = [outputText textStorage];
    [textStorage beginEditing];
    [textStorage appendAttributedString:appendText];
    [textStorage endEditing];
    [now release];
    [formattedText release];
    [appendText release];
}

- (IBAction)onAddJoinedFile:(id)sender {
    
    if(self.addJoinedFileViewController == nil){
        AddJoinedFileViewController *w = [[AddJoinedFileViewController alloc] initWithWindowNibName:@"AddJoinedFileWindow"];
        self.addJoinedFileViewController = w;
        [w release];
    }
    NSWindow *sheetWindow = self.addJoinedFileViewController.window;
    NSWindow *mainWindow = [(AppDelegate *)[NSApp delegate] window];
    [NSApp beginSheet:sheetWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    if(self.addJoinedFileViewController.relativeJoinedFileName){
        OutlineViewItem *scriptsFolderOutlineViewItem = [OutlineViewItem outlineViewItemForLabel:self.addJoinedFileViewController.relativeJoinedFileName andType:@"folder" andParent:outlineRoot];
        scriptsFolderOutlineViewItem.childrenAreOrderable = YES;
        [outlineRoot appendChild:scriptsFolderOutlineViewItem];
    }
    [outlineView reloadData];
}

- (IBAction)onDeleteJoinFile:(id)sender {
    
    NSInteger index = [outlineView selectedRow];
    OutlineViewItem *item = [outlineView itemAtRow:index];
    
    OutlineViewItem *copyFolderItem = [outlineRoot.children objectAtIndex:0];
    [item moveChildrenTo:copyFolderItem];
    [outlineRoot removeChild:item];
    [outlineView reloadData];
    
    /*
     move all in joined to copy
     remove joined from outline
     
     */
}

- (IBAction)onEditJoinFile:(id)sender {
    NSInteger index = [outlineView selectedRow];
    OutlineViewItem *item = [outlineView itemAtRow:index];
    [self.addJoinedFileViewController setRelativeJoinedFileName:item.label setHeaderText:@"" setFooterText:@""];
    NSWindow *sheetWindow = self.addJoinedFileViewController.window;
    NSWindow *mainWindow = [(AppDelegate *)[NSApp delegate] window];
    [NSApp beginSheet:sheetWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(didEndEditSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndEditSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    NSInteger index = [outlineView selectedRow];
    OutlineViewItem *item = [outlineView itemAtRow:index];
    if(self.addJoinedFileViewController.relativeJoinedFileName){
        item.label = self.addJoinedFileViewController.relativeJoinedFileName;
    }
    [outlineView reloadData];
}





-(void)logItemInfo:(NSDictionary *)item {
    NSLog(@"item level:%@ label:%@ parent label:%@",[item objectForKey:@"level"],[item objectForKey:@"label"],[[item objectForKey:@"parent"]objectForKey:@"label"]);
}

/**
 * create the file dictionary from outlineRoot, used to instantiate the file dictionary if outline root is unarchived
 **/
-(NSMutableDictionary *)generateFlatFileDictionary {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(OutlineViewItem *folder in outlineRoot.children){
        for (OutlineViewItem *file in folder.children) {
            [dictionary setObject:file.data forKey:file.label]; 
        }
    }
    return dictionary;
}





#pragma mark NSComboBoxDataSource
-(NSUInteger)comboBoxCell:(NSComboBoxCell*)cell indexOfItemWithStringValue:(NSString*)string{
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    NSArray *values = [cell representedObject];
    if(values == nil)
        return NSNotFound;
    else
        return [values indexOfObject:string];
    
}

-(NSInteger)numberOfItemsInComboBoxCell:(NSComboBoxCell*)cell {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    NSArray *values = [cell representedObject];
    if(values == nil)
        return 0;
    else
        return [values count];
}

-(id)comboBoxCell:(NSComboBoxCell*)cell objectValueForItemAtIndex:(NSInteger)index {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    NSArray *values = [cell representedObject];
    if(values == nil)
        return @"";
    else
        return [values objectAtIndex:index];
}







#pragma -mark NSOutlineViewDataSource
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if(outlineRoot == nil) return 0;
    if(item == nil){
        return [outlineRoot numberOfChildren];
    }else{
        return [item numberOfChildren];
    }
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if(outlineRoot == nil) return NO;
    if(item == nil){
        return YES;
    }else{
        return [item hasChildren];
    }
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if(outlineRoot == nil) return nil;
    if(item == nil){
        return [outlineRoot childAtIndex:index];
    }else{
        return [item childAtIndex:index];
    }
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if(outlineRoot == nil) return nil;
    if(item == nil){
        return outlineRoot.label;
    }else{
        return [item objectValueForTableColumn:tableColumn];
    }
}

-(void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)value forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    [item setObjectValue:value forTableColumn:tableColumn];
    //reload table
    [self.outlineView reloadData];
}

/**
 * set representedObject to an array of values
 */
-(void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    [item outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn];
}


#pragma -mark NSOutlineView Delegate Methods

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    return [item outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    OutlineViewItem *outlineViewItem = (OutlineViewItem*)item;
    if(outlineViewItem.childrenAreOrderable == YES){
        [settingsButton setEnabled:YES];
        [minusButton setEnabled:YES];
    }else{
        [settingsButton setEnabled:NO];
        [minusButton setEnabled:NO];
    }
    return YES;
}

@end

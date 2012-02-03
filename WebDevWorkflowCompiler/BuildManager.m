//
//  BuildManager.m
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 02/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "BuildManager.h"
#import "OutlineViewItem.h"
#import "BuildCategory.h"
#import "BuildFile.h"
#import "AppDelegate.h"
#import "PreferencesViewController.h"


/*
 Private Properties & Methods
 */
@interface BuildManager () {
    int _currentCategoryIndex;
    int _currentFileIndex;
}
@property (nonatomic, retain) NSArray *_buildCategories;
//@property (nonatomic, retain) NSString *_coffeeScriptPath;
//@property (nonatomic, retain) NSString *_pathEnvironmentVariable;
//@property (nonatomic, retain) NSString *_nodePathEnvironmentVariable;
//@property (nonatomic, retain) NSString *_projectPath;
@property (nonatomic, retain) NSString *_compiledFileString;
@property (nonatomic, retain) NSFileHandle *_fileHandle;
@property (nonatomic, retain) NSTask *_task;
@property (nonatomic, retain) NSTimer *_processBreather;
@property (copy) NSString *_buildPath;
@property (retain) NSString *_closureFileOutput;

-(void)compile;
-(void)processFileBreatherOnTimer:(NSTimer *)timer;
-(void)processFile;
-(void)processFileComplete;
-(void)processFilesComplete;
-(void)processCategory;
-(void)processCategoryComplete;
-(void)processCategoriesComplete;
-(void)copyItem:(NSString *)filePath;
-(void)readAndJoinFile:(NSString *)filePath;
-(void)createCompileCoffeeScriptTask:(NSString *)filePath;
-(void)completedTask:(NSString *)string;
-(void)errorInitiatingTask;
-(void)abortBuild;
-(void)errorEndingTask:(NSString *)string;
-(void)readPipe:(NSNotification *)notification;
-(void)readClosurePipe:(NSNotification *)notification;
-(void)compileFileWithGoogleClosure:(NSString *)filePath;
-(NSString *)resolveBuildPathRelativeToSource:(NSString *)filePath;

@end



@implementation BuildManager

@synthesize _buildCategories;
//@synthesize _coffeeScriptPath;
//@synthesize _pathEnvironmentVariable;
//@synthesize _nodePathEnvironmentVariable;
//@synthesize _projectPath;
@synthesize _compiledFileString;
@synthesize _fileHandle;
@synthesize _task;
@synthesize _processBreather;
@synthesize _closureFileOutput;
@synthesize delegate;
@synthesize _buildPath;

- (void)dealloc {
    [_buildCategories release];
    //[_coffeeScriptPath release];
    //[_pathEnvironmentVariable release];
    //[_nodePathEnvironmentVariable release];
    //[_projectPath release];
    [_compiledFileString release];
    [_fileHandle release];
    [_task release];
    [_processBreather release];
    [_buildPath release];
    [super dealloc];
}
/*
-(id)initWithCoffeeScriptPath:(NSString *)coffeeScriptPath andPathEnvironmentVariable:(NSString *)pathEnvVar andNodePathEnvironmentVariable:(NSString *)nodePathEnvVar andProjectPath:(NSString *)projectPath {
    self = [super init];
    if(self != nil){
        self._coffeeScriptPath = coffeeScriptPath;
        self._pathEnvironmentVariable = pathEnvVar;
        self._nodePathEnvironmentVariable = nodePathEnvVar;
        self._projectPath = projectPath;
    }
    return self;
}
*/
-(id)initWithBuildPath:(NSString *)buildPath {
    self = [super init];
    if(self != nil){
        self._buildPath = buildPath;
    }
    return self;
}

-(void)buildWithBuildCategories:(NSArray *)buildCategories {
    self._buildCategories =  buildCategories;
    [self compile];
}



-(void)compile {
    //[self cleanTimer];
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    
    _currentCategoryIndex = 0;
    _currentFileIndex = 0;  //also done in process category
    
    NSString *message = @"Build Starting...";
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
    }
    [self processCategory];
}

-(void)processFileBreatherOnTimer:(NSTimer *)timer {
    [self processFile];
}


-(void)processFile {
    //Options are
    BuildCategory *category = [_buildCategories objectAtIndex:_currentCategoryIndex];
    BuildFile *buildFile = [category.children objectAtIndex:_currentFileIndex];
    NSString *filePath = buildFile.sourceFilePath;
    if([category.action isEqualToString:@"copy"]){
        if([[filePath pathExtension] isEqualToString:@"coffee"]){
            [self createCompileCoffeeScriptTask:filePath];
        }else{
            [self copyItem:filePath];
        }
    }else if([category.action isEqualToString:@"join"]){
        if([[filePath pathExtension] isEqualToString:@"coffee"]){
           [self createCompileCoffeeScriptTask:filePath];
        }else{
            [self readAndJoinFile:filePath];
        }
    }
}

-(void)processFileComplete {
    BuildCategory *category = [_buildCategories objectAtIndex:_currentCategoryIndex];
    BuildFile *buildFile = [category.children objectAtIndex:_currentFileIndex];
    NSString *filePath = buildFile.sourceFilePath;

    if([category.action isEqualToString:@"join"] == NO){
        if(buildFile.shouldMinify == YES){
            [self compileFileWithGoogleClosure:[self resolveBuildPathRelativeToSource:filePath]];
        }
    }
    
    if (_currentFileIndex < [category.children count]-1) {
        _currentFileIndex++;
        [self._processBreather invalidate];
        self._processBreather = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(processFileBreatherOnTimer:) userInfo:nil repeats:NO];
    }else{
        [self processFilesComplete]; //not sure we need this now
    }
}

-(void)processFilesComplete {
    BuildCategory *category = [_buildCategories objectAtIndex:_currentCategoryIndex];
    if([category.action isEqualToString:@"join"]){
        NSString *categoryBuildPath = [[NSString alloc] initWithFormat:@"%@/%@",_buildPath,category.destination];
        NSError *error;
        [self._compiledFileString writeToFile:categoryBuildPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        //TODO probably need individual minify
        if(category.shouldMinify == YES){
            [self compileFileWithGoogleClosure:categoryBuildPath];
        }
        
        [categoryBuildPath release];
    }
    
    [self processCategoryComplete];
}

-(void)processCategory {
    BuildCategory *category = [_buildCategories objectAtIndex:_currentCategoryIndex];
    _currentFileIndex = 0;
    if([category.action isEqualToString:@"join"]){
        self._compiledFileString = @"";
    }
    if([category.children count] > 0){
        [self processFile];
    }
}

-(void)processCategoryComplete {
    if(_currentCategoryIndex < [_buildCategories count]-1){
        _currentCategoryIndex++;
        [self processCategory];
    }else{
        [self processCategoriesComplete];
    }
}

-(void)processCategoriesComplete {
    NSString *message = @"Build Complete!";
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
    }
    if([self.delegate respondsToSelector:@selector(buildHasCompleted)]){
        [delegate buildHasCompleted];
    }
}

-(void)copyItem:(NSString *)filePath {
    NSString *copyPath = [self resolveBuildPathRelativeToSource:filePath];
     
    NSURL *source = [[NSURL alloc]initFileURLWithPath:filePath];
    NSURL *destination = [[NSURL alloc]initFileURLWithPath:copyPath];
    
    if ( [[NSFileManager defaultManager] isReadableFileAtPath:[source path]] ){
        [[NSFileManager defaultManager] copyItemAtURL:source toURL:destination error:nil];
    }
    
    NSString *message = [[NSString alloc]initWithFormat:@"Copied: %@",filePath];
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
    }
    [source release];
    [destination release];
    
    [self processFileComplete];
}

-(void)readAndJoinFile:(NSString *)filePath {
    NSString *fileJS = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    self._compiledFileString = [self._compiledFileString stringByAppendingString:@"/*filePath  */\n"];    //add new line after js
    self._compiledFileString = [self._compiledFileString stringByAppendingString:fileJS];
    self._compiledFileString = [self._compiledFileString stringByAppendingString:@"\n"];    //add new line after js
    NSString *message = [[NSString alloc]initWithFormat:@"Added: %@",filePath];
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
    }
    [self processFileComplete]; 
}

-(void)createCompileCoffeeScriptTask:(NSString *)filePath {
    PreferencesViewController *pvc = [(AppDelegate *)[[NSApplication sharedApplication] delegate] preferencesViewController];
    NSPipe *pipe = [NSPipe pipe];
    self._fileHandle = [pipe fileHandleForReading];
    [_fileHandle readInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readPipe:) name:NSFileHandleReadCompletionNotification object:_fileHandle];
    self._task = [[NSTask alloc] init];
    [_task setStandardOutput:pipe];
    [_task setStandardError:pipe];

    [_task setLaunchPath: pvc.coffeeScriptFilePath];
    
    NSMutableArray *arguments = [[NSMutableArray alloc]init];
    //[arguments addObject:@"--join"];
    //[arguments addObject:buildPath];
    [arguments addObject:@"--compile"];
    [arguments addObject:@"-p"];
    [arguments addObject:@"-b"];
    /*
     for (OutlineViewItem *files in scriptsArray) {
     [arguments addObject:[(FileDataContainer *) files.data path]];
     }
     */
    [arguments addObject:filePath];
    //[_task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:_nodePathEnvironmentVariable, @"NODE_PATH", _pathEnvironmentVariable, @"PATH", nil]];
    [_task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pvc.nodePathEnvironmentVariable, @"NODE_PATH", pvc.pathEnvironmentVariable, @"PATH", nil]];
    
    [_task setArguments:arguments];
    @try{
        
        [_task launch];
    }@catch(NSException *exception){
        [_task release];
        self._task = nil;
        [self errorInitiatingTask];
    }
    [arguments release];
}

/**
 * Compile task has been completed and has returned the incoming text, this method then determins wether cuurent file belongs to a join category or simply needs to be written to file
 */
-(void)completedTask:(NSString *)string {
    BuildCategory *category = [_buildCategories objectAtIndex:_currentCategoryIndex];
    BuildFile *buildFile = [category.children objectAtIndex:_currentFileIndex];
    NSString *filePath = buildFile.sourceFilePath;
    if([category.action isEqualToString:@"join"]){
        self._compiledFileString = [self._compiledFileString stringByAppendingString:string];
    }else{
        //write js
        NSString *buildPath = [self resolveBuildPathRelativeToSource:filePath];
        //buildPath = [buildPath stringByDeletingPathExtension];
        //buildPath = [buildPath stringByAppendingPathExtension:@"js"];
        NSError *error;
        [string writeToFile:buildPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    NSString *message = [[NSString alloc]initWithFormat:@"Compiled: %@",filePath];
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
    }
    [message release];
    [self processFileComplete];
}

-(void)errorInitiatingTask {
    BuildCategory *category = [_buildCategories objectAtIndex:_currentCategoryIndex];
    BuildFile *buildFile = [category.children objectAtIndex:_currentFileIndex];
    NSString *filePath = buildFile.sourceFilePath;
    NSString *message = [[NSString alloc]initWithFormat:@"Could not launch coffee compiler: %@",filePath];
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
    }
    [self abortBuild];
    [message release];
}

-(void)abortBuild {
    NSString *message = @"Build Aborted!";
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
    }
    if([self.delegate respondsToSelector:@selector(buidHasAborted)]){
        [delegate buidHasAborted];
    }
}

-(void)errorEndingTask:(NSString *)string {
    BuildCategory *category = [_buildCategories objectAtIndex:_currentCategoryIndex];
    BuildFile *buildFile = [category.children objectAtIndex:_currentFileIndex];
    NSString *filePath = buildFile.sourceFilePath;
    NSString *message = [[NSString alloc]initWithFormat:@"Compile Error: %@",filePath];
    if([self.delegate respondsToSelector:@selector(buildSendsMessage:)]){
        [delegate buildSendsMessage:message];
        [delegate buildSendsMessage:string];
    }
    [self abortBuild];
    [message release];
}

-(void)readPipe:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSFileHandleReadCompletionNotification object:_fileHandle];
    NSLog( @"%s" , __PRETTY_FUNCTION__ );
    NSData *data;
    NSString *incomingText;
    
    if([notification object] != _fileHandle)
        return;
    
    data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    incomingText = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]autorelease];
    
    
    if (_task) {
        [_task terminate];
        [self._task release];
        self._task = nil;
        //NSLog(@"fileHandle retaincount:%lu",[self._fileHandle retainCount]);
        //[self.fileHandle release];
        //self.fileHandle = nil;
        //[_fileHandle readInBackgroundAndNotify];
    }
    
    NSRange range = [incomingText rangeOfString: @"Error:"];
    
    if(range.location == 0){
        [self errorEndingTask:incomingText];
    }else {
        [self completedTask:incomingText]; 
    }
}

-(void)compileFileWithGoogleClosure:(NSString *)filePath {
    PreferencesViewController *pvc = [(AppDelegate *)[[NSApplication sharedApplication] delegate] preferencesViewController];
    NSPipe *pipe = [NSPipe pipe];
    self._fileHandle = [pipe fileHandleForReading];
    [_fileHandle readInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readClosurePipe:) name:NSFileHandleReadCompletionNotification object:_fileHandle];
    self._task = [[NSTask alloc] init];
    [_task setStandardOutput:pipe];
    [_task setStandardError:pipe];
    [_task setLaunchPath: pvc.javaExecutableFilePath];///usr/bin/java
    NSMutableArray *arguments = [[NSMutableArray alloc]init];
    [arguments addObject:@"-jar"];
    [arguments addObject:pvc.googleClosureCompilerFilePath];//@"/usr/local/bin/compiler.jar"
    [arguments addObject:@"--js"];
    [arguments addObject:filePath];
    [_task setArguments:arguments];
    
    @try{
        [_task launch];
        [_task waitUntilExit];
        int status = [_task terminationStatus];
        NSLog(@"closure compiler success value %d",status);

        if (status == 0){
            NSLog(@"Task succeeded.");
            
            NSRange errorRange = [self._closureFileOutput rangeOfString: @"ERROR -"];
            NSRange warningRange = [self._closureFileOutput rangeOfString: @"WARNING -"];
            if(errorRange.location != NSNotFound){
                [self errorEndingTask:self._closureFileOutput];
            }else if(warningRange.location != NSNotFound){
                [self errorEndingTask:self._closureFileOutput];
            }else{
                NSError *error;
                [self._closureFileOutput writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            }
            
        }else{
            NSLog(@"Task failed.");
        }
        
        [self._task release];
        self._task = nil;
    }@catch(NSException *exception){
        [_task release];
        self._task = nil;
        [self errorInitiatingTask];
    }
    [arguments release];
}

-(void)readClosurePipe:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSFileHandleReadCompletionNotification object:_fileHandle];
    NSLog( @"%s" , __PRETTY_FUNCTION__ );
    NSData *data;
    NSString *incomingText;
    
    if([notification object] != _fileHandle)
        return;
    
    data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    incomingText = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]autorelease];
    
    //NSLog(@"result %@",incomingText);
    /*
    if (_task) {
        [_task terminate];
        [self._task release];
        self._task = nil;
        NSLog(@"fileHandle retaincount:%lu",[self._fileHandle retainCount]);
        //[self.fileHandle release];
        //self.fileHandle = nil;
        //[_fileHandle readInBackgroundAndNotify];
    }
    */
    self._closureFileOutput = [incomingText copy];
    
    
    
    /*
    if(range.location == 0){
        [self errorEndingTask:incomingText];
    }else {
        [self completedTask:incomingText]; 
    }
     */
}

-(NSString *)resolveBuildPathRelativeToSource:(NSString *)filePath {
    //NSString *buildPath = [[NSString alloc] initWithFormat:@"%@/build/",_projectPath];
    NSArray *buildComponents = [_buildPath pathComponents];
    NSArray *itemComponenets = [filePath pathComponents];
    //interate through path and check where they diverge
    NSString *relativePath;
    NSMutableArray *relativePathComponents = [[NSMutableArray alloc]init];
    BOOL assembleRelativePath = NO;
    for(int i=0; i < [itemComponenets count]; i++){
        if(assembleRelativePath){
            [relativePathComponents addObject:[itemComponenets objectAtIndex:i]];
        }
        if([buildComponents count] > i){
            if([[itemComponenets objectAtIndex:i] isEqualToString:[buildComponents objectAtIndex:i]] == NO){
                if(assembleRelativePath == NO) {
                    assembleRelativePath = YES;//skip this level as this should the level where they diverge
                }
            }
        }
    }
    
    relativePath = [NSString pathWithComponents:relativePathComponents];
    
    NSString *copyPath = [_buildPath stringByAppendingString:@"/"];
    
    copyPath = [copyPath stringByAppendingString:relativePath];
    copyPath = [copyPath stringByDeletingPathExtension];
    copyPath = [copyPath stringByAppendingPathExtension:@"js"];
    //[buildPath release];
    [relativePathComponents release];
    return copyPath;
    
}





@end
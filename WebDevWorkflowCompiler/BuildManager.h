//
//  BuildManager.h
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 02/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BuildManagerDelegate;

@interface BuildManager : NSObject {
    @private
    NSArray *_buildCategories;
    NSString *_coffeeScriptPath;
    NSString *_pathEnvironmentVariable;
    NSString *_nodePathEnvironmentVariable;
    NSString *_projectPath;
    @public
    id<BuildManagerDelegate> delegate;
}
@property (nonatomic, assign) id<BuildManagerDelegate> delegate;
/*
-(id)initWithCoffeeScriptPath:(NSString *)coffeeScriptPath andPathEnvironmentVariable:(NSString *)pathEnvVar andNodePathEnvironmentVariable:(NSString *)nodePathEnvVar andProjectPath:(NSString *)projectPath;
*/
-(id)initWithBuildPath:(NSString *)buildPath;
-(void)buildWithBuildCategories:(NSArray *)buildCategories;
@end


/*
 Build Manager Delegate
 */
@protocol BuildManagerDelegate <NSObject>
@optional
-(void)buildSendsMessage:(NSString *)message;
-(void)buildHasCompleted;
-(void)buidHasAborted;
@end

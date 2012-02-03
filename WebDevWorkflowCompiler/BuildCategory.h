//
//  BuildCategory.h
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 02/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildCategory : NSObject

@property (nonatomic, retain) NSString *action;
@property (nonatomic, retain) NSArray *children;
@property (nonatomic, retain) NSString *destination;
@property (assign) BOOL shouldMinify;

-(id)initWithAction:(NSString *)action andChildren:(NSArray *)children andDestination:(NSString *)destination;

@end

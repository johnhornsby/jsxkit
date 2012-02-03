//
//  BuildCategory.m
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 02/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "BuildCategory.h"

@implementation BuildCategory

@synthesize action;
@synthesize children;
@synthesize destination;
@synthesize shouldMinify;

- (void)dealloc {
    [self.action release];
    [self.children release];
    [self.destination release];
    [super dealloc];
}

-(id)initWithAction:(NSString *)action andChildren:(NSArray *)children andDestination:(NSString *)destination {
    self = [super init];
    if(self){
        self.action = action;
        self.children = children;
        self.destination = destination;
        self.shouldMinify = NO;
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"action:%@ destination:%@ children:%@",action,destination,children];
}


@end

//
//  FolderDataContainer.m
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "FolderDataContainer.h"
#import "ItemDataContainer.h"

@implementation FolderDataContainer

@synthesize isModified;
@synthesize children;
@synthesize hasChildren;

+(id)folderDataContainerForLabel:(NSString *)string andForParent:(ItemDataContainer *)par andWithType:(NSString *)t{
    FolderDataContainer *folderDataContainer = [[[FolderDataContainer alloc]initWithLabel:string andWithParent:par andWithType:t]autorelease];
    return folderDataContainer;
}

-(id)initWithLabel:(NSString *)label andWithParent:(ItemDataContainer *)parent andWithType:(NSString *)type {
    self = [super initWithLabel:label andWithParent:parent andWithType:type];
    if(self){
        self.isModified = NO;
        self.parent = parent;
        self.children = [NSMutableArray array];
        self.hasChildren = NO;
    }
    return self; 
}

-(NSString *) description {
	return [NSString stringWithFormat:@"<FolderDataContainer> label: %@\ntype: %@\nisModified: %@\n",label,type,(isModified) ? @"YES" : @"NO"];
}

-(void)dealloc
{
    [children release];
    [super dealloc];
}

#pragma -mark ItemDataContainer Override Methods
-(NSInteger)numberOfChildren {
    return [children count];
}

@end

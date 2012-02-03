//
//  ItemDataContainer.m
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "ItemDataContainer.h"

@implementation ItemDataContainer

@synthesize parent;
@synthesize label;
@synthesize type;

+(id)itemDataContainerForLabel:(NSString *)label andForParent:(ItemDataContainer *)parent andWithType:(NSString *)type{
    return [[[ItemDataContainer alloc]initWithLabel:label andWithParent:parent andWithType:type]autorelease];
}

-(id)initWithLabel:(NSString *)label andWithParent:(ItemDataContainer *)parent andWithType:(NSString *)type {
    self = [super init];
    if(self){
        self.label = label;
        self.type = type;
        self.parent = parent;
    }
    return self; 
}


-(void)dealloc
{
	[label release];
	[type release];
	[parent release];
    [super dealloc];
}

-(NSString *)typeOfDataContainer {
    return type;
}
-(NSInteger)numberOfChildren {
    return 0;
}

@end

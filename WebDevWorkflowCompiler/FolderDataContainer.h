//
//  FolderDataContainer.h
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemDataContainer.h"

@interface FolderDataContainer : ItemDataContainer{
    BOOL isModified;
    NSMutableArray *children;
    BOOL hasChildren;
}

@property (assign) BOOL isModified;
@property (nonatomic, retain) NSMutableArray *children;
@property (assign) BOOL hasChildren;

+(id)folderDataContainerForLabel:(NSString *)string andForParent:(ItemDataContainer *)par andWithType:(NSString *)t;
-(id)initWithLabel:(NSString *)label andWithParent:(ItemDataContainer *)parent andWithType:(NSString *)t;
@end

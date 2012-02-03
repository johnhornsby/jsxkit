//
//  ItemDataContainer.h
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemDataContainer : NSObject {
    ItemDataContainer *parent;
	NSString *label;
	NSString *type;
}
@property (nonatomic,retain) ItemDataContainer *parent;
@property (nonatomic,retain) NSString *label;
@property (nonatomic,retain) NSString *type;

+(id)itemDataContainerForLabel:(NSString *)string andForParent:(ItemDataContainer *)par andWithType:(NSString *)t;
-(id)initWithLabel:(NSString *)string andWithParent:(ItemDataContainer *)par andWithType:(NSString *)t;
-(NSString *)typeOfDataContainer;
-(NSInteger)numberOfChildren;

@end

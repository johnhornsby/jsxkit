//
//  OutlineItem.h
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 22/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutlineViewItem : NSObject <NSCoding, NSCopying> {
    NSString *type;
    NSString *label;
    OutlineViewItem *parent;
    NSMutableArray *children;
    id data;
    BOOL childrenAreOrderable;
    NSMutableArray *compileOrderValues;
    BOOL shouldMinify;
}

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) OutlineViewItem *parent;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain) id data;
@property (assign) BOOL childrenAreOrderable;
@property (nonatomic, retain) NSMutableArray *compileOrderValues;
@property (assign) BOOL shouldMinify;

+(id)outlineViewItemForLabel:(NSString *)label andType:(NSString *)type andParent:(OutlineViewItem *)parent;
-(id)initWithLabel:(NSString *)label andType:(NSString *)type andParent:(OutlineViewItem *)parent; 
-(NSMutableArray*)children;
-(OutlineViewItem *)childAtIndex:(NSInteger)index;
-(OutlineViewItem *)childForLabel:(NSString *)label;
-(BOOL)hasChildren;
-(NSInteger)numberOfChildren;
-(void)removeChild:(OutlineViewItem *)child;
-(void)appendChild:(OutlineViewItem *)child;
-(void)addChild:(OutlineViewItem *)child atIndex:(NSInteger)index;
-(id)objectValueForTableColumn:(NSTableColumn *)tableColumn;
-(NSInteger)indexForChild:(OutlineViewItem *)child;
-(void)setObjectValue:(id)value forTableColumn:(NSTableColumn *)tableColumn;
-(void)updateCompileOrderValues;
-(void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn;
-(NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn;
-(void)moveChildrenTo:(OutlineViewItem *)outlineViewItem;
@end

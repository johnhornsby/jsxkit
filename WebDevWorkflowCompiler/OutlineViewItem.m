//
//  OutlineViewItem.m
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 22/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "OutlineViewItem.h"
#import "AppDelegate.h"
#import "ProjectViewController.h"

@implementation OutlineViewItem

@synthesize type;
@synthesize label;
@synthesize children;
@synthesize data;
@synthesize parent;
@synthesize childrenAreOrderable;
@synthesize compileOrderValues;
@synthesize shouldMinify;

-(void)dealloc{
    [type release];
    [label release];
    [children release];
    [data release];
    [parent release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    OutlineViewItem *copy = [[[self class] allocWithZone:zone] init];
    copy.label = [[self.label copyWithZone:zone]autorelease];
    copy.type = [[self.type copyWithZone:zone]autorelease];
    copy.parent = [[self.parent copyWithZone:zone]autorelease];
    copy.children = [[self.children copyWithZone:zone]autorelease];
    copy.childrenAreOrderable = self.childrenAreOrderable;
    copy.data = [[self.data copyWithZone:zone]autorelease];
    copy.compileOrderValues = [[self.compileOrderValues copyWithZone:zone]autorelease];
    copy.shouldMinify = self.shouldMinify;
    return copy;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self){
        self.label = [aDecoder decodeObjectForKey:@"label"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.parent = [aDecoder decodeObjectForKey:@"parent"];
        self.children = [aDecoder decodeObjectForKey:@"children"];
        self.childrenAreOrderable = [aDecoder decodeBoolForKey:@"childrenAreOrderable"];
        self.data = [aDecoder decodeObjectForKey:@"data"];
        self.compileOrderValues = [aDecoder decodeObjectForKey:@"compileOrderValues"];
        self.shouldMinify = [aDecoder decodeBoolForKey:@"shouldMinify"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.label forKey:@"label"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.parent forKey:@"parent"];
    [aCoder encodeObject:self.children forKey:@"children"];
    [aCoder encodeBool:self.childrenAreOrderable forKey:@"childrenAreOrderable"];
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeObject:self.compileOrderValues forKey:@"compileOrderValues"];
    [aCoder encodeBool:self.shouldMinify forKey:@"shouldMinify"];
}

+(id)outlineViewItemForLabel:(NSString *)label andType:(NSString *)type andParent:(OutlineViewItem *)parent {
    return [[[OutlineViewItem alloc] initWithLabel:label andType:type andParent:parent]autorelease];
}

-(id)initWithLabel:(NSString *)label andType:(NSString *)type andParent:(OutlineViewItem *)parent {
    self = [super init];
    if(self){
        self.label = label;
        self.type = type;
        self.parent = parent;
        self.children = [NSMutableArray array];
        self.childrenAreOrderable = NO;
        self.shouldMinify = NO;
    }
    return self;
}

/**
 * Parent responsibility
 **/
//-(NSMutableArray*)children {
//    return self.children;
//}

/**
 * Parent responsibility
 **/
-(OutlineViewItem *)childAtIndex:(NSInteger)index {
    if(index < [children count]){
        return [children objectAtIndex:index];
    }else{
        NSLog(@"childAtIndex Index out of range");
        return nil;
    }
}

/**
 * Parent responsibility
 **/
-(OutlineViewItem *)childForLabel:(NSString *)label {
    for(OutlineViewItem *item in children){
        if([item.label isEqualToString:label]){
            return item;
        }
    }
    return nil;
}

/**
 * Parent responsibility
 **/
-(NSInteger)indexForChild:(OutlineViewItem *)child {
    return [children indexOfObject:child];
}

/**
 * Parent responsibility
 **/
-(BOOL)hasChildren {
    if([children count] > 0){
        return YES;
    }else{
        return NO;
    }
}

/**
 * Parent responsibility
 **/
-(NSInteger)numberOfChildren {
    return [children count];
}

/**
 * Parent responsibility
 **/
-(void)removeChild:(OutlineViewItem *)child {
    if([children indexOfObject:child] != NSNotFound){
        child.parent = nil;
        [children removeObject:child];
    }else{
        NSLog(@"Can't remove child as it is not found in OutlineViewItem");
    }
	[self updateCompileOrderValues];
}

/**
 * Parent responsibility
 **/
-(void)appendChild:(OutlineViewItem *)child {
	[children addObject:child];
    child.parent = self;
	[self updateCompileOrderValues];
}

/**
 * Parent responsibility
 **/
-(void)addChild:(OutlineViewItem *)child atIndex:(NSInteger)index {
	[children insertObject:child atIndex:index];
	[self updateCompileOrderValues];
}

/**
 *Child responsibility
 **/
-(id)objectValueForTableColumn:(NSTableColumn *)tableColumn {
    if(tableColumn == nil) return nil;
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if([tableColumn.identifier isEqualToString:@"Action"]){
        if([type isEqualToString:@"file"]){
            return parent.label;
        }else{
            return @"";
        }
    }else if([tableColumn.identifier isEqualToString:@"Minify"]){
        if([type isEqualToString:@"file"]){
            return [NSNumber numberWithBool:self.shouldMinify];
        }else{
            return @"";
        }
    }else if([tableColumn.identifier isEqualTo:@"BuildOrder"]){
        if(parent.childrenAreOrderable){
            if([type isEqualToString:@"file"]){
                NSInteger index = [parent indexForChild:self];
				return [parent.compileOrderValues objectAtIndex:index];
            }else{
               return @""; 
            }
        }else{
            return @"";
        }
    }else {
        if([type isEqualToString:@"file"]){
            /**
             TODO
             The project path must relate to the label. If this has been saved to a different folder structur then it can differ
             **/
           // AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            //ProjectViewController *projectViewController = appDelegate.projectViewController;
            //NSString *projectPath = projectViewController.projectPath;
            //NSRange range = [label rangeOfString:projectPath];
            //return [label substringFromIndex:range.length+range.location];
            /*
            if(range.location == 0){
                return label;
            }else{
                return [label substringFromIndex:range.length+range.location];
            }
             */
            
            //Label here should be relative
            return label;
        }else{
            return label;
        }
    }
}

/**
 *Child responsibility
 **/
-(void)setObjectValue:(id)value forTableColumn:(NSTableColumn *)tableColumn {
    if(tableColumn == nil) return;
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
	if([type isEqualToString:@"file"]){
		if([tableColumn.identifier isEqualToString:@"Action"]){
            OutlineViewItem *destinationFolder = [parent.parent childForLabel:value];
            OutlineViewItem *originFolder = parent;
            [self retain];                              //must increase the retain count durring the remove and append as the parent.children array is the only object holding onto self, and so is released before it can be appended.
            [originFolder removeChild:self];
            [destinationFolder appendChild:self];
            [self release];
		}else if([tableColumn.identifier isEqualToString:@"BuildOrder"]){
			NSInteger valueIndex = [parent.compileOrderValues indexOfObject:value];
            NSInteger selfIndex = [parent.children indexOfObject:self]; 
			[parent.children exchangeObjectAtIndex:valueIndex withObjectAtIndex:selfIndex];
		}else if([tableColumn.identifier isEqualToString:@"Minify"]){
            CFBooleanRef b = (CFBooleanRef)value;
            if(b == kCFBooleanTrue){
                self.shouldMinify = YES;
            }else{
                self.shouldMinify = NO;
            }
        }
	}
}

/**
 * Parent responsibility
 **/
-(void)updateCompileOrderValues {
	if(compileOrderValues==nil){
		self.compileOrderValues = [NSMutableArray array];
	}
	[compileOrderValues removeAllObjects];
	for(int i=0;i<[children count];i++){
		[compileOrderValues addObject: [NSString stringWithFormat:@"%d",i+1]];
	}
	
}

/**
 *Child responsibility
 **/
-(void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn {
    
    if(tableColumn == nil) return;
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    if([type isEqualTo:@"file"]){
        if([tableColumn.identifier isEqualTo:@"BuildOrder"]){
            if(parent.childrenAreOrderable){
                [cell setRepresentedObject:parent.compileOrderValues];
            }else{
                //NSLog(@"hello");
            }
        }else if([tableColumn.identifier isEqualTo:@"Action"]){
            NSMutableArray *array = [[NSMutableArray alloc]init];
            NSArray *rootChildren = parent.parent.children;
            for(OutlineViewItem *folder in rootChildren){
                [array addObject:folder.label];
            }
            [cell setRepresentedObject:array];
            [array release];
        }else if([tableColumn.identifier isEqualTo:@"Minify"]){
            [cell setTitle:@""];
        }
    }
}

/**
 *Child responsibility
 **/
-(NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn {
    
    if (tableColumn == nil) {
        return nil;
    }
    //NSLog( @"%s" , __PRETTY_FUNCTION__ );
    NSInteger row = [outlineView rowForItem:self];
    if([type isEqualTo:@"file"]){
        if(parent.childrenAreOrderable){
            return [tableColumn dataCellForRow:row];
        }else{
            if([tableColumn.identifier isEqualToString:@"Action"] || [tableColumn.identifier isEqualToString:@"Minify"]){
                return [tableColumn dataCellForRow:row];
            }else {
                return [[[NSTextFieldCell alloc]initTextCell:@""] autorelease];
            }
        }
    }else{
        if(childrenAreOrderable){
            if([tableColumn.identifier isEqualToString:@"file"]){
                NSTextFieldCell *cell = [[[NSTextFieldCell alloc]initTextCell:@""] autorelease];
                
                return cell;
            }
        }
    }
    return [[[NSTextFieldCell alloc]initTextCell:@""] autorelease];
}

-(void)moveChildrenTo:(OutlineViewItem *)outlineViewItem {
    if(childrenAreOrderable){
        NSInteger childrenCount = [children count];
        OutlineViewItem *destinationParentFolder = outlineViewItem;
        if(childrenCount > 0){
            for(NSInteger i=childrenCount-1;i>-1;i--){
                OutlineViewItem *child = [children objectAtIndex:i];
                [child retain];//must increase the retain count durring the remove and append as the parent.children array is the only object holding onto self, and so is released before it can be appended.
                [self removeChild:child];
                [destinationParentFolder appendChild:child];
                [child release];
            }
        }
    }
}

@end

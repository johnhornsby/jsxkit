//
//  FileDataContainer.m
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import "FileDataContainer.h"
#import "OutlineViewItem.h"

@implementation FileDataContainer

@synthesize nsurl;
@synthesize modificationDate;
@synthesize isModified;
@synthesize parent;

- (id)copyWithZone:(NSZone *)zone {
    FileDataContainer *copy = [[[self class] allocWithZone:zone] init];
    copy.nsurl = [[self.nsurl copyWithZone:zone]autorelease];
    copy.modificationDate = [[self.modificationDate copyWithZone:zone]autorelease];
    copy.parent = [[self.parent copyWithZone:zone]autorelease];
    copy.isModified = self.isModified;
    return copy;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self){
        self.nsurl = [aDecoder decodeObjectForKey:@"nsurl"];
        self.modificationDate = [aDecoder decodeObjectForKey:@"modificationDate"];
        self.parent = [aDecoder decodeObjectForKey:@"parent"];
        self.isModified = [aDecoder decodeBoolForKey:@"isModified"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.nsurl forKey:@"nsurl"];
    [aCoder encodeObject:self.modificationDate forKey:@"modificationDate"];
    [aCoder encodeObject:self.parent forKey:@"parent"];
    [aCoder encodeBool:self.isModified forKey:@"isModified"];
}

-(void)dealloc {
    [nsurl release];
    [modificationDate release];
    [super dealloc];
}

+(id)fileDataContainerForURL:(NSURL*)url andDate:(NSDate *)date andParent:(OutlineViewItem *)parent {
    return [[[FileDataContainer alloc]initWithURL:url andDate:date andParent:parent]autorelease];
}

-(id)initWithURL:(NSURL*)url andDate:(NSDate *)date andParent:(OutlineViewItem *)parent {
    self = [super init];
    if(self){
        self.nsurl = url;
        self.modificationDate = date;
        self.isModified = YES;
        self.parent = parent;
    }
    return self; 
}

-(NSString *) description {
	return [NSString stringWithFormat:@"<FileDataContainer> path: %@\nisModified: %@\nmodification date: %@\n",[nsurl path],(isModified) ? @"YES" : @"NO",[modificationDate descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" timeZone:nil locale:nil]];
}



-(void)removeFromParent {
    if(self.parent != nil){
        [parent removeChild:self];
        self.parent = nil;
    }
}

-(NSString *)path {
    return [nsurl path];
}

#pragma -mark ItemDataContainer Protocol Methods

@end

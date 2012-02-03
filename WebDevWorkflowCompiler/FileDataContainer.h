//
//  FileDataContainer.h
//  WebDevWorkflowCompiler
//
//  Created by John Hornsby on 21/11/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutlineViewItem.h"

@interface FileDataContainer : NSObject <NSCopying, NSCoding> {
    NSURL *nsurl;
    NSDate *modificationDate;
    BOOL isModified;
}

@property (nonatomic,retain) NSURL *nsurl;
@property (nonatomic,retain) NSDate *modificationDate;
@property (nonatomic,retain) OutlineViewItem *parent;
@property (assign) BOOL isModified;

+(FileDataContainer *)fileDataContainerForURL:(NSURL*)url andDate:(NSDate *)date andParent:(OutlineViewItem *)parent;
-(FileDataContainer *)initWithURL:(NSURL*)url andDate:(NSDate *)date andParent:(OutlineViewItem *)parent;
-(void)removeFromParent;
-(NSString *)path;

@end

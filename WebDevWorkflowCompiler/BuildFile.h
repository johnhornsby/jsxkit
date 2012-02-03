//
//  BuildFile.h
//  WebDevWorkflowCompiler
//
//  Created by john hornsby on 14/12/2011.
//  Copyright (c) 2011 Interactive Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildFile : NSObject

@property (retain) NSString *sourceFilePath;
@property (assign) BOOL shouldMinify; 

@end

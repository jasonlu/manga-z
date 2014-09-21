//
//  DropZone.h
//  Manga-z
//
//  Created by Jason Lu on 9/20/14.
//  Copyright (c) 2014 Jason Lu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface DropZone : NSView


- (BOOL)openFile:(NSString *) filePath;
- (BOOL)drawImage:(NSData*) data;


@end

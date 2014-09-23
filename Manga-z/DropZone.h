//
//  DropZone.h
//  Manga-z
//
//  Created by Jason Lu on 9/20/14.
//  Copyright (c) 2014 Jason Lu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
@class AppDelegate;

@interface DropZone : NSView

- (BOOL)openFile:(NSString *) filepath;
- (BOOL)updateBackgroundWithImage:(NSImage*) image;

@end

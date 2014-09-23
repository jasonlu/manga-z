//
//  AppDelegate.h
//  Manga-z
//
//  Created by Jason Lu on 9/20/14.
//  Copyright (c) 2014 Jason Lu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
#import "DropZone.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSString *_currentFilepath;
    NSTextField *_filepathLabel;

}
@property (strong) IBOutlet DropZone *_dropZone;
@property (strong) IBOutlet NSTextField *_filepathLabel;


- (BOOL)openFile:(NSString *) filePath;
@end


//
//  AppDelegate.m
//  Manga-z
//
//  Created by Jason Lu on 9/20/14.
//  Copyright (c) 2014 Jason Lu. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@property (copy) NSString  *_currentFilepath;
@property (weak) IBOutlet NSWindow *window;

@end




@implementation AppDelegate

@synthesize _currentFilepath = _currentFilepath;
@synthesize _filepathLabel = _filepathLabel;
@synthesize _dropZone = _dropZone;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:@"/Volumes/HDD/Pictures/Wallpapers/official-os-x-yosemite-hd-wallpapers.jpg"];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects: [NSArray arrayWithObjects:img, nil] forKeys: [NSArray arrayWithObjects:@"image", nil]];
    
    [_dropZone updateBackgroundWithImage:img];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"updateBackground" object:img userInfo:userInfo];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)openFile:(NSString *) filePath {
    _currentFilepath = filePath;
    [_filepathLabel setStringValue:[filePath lastPathComponent]];

    NSLog(@"Opening file: %@", filePath);
    
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath
                                                     mode:ZipFileModeUnzip];
    
    [unzipFile goToFirstFileInZip];
    ZipReadStream *read= [unzipFile readCurrentFileInZip];
    NSMutableData *data= [[NSMutableData alloc] initWithLength:256];
    int bytesRead= [read readDataWithBuffer:data];
    
    [read finishedReading];
//    [_dropZone drawImage: data];
    
    
    
    NSArray *infos= [unzipFile listFileInZipInfos];
    for (FileInZipInfo *info in infos) {
        NSLog(@"- %@ %@ %d (%d)", info.name, info.date, info.size,
              info.level);
        
        // Locate the file in the zip
        [unzipFile locateFileInZip:info.name];
        
        // Expand the file in memory
        ZipReadStream *read= [unzipFile readCurrentFileInZip];
        NSMutableData *data= [[NSMutableData alloc] initWithLength:256];
        int bytesRead= [read readDataWithBuffer:data];
        [read finishedReading];
    }
    
    
    
    return YES;
}



@end

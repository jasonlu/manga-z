//
//  DropZone.m
//  Manga-z
//
//  Created by Jason Lu on 9/20/14.
//  Copyright (c) 2014 Jason Lu. All rights reserved.
//

#import "DropZone.h"

@implementation DropZone


NSImage* _cover;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if( _cover != nil) {
        //[_cover drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        // Or stretch image to fill view
        [_cover drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    // Drawing code here.
}

- (id) initWithFrame:(NSRect)frameRect {
    if(!(self = [super initWithFrame:frameRect])) {
        NSLog(@"Error: DropZone initWithFrame");
        return self;
    }
    _cover = nil;
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    NSLog(@"Drop init...");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBackground:) name:@"updateBackground" object:nil];
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
        == NSDragOperationGeneric) {
        NSLog(@"Draggin in.");
        return NSDragOperationCopy;
        
    } // end if
    
    // not a drag we can use
    NSLog(@"not a drag we can use.");
    return NSDragOperationNone;
    
} // end draggingEntered

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
} // end prepareForDragOperation

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // define the types we accept
    // NSPasteboardTypeTIFF: (used to be NSTIFFPboardType).
    // NSFilenamesPboardType:An array of NSString filenames
    NSArray *zTypeArray = [NSArray arrayWithObjects: NSFilenamesPboardType, nil];
    NSString *zDesiredType = [zPasteboard availableTypeFromArray:zTypeArray];
    
    if (![zDesiredType isEqualToString:NSFilenamesPboardType]) {
        //this can't happen ???
        NSLog(@"Error MyNSView performDragOperation");
        return NO;
    }
    
    // the pasteboard contains a list of file names
    // Take the first one
    NSArray *zFileNamesAry = [zPasteboard propertyListForType:@"NSFilenamesPboardType"];
    NSString *zPath = [zFileNamesAry objectAtIndex:0];
    NSLog(@"Info: path: %@", zPath);
    [self setNeedsDisplay:YES];
    //    [(AppDelegate *)[[NSApplication sharedApplication] delegate] openFile: zPath];
    [self openFile: zPath];
    
    
    
    return YES;

} // end performDragOperation


- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    [self setNeedsDisplay:YES];
} // end concludeDragOperation


- (BOOL)updateBackgroundWithData:(NSData*) data {
    _cover = [[NSImage alloc] initWithData:data];
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)updateBackgroundWithImage:(NSImage*) image {
    _cover = image;
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)updateBackground:(NSNotification*)notice {
    _cover = notice.userInfo[@"image"];
    [self setNeedsDisplay: YES];
    return YES;

}


- (BOOL)updateBackground {
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:@"/Volumes/HDD/Pictures/Wallpapers/official-os-x-yosemite-hd-wallpapers.jpg"];
    _cover = img;
    [self setNeedsDisplay: YES];
    return YES;
}

- (NSImage*) resizeImage: (NSImage *) orgImage to: (NSInteger) toSize{
    NSSize newSize;
    float w = [orgImage size].width;
    float h = [orgImage size].height;
    if(w > h) {
        newSize.width = toSize;
        newSize.height = toSize * (h / w);
    } else {
        newSize.height = toSize;
        newSize.width = toSize * (w / h);
    }
    NSImage *sourceImage = orgImage;
    // [sourceImage setScalesWhenResized:YES];
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    } else {
        NSImage *newImage = [[NSImage alloc] initWithSize: newSize];
        [newImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
        [newImage unlockFocus];
        NSLog(@"Image resized!");
        return newImage;
    }
    return nil;
}


- (BOOL) saveImageFile: (NSImage *)image atPath: (NSString *) filepath{
    [image lockFocus];
    NSBitmapImageRep *tImgRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, [image size].width, [image size].height)] ;
    NSData *tData = [tImgRep representationUsingType: NSJPEGFileType properties: nil];
    [image unlockFocus];
    NSLog(@"tNewFilepath: %@", filepath);
    [tData writeToFile: filepath atomically: YES];
    return YES;
}

- (BOOL) saveZipFile: (NSString *) dirPath toPath: (NSString *) zipFilepath {
    return YES;
}

- (BOOL)openDir: (NSString *) filepath {
    NSFileManager *fMgr = [[NSFileManager alloc] init];
    NSError *err = nil;
    NSArray *dirContents = [fMgr contentsOfDirectoryAtPath:filepath error:&err];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg' OR self ENDSWITH '.gif' OR self ENDSWITH '.png'"];
    dirContents = [dirContents filteredArrayUsingPredicate:filter];
    id sortByNameAsc = ^(NSString *str1, NSString *str2) {
        return [str1 compare: str2];
    };
    dirContents = [dirContents sortedArrayUsingComparator:sortByNameAsc];
    NSString *coverImagePath = [filepath stringByAppendingPathComponent: [dirContents objectAtIndex:0]];
    _cover = [[NSImage alloc] initWithContentsOfFile: coverImagePath];

    for(NSString* tFilename in dirContents) {
        NSLog(@"file in %@:\t %@", filepath, tFilename);
        NSImage *tOrgImage = nil;
        NSImage *tNewImage = nil;
        NSString *tFilepath = [filepath stringByAppendingPathComponent:tFilename];
        NSString *tNewFilepath = [tFilepath stringByAppendingString:@".new.jpg"];
        tOrgImage = [[NSImage alloc] initWithContentsOfFile:tFilepath];
        tNewImage = [self resizeImage: tOrgImage to: 1024];
        [self saveImageFile: tNewImage atPath: tNewFilepath];
    }
    return YES;
}

- (BOOL)openZip: (NSString *) filepath {
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filepath
                                                     mode:ZipFileModeUnzip];
    
    NSArray *infos= [unzipFile listFileInZipInfos];
    id sortByNameAsc = ^(FileInZipInfo *obj1, FileInZipInfo *obj2){
        return [obj1.name compare:obj2.name];
    };
    NSArray *sortedInfos = [infos sortedArrayUsingComparator:sortByNameAsc];
    FileInZipInfo *firstInfo = [sortedInfos objectAtIndex:0];
    NSString *firstFile = firstInfo.name;
    //[unzipFile goToFirstFileInZip];
    [unzipFile locateFileInZip:firstFile];
    ZipReadStream *read= [unzipFile readCurrentFileInZip];
    NSMutableData *data= [[NSMutableData alloc] initWithLength:1024*1024*10];
    
    int bytesRead= [read readDataWithBuffer:data];
    
    [data setLength:bytesRead];
    NSLog(@"bytesRead: %d", bytesRead);
    
    [read finishedReading];
    
    /*
     NSError *error;
     NSString *globallyUniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
     NSString *tempDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:globallyUniqueString];
     NSURL *tempDirectoryURL = [NSURL fileURLWithPath:tempDirectoryPath isDirectory:YES];
     NSURL *tempFileURL = [tempDirectoryURL URLByAppendingPathComponent:filename];
     [[NSFileManager defaultManager] createDirectoryAtURL:tempDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
     
     
     tempFileURL = [NSURL URLWithString:@"/Users/aoisama/temp.jpg"];
     NSString *t = @"/Users/aoisama/temp.jpg";
     [data writeToFile: t atomically:YES];
     
     NSLog(@"tmp: %@", tempFileURL);
     */
    

    return YES;
    
    
    
    for (FileInZipInfo *info in infos) {
        //        NSLog(@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level);
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

- (BOOL)openFile:(NSString *) filepath {
    
    NSLog(@"Opening file: %@", filepath);
    NSFileManager *fMgr = [[NSFileManager alloc] init];
    BOOL isDir;
    if (![fMgr fileExistsAtPath:filepath isDirectory:&isDir]) {
        return NO;
    }
    if (isDir) {
        return [self openDir: filepath];
    } else {
        return [self openZip: filepath];
    }
}




@end

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


- (BOOL)drawImage:(NSData*) data {
    _cover = [[NSImage alloc] initWithData:data];
    [self setNeedsDisplay: YES];
    return YES;
}


- (BOOL)openFile:(NSString *) filePath {
    
    NSLog(@"Opening file: %@", filePath);
    
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath
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
    
    [self drawImage:data];
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




@end

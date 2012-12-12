//
//  ECDropFileView.m
//  EasyConvert
//
//  Created by icyleaf on 12-10-22.
//  Copyright (c) 2012年 icyleaf. All rights reserved.
//

#import "ECDropFileView.h"

@interface ECDropFileView ()
{
    NSArray *files;
}

- (void)hightlight:(BOOL)isHightlight;
- (void)cancelDropWithError:(NSError *)error;

@end

static NSImage *dropEmptyImage = nil;
static NSImage *dropOnImage = nil;
static NSImage *dropDoneImage = nil;
static NSImage *dropErrorImage = nil;
static BOOL isDropOn = NO;

@implementation ECDropFileView

+ (void)initialize {
    dropEmptyImage = [NSImage imageNamed:@"DropEmpty"];
    dropOnImage = [NSImage imageNamed:@"DropFull"];
    dropDoneImage = [NSImage imageNamed:@"DropDone"];
    dropErrorImage = [NSImage imageNamed:@"DropError"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        //register for all the image types we can display
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    return self;
}

#pragma mark - Drag delegate methods

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    [self.fileNameField setHidden:YES];
    NSPasteboard *pasteBoard = [sender draggingPasteboard];
    if ([[pasteBoard types] containsObject:NSFilenamesPboardType])
    {
        NSArray *tmpfiles = [pasteBoard propertyListForType:NSFilenamesPboardType];
        files = tmpfiles;
        [self hightlight:YES];
        return NSDragOperationGeneric;
    }
    
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    [self.indicator setHidden:NO];
    [self.indicator startAnimation:self];
    for (NSString *fileName in files)
    {
        [self openFile:fileName];
    }
    
    return YES;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    [self hightlight:NO];
    [self.indicator setHidden:YES];
}

#pragma mark - Convert file related methods

- (void)chooseFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setPrompt: NSLocalizedString(@"Select your file", "Preferences -> Open panel prompt")];
    [panel setAllowsMultipleSelection: YES];
    [panel setCanChooseFiles: YES];
    [panel setCanChooseDirectories: NO];
    [panel setCanCreateDirectories: YES];
    [panel setResolvesAliases:YES];
    
    void (^appOpenPanelHandler)(NSInteger) = ^( NSInteger resultCode )
    {
        if(resultCode == NSFileHandlingPanelOKButton)
        {
            [self hightlight:YES];
            [self.indicator setHidden:NO];
            [self.indicator startAnimation:self];

            for (NSURL *fileName in panel.URLs)
            {
                [self performSelector:@selector(openFile:) withObject:[fileName path] afterDelay:0.4];
            }
        }
    };
    
    [panel beginSheetModalForWindow:[self window] completionHandler:appOpenPanelHandler];
}

- (BOOL)openFile:(NSString *)newFile
{
    NSLog(@"File: %@", newFile);
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSError *error;
    
    NSString *content = [[NSString alloc] initWithContentsOfFile:newFile encoding:enc error:&error];
    if (error)
    {
        [self cancelDropWithError:error];
        NSLog(@"Open file with error: %@", [error description]);
        
        return NO;
    }
    
    NSString *fileWithExt = [newFile lastPathComponent];
    NSString *fileExt = [fileWithExt pathExtension];
    NSString *fileName =  [fileWithExt stringByDeletingPathExtension];
    NSString *filePath = [newFile stringByReplacingOccurrencesOfString:fileWithExt withString:@""];
    
    NSString *saveFileName;
    NSString *saveFile;
    if ([self.overwiteFileButton state] != NSOnState)
    {
        saveFileName = [NSString stringWithFormat:@"%@_utf8.%@", fileName, fileExt];
        saveFile = [NSString stringWithFormat:@"%@%@", filePath, saveFileName];
    }
    else
    {
        saveFileName = fileWithExt;
        saveFile = newFile;
    }
    
    [content writeToFile:saveFile atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    [self.fileNameField setStringValue:saveFileName];
    [self.fileNameField setHidden:NO];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [[NSWorkspace sharedWorkspace] openURL:fileURL];
    
    if (error)
    {
        [self cancelDropWithError:error];
        NSLog(@"Write file failed: %@", [error description]);
        return NO;
    }
    
    [self.indicator stopAnimation:NO];
    [self.indicator setHidden:YES];
    
    return YES;
}

-(void) hightlight:(BOOL)isHightlight
{
    [self.dropButton setImage:isHightlight ? dropOnImage : dropEmptyImage];
}

- (void)cancelDropWithError:(NSError *)error
{
    [self.dropButton setImage:dropErrorImage];
    [self.indicator stopAnimation:NO];
    [self.indicator setHidden:YES];
    
    [self.fileNameField setHidden:NO];
    [self.fileNameField setStringValue:[error localizedDescription]];
}


@end

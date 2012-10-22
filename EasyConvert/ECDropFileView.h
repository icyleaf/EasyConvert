//
//  ECDropFileView.h
//  EasyConvert
//
//  Created by icyleaf on 12-10-22.
//  Copyright (c) 2012年 icyleaf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ECDropFileView : NSView

@property (assign) IBOutlet NSButton *dropButton;
@property (assign) IBOutlet NSProgressIndicator *indicator;
@property (assign) IBOutlet NSTextField *fileNameField;
@property (assign) IBOutlet NSButton *overwiteFileButton;

- (IBAction)chooseFile:(id)sender;
- (BOOL)openFile:(NSString *)newFile;
@end

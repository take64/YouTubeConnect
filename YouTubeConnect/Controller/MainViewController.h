//
//  MainViewController.h
//  YouTubeConnect
//
//  Created by TAKEMOTO KOUHEI on 2015/03/14.
//  Copyright (c) 2015年 citrus.tk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController
{
    NSMutableDictionary *videoInfo;
    NSMutableArray *downloadList;
}

@property (nonatomic, retain) IBOutlet NSTextField *urlField;
@property (nonatomic, retain) IBOutlet NSImageView *previewImageView;
@property (nonatomic, retain) IBOutlet NSPopUpButton *outputOptionPopUpButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *downloadIndicator;
@property (nonatomic, retain) IBOutlet NSTextField *downloadLabel;
@property (nonatomic, retain) IBOutlet NSButton *downloadButton;

@property (nonatomic, retain) NSMutableDictionary *videoInfo;
@property (nonatomic, retain) NSMutableArray *downloadList;

#pragma mark - event

//// YouTube URLの入力Return
//- (IBAction) onReturnYouTubeURLField:(id)sender;

@end

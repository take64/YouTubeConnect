//
//  MainViewController.m
//  YouTubeConnect
//
//  Created by TAKEMOTO KOUHEI on 2015/03/14.
//  Copyright (c) 2015年 citrus.tk. All rights reserved.
//

#import "MainViewController.h"

// CitrusDeck
#import "CDCrypt.h"
#import "CDYouTube.h"
#import "CDYouTubeItem.h"
#import "CDExtension.h"
#import "CDHTTPDownload.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize urlField;
@synthesize previewImageView;
@synthesize outputOptionPopUpButton;
@synthesize downloadIndicator;
@synthesize downloadLabel;
@synthesize downloadButton;

@synthesize videoInfo;
@synthesize downloadList;



- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - event

// YouTube URLの入力Return
- (IBAction) onReturnYouTubeURLField:(id)sender
{
    NSLog(@"onReturnYouTubeURLField");
    
    NSString *urlString = [(NSTextField *)sender stringValue];
//    NSLog(@"url => %@", urlString);
    
    // プレビューの表示
    [self loadPreviewImageView:urlString];
    
    // インジケーターの初期化
    [[self downloadIndicator] setDoubleValue:0];
    
    // ラベルの初期化
    [[self downloadLabel] setStringValue:@"0.00 / 0.00MB"];
}

// Downloadボタン押下時
- (IBAction) onCkickDownloadButton:(id)sender
{
    NSLog(@"onCkickDownloadButton");
    
    CDYouTubeItem *item = [[self downloadList] objectAtIndex:
                           [[self outputOptionPopUpButton] indexOfSelectedItem]
                           ];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@.%@",
                      [paths objectAtIndex:0],
                      [CDCrypt urldecode:[self videoInfo][@"title"]],
                      [CDExtension extFormMime:[item type]]
                      ];
    
    [[self downloadIndicator] setMaxValue:[[item filesize] doubleValue]];
    
    
    CDHTTPDownload *dl = [[CDHTTPDownload alloc] init];
    [dl download:[item url] progress:^(double currentProgress) {
        [[self downloadIndicator] setDoubleValue:currentProgress];
        
        [[self downloadLabel] setStringValue:
         [NSString stringWithFormat:@"%.2f / %.2fMB",
          ((double)currentProgress / 1024 / 1024),
          ((double)[[item filesize] doubleValue] / 1024 / 1024)
          ]
         ];
        
    } complete:^{
        [[dl downlaodData] writeToFile:path atomically:YES];
    }];
}




// プレビュー動画の表示
- (void) loadPreviewImageView:(NSString *)urlString
{
    NSString *videoID = [CDYouTube extractVideoIDFromURL:urlString];
    
    NSString *imageURLString = [CDYouTube urlImageFromVideoID:videoID];
    
    [[self previewImageView] setImage:[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
    
    NSString *info = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/get_video_info?video_id=%@&asv=3&el=detailpage", videoID]] encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *paramList = [info componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for(NSString *one in paramList)
    {
        NSArray *kyvl = [one componentsSeparatedByString:@"="];
        [params setValue:kyvl[1] forKey:kyvl[0]];
    }
    [self setVideoInfo:params];
    
    if(params[@"url_encoded_fmt_stream_map"] == nil)
    {
        return ;
    }
    
    paramList = [[CDCrypt urldecode:params[@"url_encoded_fmt_stream_map"]] componentsSeparatedByString:@","];
    NSMutableArray *list = [NSMutableArray array];
    for(NSString *one in paramList)
    {
        CDYouTubeItem *item = [CDYouTubeItem extract:one];
        
        [item appendFilesize];
        
        [list addObject:item];
    }
    
    
    [self setDownloadList:list];
    
    // 出力一覧の再設定
    [[self outputOptionPopUpButton] removeAllItems];
    for(CDYouTubeItem *item in [self downloadList])
    {
        [[self outputOptionPopUpButton] addItemWithTitle:
         [NSString stringWithFormat:@"%@ %@(%@) %.2fMB",
          [item itag],
          [item type],
          [item quality],
          ((double)[[item filesize] integerValue] / 1024 / 1024)
          ]
         ];
    }
}


@end

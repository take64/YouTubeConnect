//
//  MainViewController.m
//  YouTubeConnect
//
//  Created by TAKEMOTO KOUHEI on 2015/03/12.
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
    
    // YouTube URL Field
//    [[self urlField] ]
    
    
    
}


#pragma mark - event

// YouTube URLの入力Return
- (IBAction) onReturnYouTubeURLField:(id)sender
{
    NSLog(@"onReturnYouTubeURLField");
    
    NSString *urlString = [(NSTextField *)sender stringValue];
    NSLog(@"url => %@", urlString);
    
    // プレビューの表示
    [self loadPreviewWebView:urlString];
    
    // インジケーターの初期化
    [[self downloadIndicator] setDoubleValue:0];
    
    // ラベルの初期化
    [[self downloadLabel] setStringValue:@"0.00 / 0.00MB"];
}

// Downloadボタン押下時
- (IBAction) onCkickDownloadButton:(id)sender
{
    NSLog(@"onCkickDownloadButton");
    
    
//    [@"asd" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
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
- (void) loadPreviewWebView:(NSString *)urlString
{
    NSString *videoID = [CDYouTube extractVideoIDFromURL:urlString];
    NSLog(@"videoID => %@", videoID);
    
    NSString *imageURLString = [CDYouTube urlImageFromVideoID:videoID];
    
    NSLog(@"imageURL => %@", imageURLString);
    
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
    
    
    NSLog(@"---- ---- ---- ---- ---- ----");
    paramList = [[CDCrypt urldecode:params[@"url_encoded_fmt_stream_map"]] componentsSeparatedByString:@","];
    NSMutableArray *list = [NSMutableArray array];
    for(NSString *one in paramList)
    {
        CDYouTubeItem *item = [CDYouTubeItem extract:one];
        
        [item appendFilesize];
        
        [list addObject:item];
    }
    
    NSLog(@"%@", list);
    
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
    
    
    
    
////        NSString *one2 = [self urldecode:one];
////        NSString *one2 = one;
//        NSString *one2 = [self urldecode:one];
//        NSLog(@"%@", one2);
//        
//        NSRange range = [one2 rangeOfString:@"url="];
//        NSString *newURL = [one2 substringFromIndex:range.location + 4];
//        NSLog(@"newURL => %@", newURL);
//        
//        
//        
//        
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        
//        NSArray *paramList2 = [one2 componentsSeparatedByString:@"&"];
//        NSString *baseURL = @"";
//        NSMutableArray *paramList3 = [NSMutableArray array];
//        for(NSString *one3 in paramList2)
//        {
//            NSLog(@"%@", one3);
////            if([one3 hasPrefix:@"quality"] == YES)
////            {
////                [dic setValue:[one3 stringByReplacingOccurrencesOfString:@"quality=" withString:@""] forKey:@"quality"];
////            }
//            if([one3 hasPrefix:@"url"] == YES)
//            {
//                baseURL = [one3 stringByReplacingOccurrencesOfString:@"url=" withString:@""];
//                NSLog(@"baseURL => %@", baseURL);
////                [dic setValue:[one3 stringByReplacingOccurrencesOfString:@"url=" withString:@""] forKey:@"url"];
//            }
//            else if([one3 hasPrefix:@"type"])
//            {
//                NSArray *kyvl = [one3 componentsSeparatedByString:@";"];
//                [paramList3 addObject:kyvl[0]];
//            }
////            else if([one3 hasPrefix:@"type"])
////            {
////                
////            }
////            else if([one3 hasPrefix:@"dur"] == YES || [one3 hasPrefix:@"gcr"] == YES || [one3 hasPrefix:@"id"] == YES || [one3 hasPrefix:@"initcwndbps"] == YES || [one3 hasPrefix:@"ip"] == YES || [one3 hasPrefix:@"ipbits"] == YES || [one3 hasPrefix:@"itag"] == YES || [one3 hasPrefix:@"mm"] == YES || [one3 hasPrefix:@"ms"] == YES || [one3 hasPrefix:@"mv"] == YES || [one3 hasPrefix:@"pl"] == YES || [one3 hasPrefix:@"source"] == YES || [one3 hasPrefix:@"upn"] == YES || [one3 hasPrefix:@"expire"])
//            else
//            {
//                [paramList3 addObject:one3];
////                NSArray *kyvl = [one3 componentsSeparatedByString:@"="];
////                [dic setValue:kyvl[1] forKey:kyvl[0]];
//            }
//            
//        }
//        NSString *accessURL = [NSString stringWithFormat:@"%@&%@", baseURL, [paramList3 componentsJoinedByString:@"&"]];
//        
//        NSLog(@"accessURL => %@", accessURL);
////        NSLog(@"%@", dic);
//        [list addObject:accessURL];
//    }
////    NSLog(@"parsed => %@", list);
//    
//    
//    
//    NSString *videoURL = list[0];//[NSString stringWithFormat:@"http://www.youtube.com/get_video?video_id=%@&t=%@&fmt=34", videoID, [self encodeFromPercentEscapesString:params[@"token"]]];
//    
//    NSLog(@"videoURL => %@", videoURL);
//    
////    NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoURL]];
//    
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:videoURL]];
//    [request setHTTPMethod:@"GET"];
////    [request setAllHTTPHeaderFields:@{
////                                      @"Host": @"http://www.youtube.com"
////                                      }];
//    
//    NSURLResponse *response;
//    NSData *videoData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//    
//    
//    
//    [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"/Users/take64/Desktop/videos/%@", params[@"title"]] contents:videoData attributes:nil];
//    
//    NSLog(@"finish");
//    // http://www.youtube.com/get_video_info?video_id
}


//- (NSString*)encodeFromPercentEscapesString:(NSString*)string
//{
//    // %XX -> char
//    NSString *encodedStr = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
//                                                                                                kCFAllocatorDefault,
//                                                                                                (CFStringRef) string,
//                                                                                                CFSTR(""),
//                                                                                                kCFStringEncodingUTF8));
//    
//    return encodedStr;
//}

//- (NSString *)urldecode:(NSString *)stringValue
//{
////    NSString *decodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)stringValue, CFSTR(""), kCFStringEncodingUTF8));
////    return decodedString;
//    return [stringValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//}


@end

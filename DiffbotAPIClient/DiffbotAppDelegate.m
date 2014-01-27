//
//  DiffbotAppDelegate.m
//  DiffbotAPIClient
//
//  Created by Dan on 1/26/14.
//  Copyright (c) 2014 Dan. All rights reserved.
//

#import "DiffbotAppDelegate.h"
#import "DiffbotAPIClient.h"

@implementation DiffbotAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self sampleBatchRequest];
    return YES;
}

- (void)sampleBatchRequest {
    NSString *firstArticleURL = @"http://www.macrumors.com/2014/01/12/your-verse-ipad-ad";
    NSString *secondArticleURL = @"http://www.huffingtonpost.com/2014/01/24/stephen-hawking-black-holes-event-horizons_n_4658220.html";
    
    NSDictionary *dictOne = [DiffbotAPIClient dictForBatchRequest:DiffbotArticleRequest UrlString:firstArticleURL Method:@"GET" OptionalArgs:nil Format:DiffbotAPIFormatJSON];
    
    NSDictionary *dictTwo = [DiffbotAPIClient dictForBatchRequest:DiffbotArticleRequest UrlString:secondArticleURL Method:@"GET" OptionalArgs:nil Format:DiffbotAPIFormatJSON];
    
    [DiffbotAPIClient batchRequests:@[dictOne, dictTwo] withCallback:^(BOOL success, id result) {
        NSLog(@"%@", result);
    }];
}


- (void)sampleAnalyzeRequest {
    NSString *articleURL = @"http://www.macrumors.com/2014/01/12/your-verse-ipad-ad";
    NSDictionary *optionalArgs = @{
                                   @"fields": @"author"
                                   };
    
    [DiffbotAPIClient apiRequest:DiffbotPageClassifierRequest UrlString:articleURL OptionalArgs:optionalArgs Format:DiffbotAPIFormatJSON withCallback:^(BOOL success, id result) {
        if(success) {
            NSLog(@"Call success: %@", result);
        } else {
            NSLog(@"Error: %@", result);
        }
    }];
}

- (void)sampleArticleRequest {
    NSString *articleURL = @"http://www.macrumors.com/2014/01/12/your-verse-ipad-ad";
    NSDictionary *optionalArgs = @{
                                   @"fields": @"author"
                                   };
    
    [DiffbotAPIClient apiRequest:DiffbotArticleRequest UrlString:articleURL OptionalArgs:optionalArgs Format:DiffbotAPIFormatJSON withCallback:^(BOOL success, id result) {
        if(success) {
            NSLog(@"Call success: %@", result);
        } else {
            NSLog(@"Error: %@", result);
        }
    }];
}

- (void)sampleCrawl {
    NSArray *seeds = @[@"http://techcrunch.com"];
    NSString *apiURL = @"http://api.diffbot.com/v2/article";
    [DiffbotAPIClient crawlRequest:@"Crawl" UrlSeeds:seeds ApiUrl:apiURL OptionalArgs:nil withCallback:^(BOOL success, id result) {
        NSLog(@"%@", result);
    }];
}


@end

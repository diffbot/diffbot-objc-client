//
//  DiffbotAPIClient.m
//  DiffbotAPI
//
//  Created by Dan on 1/7/14.
//  Copyright (c) 2014 Dan. All rights reserved.
//

#import "DiffbotAPIClient.h"
#import "NSDictionary+Merge.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define DIFFBOT_API_TOKEN                       @"sampletoken"
#define DIFFBOT_API_BASEURL                     @"http://api.diffbot.com/v2/"

@implementation DiffbotAPIClient

+ (void)apiRequest:(DiffbotAPIRequestType)rType UrlString:(NSString *)urlStr OptionalArgs:(NSDictionary *)optArgs Format:(DiffbotAPIFormatType)formatType withCallback:(DiffbotAPIRequestCallback)callback {

    NSString *apiRequest = [self apiRequestStringFromType:rType];
    [self customRequest:apiRequest UrlString:urlStr OptionalArgs:optArgs Format:formatType withCallback:callback];
}

+ (void)customRequest:(NSString *)apiRequest UrlString:(NSString *)urlStr OptionalArgs:(NSDictionary *)optArgs Format:(DiffbotAPIFormatType)formatType withCallback:(DiffbotAPIRequestCallback)callback {
    NSURL *url = [NSURL URLWithString:urlStr];

    NSString *format = (formatType == DiffbotAPIFormatJSON) ? @"json" : @"xml";
    
    NSDictionary *baseParams = @{
                                 @"format": format,
                                 @"token": DIFFBOT_API_TOKEN,
                                 @"url": url
                                 };
    NSDictionary *params = [NSDictionary dictionaryByMerging:baseParams with:optArgs];
    
    [self makeGETRequest:apiRequest BaseURLStr:DIFFBOT_API_BASEURL Params:params Callback:callback];
}

+ (void)crawlRequest:(NSString *)jobName UrlSeeds:(NSArray *)seeds ApiUrl:(NSString *)apiUrl OptionalArgs:(NSDictionary *)optArgs withCallback:(DiffbotAPIRequestCallback)callback {
    NSDictionary *baseParams = @{
                                 @"token": DIFFBOT_API_TOKEN,
                                 @"apiUrl": apiUrl,
                                 @"seeds": [seeds componentsJoinedByString:@" "],
                                 @"name": jobName
                                 };
    NSDictionary *params = [NSDictionary dictionaryByMerging:baseParams with:optArgs];

    [self makeGETRequest:@"crawl" BaseURLStr:DIFFBOT_API_BASEURL Params:params Callback:callback];
}

+ (void)retrieveCrawlDetails:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback {
    
}

+ (void)pauseCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback {
    NSDictionary *params = @{
                             @"token": DIFFBOT_API_TOKEN,
                             @"name": jobName,
                             @"pause": @"1"
                             };
    
    [self makeGETRequest:@"crawl" BaseURLStr:DIFFBOT_API_BASEURL Params:params Callback:callback];
}

+ (void)unpauseCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback {
    NSDictionary *params = @{
                             @"token": DIFFBOT_API_TOKEN,
                             @"name": jobName,
                             @"pause": @"0"
                             };
    
    [self makeGETRequest:@"crawl" BaseURLStr:DIFFBOT_API_BASEURL Params:params Callback:callback];
}

+ (void)restartCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback {
    NSDictionary *params = @{
                             @"token": DIFFBOT_API_TOKEN,
                             @"name": jobName,
                             @"restart": @"1"
                             };
    
    [self makeGETRequest:@"crawl" BaseURLStr:DIFFBOT_API_BASEURL Params:params Callback:callback];
}

+ (void)deleteCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback {
    NSDictionary *params = @{
                             @"token": DIFFBOT_API_TOKEN,
                             @"name": jobName,
                             @"delete": @"1"
                             };

    [self makeGETRequest:@"crawl" BaseURLStr:DIFFBOT_API_BASEURL Params:params Callback:callback];
}

+ (void)retrieveCrawlDataForJob:(NSString *)jobName DataType:(DiffbotAPIRetrieveCrawlDataType)dataType withCallback:(DiffbotAPIRequestCallback)callback {
    NSString *crawlType = @"data.json";
    if(dataType == DiffbotAPIRetrieveCrawlCSV) crawlType = @"urls.csv";
    
    NSString *getString = [NSString stringWithFormat:@"%@-%@_%@", DIFFBOT_API_TOKEN, jobName, crawlType];
    
    [self makeGETRequest:getString BaseURLStr:DIFFBOT_API_BASEURL Params:nil Callback:callback];
}

#pragma mark - Batch Request Functions
+ (void)batchRequests:(NSArray *)requestArray withCallback:(DiffbotAPIRequestCallback)callback{
    NSAssert([requestArray count] <= 50, @"Batch requests limited to 50.");
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://www.diffbot.com/api/batch"]];
    [request addPostValue:DIFFBOT_API_TOKEN forKey:@"token"];
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:requestArray options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    
    [request addPostValue:jsonString forKey:@"batch"];
    [request setShouldAttemptPersistentConnection:YES];
    
    [request setCompletionBlock:^{
        // Parse the response string as JSON
        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        
        for(NSDictionary *item in jsonObject) {
            id jsonData = [[item objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding];
            id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            [returnArray addObject:obj];
        }
        
        if(callback) callback(YES, returnArray);
    }];
    
    [request setFailedBlock:^{
        if(callback) callback(NO, request.error);
        NSLog(@"%@", request.error);
    }];
    
    [request startAsynchronous];
}

+ (NSDictionary *)dictForBatchRequest:(DiffbotAPIRequestType)rType UrlString:(NSString *)urlStr Method:(NSString *)method OptionalArgs:(NSDictionary *)optArgs Format:(DiffbotAPIFormatType)formatType {
    NSString *apiRequest = [self apiRequestStringFromType:rType];
    NSString *format = (formatType == DiffbotAPIFormatJSON) ? @"json" : @"xml";
    NSString *paramStr = [self parametersAsString:optArgs];
    
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                NULL,
                                                (__bridge CFStringRef) urlStr,
                                                NULL,
                                                CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                kCFStringEncodingUTF8));
    
    NSString *relative_url = [NSString stringWithFormat:@"/api/%@?token=%@%%26url=%@%%26format=%@%@", apiRequest, DIFFBOT_API_TOKEN, escapedString, format, paramStr];
    
    relative_url = [NSString stringWithFormat:@"/api/%@?token=%@&url=%@&format=%@%@", apiRequest, DIFFBOT_API_TOKEN, escapedString, format, paramStr];
    
    return @{
             @"method": method,
             @"relative_url": relative_url
             };
}


#pragma mark - Helper Functions

+ (NSString *)apiRequestStringFromType:(DiffbotAPIRequestType)rType {
    switch (rType) {
        case DiffbotArticleRequest:
            return @"article";
        case DiffbotBatchRequest:
            return @"batch";
        case DiffbotBulkRequest:
            return @"bulk";
        case DiffbotCrawlBotRequest:
            return @"crawl";
        case DiffbotFrontpageRequest:
            return @"frontpage";
        case DiffbotImageRequest:
            return @"image";
        case DiffbotPageClassifierRequest:
        case DiffbotAnalyzeRequest:
            return @"analyze";
        case DiffbotProductRequest:
            return @"product";
            
        default:
            return nil;
            break;
    }
}

+ (NSString *)parametersAsString:(NSDictionary *)params {
    NSString *paramStr = @"";
    if([params count] > 0) {
        for (NSString *key in params) {
            id value = [params objectForKey:key];
            NSString *argStr = [NSString stringWithFormat:@"&%@=%@", key, value];
            paramStr = [paramStr stringByAppendingString:argStr];
        }
    }
    
    return paramStr;
}

+ (void)makeGETRequest:(NSString *)requestString BaseURLStr:(NSString *)baseURLStr Params:(NSDictionary *)params Callback:(DiffbotAPIRequestCallback)callback {
    NSString *paramStr = [self parametersAsString:params];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@", DIFFBOT_API_BASEURL, requestString, paramStr]];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        if(callback) {
            NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:nil];
            callback(YES, jsonObject);
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"%@", error);
    }];
    
    [request startAsynchronous];
}

@end

//
//  DiffbotAPIClient.h
//  DiffbotAPI
//
//  Created by Dan on 1/7/14.
//  Copyright (c) 2014 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>

// If successful, returns YES, JSON responseObject. Else returns NO, NSError *error
typedef void (^DiffbotAPIRequestCallback)(BOOL success, id result);

typedef enum {
    DiffbotAPIFormatXML,
    DiffbotAPIFormatJSON
} DiffbotAPIFormatType;

typedef enum {
    DiffbotArticleRequest,
    DiffbotAnalyzeRequest,
    DiffbotFrontpageRequest,
    DiffbotImageRequest,
    DiffbotProductRequest,
    DiffbotPageClassifierRequest,
    DiffbotBulkRequest,
    DiffbotCrawlBotRequest,
    DiffbotBatchRequest,
} DiffbotAPIRequestType;

typedef enum {
    DiffbotAPIRetrieveCrawlJSON,
    DiffbotAPIRetrieveCrawlCSV
} DiffbotAPIRetrieveCrawlDataType;


@interface DiffbotAPIClient : NSObject

// General API Request Function
+ (void)apiRequest:(DiffbotAPIRequestType)rType UrlString:(NSString *)urlStr OptionalArgs:(NSDictionary *)optArgs Format:(DiffbotAPIFormatType)formatType withCallback:(DiffbotAPIRequestCallback)callback;
+ (void)customRequest:(NSString *)apiRequest UrlString:(NSString *)urlStr OptionalArgs:(NSDictionary *)optArgs Format:(DiffbotAPIFormatType)formatType withCallback:(DiffbotAPIRequestCallback)callback;

// Crawl API Functions
+ (void)crawlRequest:(NSString *)jobName UrlSeeds:(NSArray *)seeds ApiUrl:(NSString *)apiUrl OptionalArgs:(NSDictionary *)optArgs withCallback:(DiffbotAPIRequestCallback)callback;
+ (void)retrieveCrawlDetails:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback;
+ (void)pauseCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback;
+ (void)unpauseCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback;
+ (void)restartCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback;
+ (void)deleteCrawlRequest:(NSString *)jobName withCallback:(DiffbotAPIRequestCallback)callback;
+ (void)retrieveCrawlDataForJob:(NSString *)jobName DataType:(DiffbotAPIRetrieveCrawlDataType)dataType withCallback:(DiffbotAPIRequestCallback)callback;

// Batch API Functions

// Expects an NSArray containing NSDictionary objects returned from the
// stringForBatchRequest... method
+ (void)batchRequests:(NSArray *)requestArray withCallback:(DiffbotAPIRequestCallback)callback;

+ (NSDictionary *)dictForBatchRequest:(DiffbotAPIRequestType)rType UrlString:(NSString *)urlStr Method:(NSString *)method OptionalArgs:(NSDictionary *)optArgs Format:(DiffbotAPIFormatType)formatType;


@end

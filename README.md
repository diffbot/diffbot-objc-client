# Diffbot Objective-C API Client

## Installation

Add the DiffbotAPIClient folder to your project.

In Project Settings -> Build Phases -> Link Binary With Libraries, add libz.dylib

If your project is running ARC, you will need to add the "-fno-objc-arc" compiler flag to all "ASI*" files and Reachability.m. Do this in Project Settings -> Build Phases -> Compile Sources 


## General Use

Make general calls to the Diffbot API using this method:
```
+ (void)apiRequest:(DiffbotAPIRequestType)rType 
     UrlString:(NSString *)urlStr 
     OptionalArgs:(NSDictionary *)optArgs 
     Format:(DiffbotAPIFormatType)formatType 
     withCallback:(DiffbotAPIRequestCallback)callback;
```

## Configuration

You will need to set the developer token in DiffbotAPIClient.m

```objective-c
#define DIFFBOT_API_TOKEN @"sampletoken"
```

To add optional arguments to any api call, pass in an NSDictionary with the optional arguments.

## Example: Analyze API Call

```
    NSString *articleURL = @"http://www.macrumors.com/2014/01/12/your-verse-ipad-ad";
    NSDictionary *optionalArgs = @{
                                   @"author": @"fields"
                                   };
    
    [DiffbotAPIClient apiRequest:DiffbotPageClassifierRequest UrlString:articleURL OptionalArgs:optionalArgs Format:DiffbotAPIFormatJSON withCallback:^(BOOL success, id result) {
        if(success) {
            NSLog(@"Call success: %@", result);
        } else {
            NSLog(@"Error: %@", result);
        }
    }];


```

## Example: Article API Call

```
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
```

## Example: Batch request

```
    NSString *firstArticleURL = @"http://www.macrumors.com/2014/01/12/your-verse-ipad-ad";
    NSString *secondArticleURL = @"http://www.huffingtonpost.com/2014/01/24/stephen-hawking-black-holes-event-horizons_n_4658220.html";
    
    NSDictionary *dictOne = [DiffbotAPIClient dictForBatchRequest:DiffbotArticleRequest UrlString:firstArticleURL Method:@"GET" OptionalArgs:nil Format:DiffbotAPIFormatJSON];

    NSDictionary *dictTwo = [DiffbotAPIClient dictForBatchRequest:DiffbotArticleRequest UrlString:secondArticleURL Method:@"GET" OptionalArgs:nil Format:DiffbotAPIFormatJSON];
    
    [DiffbotAPIClient batchRequests:@[dictOne, dictTwo] withCallback:^(BOOL success, id result) {
        NSLog(@"%@", result);
    }];
```

-Initial commit by Dan Ha-

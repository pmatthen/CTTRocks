//
//  Rock.m
//  CTTRocks
//
//  Created by Josef Hilbert on 11.02.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "Rock.h"
#import "CHCSVParser.h"

static NSMutableArray *rocks;
static NSMutableArray *rocksFiltered;
static NSString *lastUsedFilter;
static NSArray *assestPaths;

@interface Rock ()

@end

@implementation Rock

+ (void)loadImages
{
    for (int i = 0; i < assestPaths.count; i++)
    {
        NSString *searchStr= @"CTTRocks.app/";
        NSRange range = [assestPaths[i] rangeOfString:searchStr];
        
        NSString *rockNumber = [[assestPaths[i] substringFromIndex:range.location +14] substringToIndex:3];
        NSString *kindOfImage = [[assestPaths[i] substringFromIndex:range.location +13] substringToIndex:1];
        
        NSInteger indexOfImage = [rockNumber integerValue] - 1;
        if (indexOfImage >= 0 && [kindOfImage isEqualToString:@"R"])
        {
            ((Rock*)rocks[indexOfImage]).image = [[UIImage alloc] initWithContentsOfFile:assestPaths[i]];
        }
        if (indexOfImage >= 0 && [kindOfImage isEqualToString:@"B"])
        {
            ((Rock*)rocks[indexOfImage]).imageOfBuilding = [[UIImage alloc] initWithContentsOfFile:assestPaths[i]];
        }
        if (indexOfImage >= 0 && [kindOfImage isEqualToString:@"S"])
        {
            ((Rock*)rocks[indexOfImage]).imageThumbnail = [[UIImage alloc] initWithContentsOfFile:assestPaths[i]];
        }
    }
}


+ (void)loadTexts
{
    for (int i = 0; i < assestPaths.count; i++)
    {
        NSString *searchStr= @"CTTRocks.app/";
        NSRange range = [assestPaths[i] rangeOfString:searchStr];
        NSString *rockNumber = [[assestPaths[i] substringFromIndex:range.location +17] substringToIndex:3];
        NSInteger indexOfImage = [rockNumber integerValue] - 1;
        if (indexOfImage >= 0)
        {
            ((Rock*)rocks[indexOfImage]).text = [[NSAttributedString alloc]   initWithFileURL:[[NSURL alloc]initFileURLWithPath:assestPaths[i]] options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} documentAttributes:nil error:nil];
        }
    }
}

+(NSMutableArray*)rocks
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        rocks = [NSMutableArray new];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CTT New Inventory" ofType:@"csv"];
        NSError *error = nil;
        NSArray *rocksCSV = [NSArray arrayWithContentsOfCSVFile:path options:CHCSVParserOptionsSanitizesFields delimiter:';'];
        if (rocksCSV == nil) {
            //something went wrong; log the error and exit
            NSLog(@"error parsing file: %@", error);
            return;
        }
        
        for (int i = 1; i < rocksCSV.count; i++)
        {
            Rock *rock = [Rock new];
            rock.title = rocksCSV[i][1];
            rock.country = rocksCSV[i][2];
            rock.state = rocksCSV[i][3];
            rock.location = rocksCSV[i][4];
            NSString *positionOnFacadeString = rocksCSV[i][5];
            rock.positionOnFacade = [positionOnFacadeString intValue];
//            positionOnFacadeString.integerValue;
            
            [rocks addObject:rock];
        }
        assestPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:nil];
        [self loadImages];
        assestPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
        [self loadImages];
        assestPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"rtf" inDirectory:nil];
        [self loadTexts];
    });
    
    return rocks;
    
}

+(NSMutableArray*)rocksFiltered:(NSString*)filterString
{
    if ([lastUsedFilter isEqualToString:filterString])
        return rocksFiltered;
    
    rocksFiltered = [NSMutableArray new];
    for (Rock *rock in [Rock rocks])
    {
        if ([rock.title rangeOfString:filterString].location != NSNotFound)
        {
            [rocksFiltered addObject:rock];
        }
        else
        {
            if ([rock.country rangeOfString:filterString].location != NSNotFound)
            {
                [rocksFiltered addObject:rock];
            }
            else
            {
                if ((rock.state) && [rock.state rangeOfString:filterString].location != NSNotFound)
                {
                    [rocksFiltered addObject:rock];
                }
                else
                {
                    if ([rock.location rangeOfString:filterString].location != NSNotFound)
                    {
                        [rocksFiltered addObject:rock];
                    }
                }
            }
        }
    }
    return rocksFiltered;
    
}
@end

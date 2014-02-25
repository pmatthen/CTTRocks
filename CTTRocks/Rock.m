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

#define IS_PHONEPOD5() ([UIScreen mainScreen].bounds.size.height == 568.0f && [UIScreen mainScreen].scale == 2.f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)


@interface Rock ()

@end

@implementation Rock

+(Rock*)rockAtNumber:(NSInteger)number
{
    
    for (Rock *rock in rocks)
    {
        if (rock.number == number)
        {
            return rock;
        }
    }
    return nil;
}

+ (void)loadImages
{
    for (int i = 0; i < assestPaths.count; i++)
    {
        NSString *searchStr= @"CTTRocks.app/";
        NSString *accessPath = assestPaths[i];
        
        if (!([[[accessPath substringFromIndex:accessPath.length - 7] substringToIndex:1] isEqualToString:@"@"]))
        {
            
            NSRange range = [assestPaths[i] rangeOfString:searchStr];            
            NSInteger rockNumber = [[[assestPaths[i] substringFromIndex:range.location +14] substringToIndex:3] integerValue];
            NSString *kindOfImage = [[assestPaths[i] substringFromIndex:range.location +13] substringToIndex:1];
            
            if (rockNumber > 0 && [kindOfImage isEqualToString:@"R"])
            {
                if(IS_PHONEPOD5())
                {
                    accessPath = [accessPath stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@".jpg"]
                                                                       withString: [NSString stringWithFormat:@"-568h@2x.jpg"] ];
                }
                [self rockAtNumber:rockNumber].image = [[UIImage alloc] initWithContentsOfFile:accessPath];
                
            }
            if (rockNumber >  0 && [kindOfImage isEqualToString:@"B"])
            {
                [self rockAtNumber:rockNumber].imageOfBuilding = [[UIImage alloc] initWithContentsOfFile:accessPath];
            }
            if (rockNumber > 0 && [kindOfImage isEqualToString:@"S"])
            {
                [self rockAtNumber:rockNumber].imageThumbnail = [[UIImage alloc] initWithContentsOfFile:accessPath];
            }
        }
    }
}


+ (void)loadTexts
{
    for (int i = 0; i < assestPaths.count; i++)
    {
        NSString *searchStr= @"CTTRocks.app/";
        NSRange range = [assestPaths[i] rangeOfString:searchStr];
        
        NSInteger rockNumber = [[[assestPaths[i] substringFromIndex:range.location +17] substringToIndex:3] integerValue];
        
        if (rockNumber > 0)
        {
            [self rockAtNumber:rockNumber].text = [[NSAttributedString alloc]   initWithFileURL:[[NSURL alloc]initFileURLWithPath:assestPaths[i]] options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} documentAttributes:nil error:nil];
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
            rock.number = [rocksCSV[i][0] integerValue];
            rock.title = rocksCSV[i][1];
            rock.country = rocksCSV[i][2];
            rock.state = rocksCSV[i][3];
            rock.location = rocksCSV[i][4];
            NSString *positionOnFacadeString = rocksCSV[i][5];
            rock.positionOnFacade = [positionOnFacadeString intValue];
            
            [rocks addObject:rock];
        }
        
        rocks  = [rocks sortedArrayUsingComparator:^NSComparisonResult(Rock *rock1, Rock *rock2) {
            NSInteger location1 = rock1.positionOnFacade;
            NSInteger location2 = rock2.positionOnFacade;
            
            if (location1 > location2) {
                return NSOrderedDescending;
            }
            if (location1 < location2) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }].mutableCopy;

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
        if ([rock.title rangeOfString:filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [rocksFiltered addObject:rock];
        }
        else
        {
            if ([rock.country rangeOfString:filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [rocksFiltered addObject:rock];
            }
            else
            {
                if ((rock.state) && [rock.state rangeOfString:filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    [rocksFiltered addObject:rock];
                }
                else
                {
                    if ([rock.location rangeOfString:filterString options:NSCaseInsensitiveSearch].location != NSNotFound)
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

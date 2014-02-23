//
//  Rock.h
//  CTTRocks
//
//  Created by Josef Hilbert on 11.02.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rock : NSObject

@property (nonatomic)         NSInteger number;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic)         NSInteger positionOnFacade;
@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *imageThumbnail;
@property (nonatomic, strong) UIImage *imageOfBuilding;


+(NSArray*)rocks;
+(NSArray*)rocksFiltered:(NSString*)filterString;

@end

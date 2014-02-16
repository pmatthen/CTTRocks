//
//  CTTCollectionViewCell.h
//  CTT
//
//  Created by Josef Hilbert on 26.01.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTTCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewRockThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCountry;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber;

@end
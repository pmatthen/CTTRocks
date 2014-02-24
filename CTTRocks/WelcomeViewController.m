//
//  WelcomeViewController.m
//  CTTRocks
//
//  Created by Stephen Compton on 2/19/14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

{
    
    __weak IBOutlet UIImageView *welcomePageImageView;
    __weak IBOutlet UILabel *dateLabel;
}

@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage * welcomeImage = [UIImage imageNamed: @"tutorial6.png"];
    welcomePageImageView.image = welcomeImage;
    
    NSDate* currentDate = [NSDate date];
    NSTimeZone* currentTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"CST"];
    NSTimeZone* nowTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:currentDate];
    NSInteger nowGMTOffset = [nowTimeZone secondsFromGMTForDate:currentDate];
    
    NSTimeInterval interval = nowGMTOffset - currentGMTOffset;
    NSDate* nowDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Central"]];
    
    dateLabel.text =[formatter stringFromDate:nowDate];
    
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


@end

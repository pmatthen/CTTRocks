//
//  AcknowledgementsViewController.m
//  CTTRocks
//
//  Created by Stephen Compton on 2/23/14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "AcknowledgementsViewController.h"

@interface AcknowledgementsViewController ()

{
    
    __weak IBOutlet UIImageView *creditsImageView;
}

@end

@implementation AcknowledgementsViewController

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
    
    UIImage * creditsImage = [UIImage imageNamed: @"TribNightView.jpeg"];
    creditsImageView.image = creditsImage;
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.070 green:0.350 blue:0.60 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    self.title = @"Credits";}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    self.navigationController.navigationBar.tag = 1;

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end

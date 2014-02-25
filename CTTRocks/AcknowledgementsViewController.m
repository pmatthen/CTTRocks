//
//  AcknowledgementsViewController.m
//  CTTRocks
//
//  Created by Stephen Compton on 2/23/14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "AcknowledgementsViewController.h"

@interface AcknowledgementsViewController ()

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
	// Do any additional setup after loading the view.
}

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

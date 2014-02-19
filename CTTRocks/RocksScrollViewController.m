//
//  ViewController.m
//  CTTRocks
//
//  Created by Josef Hilbert on 11.02.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "RocksScrollViewController.h"
#import "MainCollectionViewController.h"
#import "ILTranslucentView.h"
#import "Rock.h"
#import <QuartzCore/QuartzCore.h>

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface RocksScrollViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, UITabBarDelegate>
{
    __weak IBOutlet UIScrollView *myScrollView;
    __weak IBOutlet UIScrollView *myPanoramicScrollview;
    
    NSArray *imagePaths;
    float startingX;
    int currentPage;
    int previousPage;
    BOOL isOverlayOn;
    UIImageView *imageView;
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
}

@end

@implementation RocksScrollViewController
@synthesize rockArray;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.selectedRock) {
        self.selectedRock = 0;
        previousPage = 0;
    } else {
        previousPage = self.selectedRock;
    }

    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x067AB5)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    self.title = @"Tribune Rocks";
    
    //Programmatically add share buttons
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didTapAction)];
    NSArray *actionButtonItems = @[shareItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    UIImage *image;
    image = [UIImage imageNamed:@"Estrella.jpeg"];
    imageView = [[UIImageView alloc] initWithImage:image];
    [myPanoramicScrollview addSubview:imageView];
    myPanoramicScrollview.contentSize = imageView.frame.size;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    myPanoramicScrollview.delegate = self;
    myPanoramicScrollview.hidden = YES;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    currentPage = (myScrollView.contentOffset.x + (0.5f * myScrollView.frame.size.width))/myScrollView.frame.size.width;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (!rockArray) {
        rockArray = [Rock rocks];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.enabled = YES;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [myScrollView addGestureRecognizer:tapGestureRecognizer];
    isOverlayOn = NO;
    startingX = (int)self.selectedRock * (int)self.view.frame.size.width;
    CGFloat width = self.view.frame.size.width * rockArray.count;
    [self photoLayout:self.selectedRock];
    
    myScrollView.contentSize = CGSizeMake(width, myScrollView.frame.size.height);
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [myScrollView setContentOffset:CGPointMake(startingX, self.view.frame.size.height)];

    [self setupGestureRecognizerAbsentNavbar];
    [self setupNavbarGestureRecognizer];
}


//Add share functionality
- (void)didTapAction {
    NSString *shareString = @"Tribune Tower, Chicago";
    UIImage *shareImage = ((Rock*)rockArray[self.selectedRock]).image;
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareImage, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [aScrollView setContentOffset:CGPointMake(aScrollView.contentOffset.x, 0.0)];

    currentPage = (myScrollView.contentOffset.x + (0.5f * myScrollView.frame.size.width))/myScrollView.frame.size.width;
    if (currentPage != previousPage) {
        if (currentPage > previousPage) {
            NSLog(@"reached page #%i by increasing", currentPage);
            [self swipePhoto:(currentPage - 4) andAdd:(currentPage + 3)];
        }
        if (currentPage < previousPage) {
            NSLog(@"reached page #%i by decreasing", currentPage);
            [self swipePhoto:(currentPage + 4) andAdd:(currentPage - 3)];
        }
        previousPage = currentPage;
    }
}

-(void)photoLayout:(int)photoPage
{
    for (int n = 3; n > 0; n--) {
        if ((photoPage - n) >= 0) {
            [self drawPhotos:(photoPage - n)];
        }
    }
    if (rockArray[photoPage]) {
        [self drawPhotos:photoPage];
    }
    
    for (int n = 1; n < 4; n++) {
        if ( ((photoPage + n) < rockArray.count) ) {
            [self drawPhotos:(photoPage + n)];
        }
    }
}

-(void)drawPhotos:(int)sub
{
    Rock *rock;
    
    NSLog(@"adding rock and overlay at position %i", sub);
    rock = rockArray[sub];
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:rock.image];
    myImageView.contentMode = UIViewContentModeScaleToFill;
    myImageView.frame = CGRectMake((self.view.frame.size.width * sub), 0, self.view.frame.size.width, myScrollView.frame.size.height);
    myImageView.tag = sub + 1;
    
    UIView* detailOverlay;
    detailOverlay = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width * sub), 0, self.view.frame.size.width, self.view.frame.size.height)];
    [detailOverlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.1]];
    detailOverlay.tag = sub + 1000;
    detailOverlay.hidden = !isOverlayOn;
    [myScrollView addSubview:detailOverlay];
    
    UIImageView *historicalImage = [[UIImageView alloc] initWithFrame:CGRectMake(35, 35, 250, 175)];
    [historicalImage setImage:rock.imageOfBuilding];
    historicalImage.contentMode = UIViewContentModeScaleToFill;
    
    UITextView *textView;
    
    if (rock.text)
    {
        NSAttributedString *textString =  [[NSAttributedString alloc] initWithAttributedString:rock.text];
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textString];
        NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
        // Add layout manager to text storage object
        [textStorage addLayoutManager:textLayout];
        // Create a text container
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
        // Add text container to text layout manager
        [textLayout addTextContainer:textContainer];
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(35, 220, 250, self.view.frame.size.height -254) textContainer:textContainer];
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
        textView.selectable = NO;
        textView.alpha = 1;
        textView.textColor = [UIColor blackColor];
        textView.directionalLockEnabled = YES;
        [textView sizeToFit];
        if (textView.frame.size.height > 250)
        {
            textView.frame = CGRectMake(35, 220, textView.frame.size.width, self.view.frame.size.height -254);
        }
    }
    else
    {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(35, 220, 250, self.view.frame.size.height -254)];
    }
    
    UIView *myTranslucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(20, 20, 280, self.view.frame.size.height -40)];
    myTranslucentView.backgroundColor = [UIColor clearColor];
    myTranslucentView.layer.cornerRadius = 10.0;
    myTranslucentView.layer.masksToBounds = YES;
    
    [detailOverlay addSubview:myTranslucentView];
    [detailOverlay addSubview:historicalImage];
    [detailOverlay addSubview:textView];
    [myScrollView addSubview:myImageView];
    [myScrollView addSubview:detailOverlay];
}

-(void)swipePhoto:(int)subViewToDelete andAdd:(int)subViewToAdd
{
    for (UIImageView *myImageView in myScrollView.subviews) {
        if ((myImageView.tag == subViewToDelete + 1) && (myImageView.tag != 0)) {
            NSLog(@"deleting rock at position %i", (myImageView.tag - 1));
            [myImageView removeFromSuperview];
        }
    }
    
    for (UIView *myDetailOverlay in myScrollView.subviews) {
        if (myDetailOverlay.tag == (subViewToDelete + 1000)) {
            NSLog(@"deleting detailview at position %i", (myDetailOverlay.tag - 1000));
            [myDetailOverlay removeFromSuperview];
        }
    }
    
    if (subViewToAdd < rockArray.count) {
        [self drawPhotos:subViewToAdd];
    }
}

-(void)tapPhoto
{
    isOverlayOn = !(isOverlayOn);
    if (isOverlayOn) {
        for (UIView *myDetailOverlay in myScrollView.subviews) {
            if (myDetailOverlay.tag >= 1000) {
                myDetailOverlay.hidden = NO;
            }
        }
        NSLog(@"tapped");
    } else {
        for (UIView *myDetailOverlay in myScrollView.subviews) {
            if (myDetailOverlay.tag >= 1000) {
                myDetailOverlay.hidden = YES;
            }
        }
        NSLog(@"tapped again");
    }
}

- (BOOL)prefersStatusBarHidden
{
        return YES;
}

-(void)showHideNavbar
{
    //Hide/unhide navigation controller
    if (![self.navigationController isNavigationBarHidden])
        [self.navigationController setNavigationBarHidden:YES animated:YES]; // hides
    else
        [self.navigationController setNavigationBarHidden:NO animated:YES]; // shows
}


- (void) setupGestureRecognizerAbsentNavbar {
    // recognise taps on navigation bar to hide
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar)];
    gestureRecognizer.numberOfTapsRequired = 1;
    // create a view which covers most of the tap bar to
    // manage the gestures - if we use the navigation bar
    // it interferes with the nav buttons
    CGRect frame = CGRectMake(self.view.frame.size.width/4, 0, self.view.frame.size.width/2, 44);
    UIView *navBarTapView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:navBarTapView];
    navBarTapView.backgroundColor = [UIColor clearColor];
    [navBarTapView setUserInteractionEnabled:YES];
    [navBarTapView addGestureRecognizer:gestureRecognizer];
}

- (void) setupNavbarGestureRecognizer {
    // recognise taps on navigation bar to hide
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar)];
    gestureRecognizer.numberOfTapsRequired = 1;
    // create a view which covers most of the tap bar to
    // manage the gestures - if we use the navigation bar
    // it interferes with the nav buttons
    CGRect frame = CGRectMake(self.view.frame.size.width/4, 0, self.view.frame.size.width/2, 44);
    UIView *navBarTapView = [[UIView alloc] initWithFrame:frame];
    [self.navigationController.navigationBar addSubview:navBarTapView];
    navBarTapView.backgroundColor = [UIColor clearColor];
    [navBarTapView setUserInteractionEnabled:YES];
    [navBarTapView addGestureRecognizer:gestureRecognizer];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if ([touch.view isKindOfClass:[UIButton class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

-(void) detectOrientation {
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        myScrollView.hidden = YES;
        myPanoramicScrollview.hidden = NO;
        imageView.contentMode = UIViewContentModeScaleToFill;
        myScrollView.contentSize = imageView.frame.size;
        
        button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        button1.frame = CGRectMake(90, 270, 44, 44);
        button2.frame = CGRectMake(203, 270, 44, 44);
        button3.frame = CGRectMake(316, 270, 44, 44);
        button4.frame = CGRectMake(429, 270, 44, 44);
        
        [button1 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button2 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button3 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button4 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        
        [button1 setTitle:@"1" forState:UIControlStateNormal];
        [button2 setTitle:@"2" forState:UIControlStateNormal];
        [button3 setTitle:@"3" forState:UIControlStateNormal];
        [button4 setTitle:@"4" forState:UIControlStateNormal];
        
        button1.tag = 1;
        button2.tag = 2;
        button3.tag = 3;
        button4.tag = 4;
        
        [button1 setBackgroundColor:[UIColor grayColor]];
        [button2 setBackgroundColor:[UIColor grayColor]];
        [button3 setBackgroundColor:[UIColor grayColor]];
        [button4 setBackgroundColor:[UIColor grayColor]];
        
        [self.view addSubview:button1];
        [self.view addSubview:button2];
        [self.view addSubview:button3];
        [self.view addSubview:button4];
        
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [button1 removeFromSuperview];
        [button2 removeFromSuperview];
        [button3 removeFromSuperview];
        [button4 removeFromSuperview];
        
        myPanoramicScrollview.hidden = YES;
        myScrollView.hidden = NO;
        NSLog(@"Portrait Mode = (%f, %f) ", self.view.frame.size.width, self.view.frame.size.height);
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        [button1 removeFromSuperview];
        [button2 removeFromSuperview];
        [button3 removeFromSuperview];
        [button4 removeFromSuperview];
    }
}

-(void)onButtonPressed:(UIButton *)button
{
    switch (button.tag) {
        case 1:
            myPanoramicScrollview.contentOffset = CGPointMake(1240, self.view.frame.size.width/2);
            break;
        case 2:
            myPanoramicScrollview.contentOffset = CGPointMake(5190, 50);
            break;
        case 3:
            myPanoramicScrollview.contentOffset = CGPointMake(7490, 50);
            break;
        case 4:
            myPanoramicScrollview.contentOffset = CGPointMake(11980, 50);
            break;
        default:
            break;
    }
}

-(IBAction)unwindSegue:(UIStoryboardSegue *)sender
{
    //
}


@end

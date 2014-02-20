//
//  ViewController.m
//  CTTRocks
//
//  Created by Josef Hilbert on 11.02.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "RocksScrollViewController.h"
#import "MainCollectionViewController.h"
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
    UIButton *button5;
    UIButton *button6;
    UIView *topDownMapOverlay;
    UIImageView *topDownMapView;
    UIImageView *buttonIndicator1;
    UIImageView *buttonIndicator2;
    UIImageView *buttonIndicator3;
    UIImageView *buttonIndicator4;
    UIImageView *buttonIndicator5;
    UIImageView *buttonIndicator6;
    UIImageView *buttonIndication1;
    UIImageView *buttonIndication2;
    UIImageView *buttonIndication3;
    UIImageView *buttonIndication4;
    UIImageView *buttonIndication5;
    UIImageView *buttonIndication6;
    UILabel *michiganLabel;
}

@end

@implementation RocksScrollViewController
@synthesize rockArray;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.070 green:0.350 blue:0.60 alpha:1] /*#084283*/];
  

    if (!self.selectedRock) {
        self.selectedRock = 0;
        previousPage = 0;
    } else {
        previousPage = self.selectedRock;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.enabled = YES;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [myScrollView addGestureRecognizer:tapGestureRecognizer];
    
    [self setupGestureRecognizerAbsentNavbar];
    [self setupNavbarGestureRecognizer];
    
    UIImage *image;
 //   image = [UIImage imageNamed:@"Estrella.jpg"];
    image = [UIImage imageNamed:@"CTTPanorama.jpg"];
//
    imageView = [[UIImageView alloc] initWithImage:image];
    [myPanoramicScrollview addSubview:imageView];
    myPanoramicScrollview.contentSize = imageView.frame.size;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    myPanoramicScrollview.delegate = self;
    myPanoramicScrollview.tag = 4;
    myPanoramicScrollview.hidden = YES;
    
    myScrollView.tag = 5;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    currentPage = (myScrollView.contentOffset.x + (0.5f * myScrollView.frame.size.width))/myScrollView.frame.size.width;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (!rockArray) {
        rockArray = [Rock rocks];
    }
    
    isOverlayOn = NO;
    startingX = (int)self.selectedRock * (int)self.view.frame.size.width;
    CGFloat width = self.view.frame.size.width * rockArray.count;
    [self photoLayout:self.selectedRock];
    myScrollView.contentSize = CGSizeMake(width, myScrollView.frame.size.height);

    [myScrollView setContentOffset:CGPointMake(startingX, self.view.frame.size.height)];
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

    if (aScrollView.tag == 4) {
        [self checkMyPanoramicScrollViewContentOffset];
    }
}

-(void)checkMyPanoramicScrollViewContentOffset
{
    if (myPanoramicScrollview.contentOffset.x <= 1240) {
        buttonIndicator1.hidden = YES;
        buttonIndication1.hidden = NO;
    } else {
        buttonIndicator1.hidden = NO;
        buttonIndication1.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 1240) && (myPanoramicScrollview.contentOffset.x <= 5190)) {
        buttonIndicator2.hidden = YES;
        buttonIndication2.hidden = NO;
    } else {
        buttonIndicator2.hidden = NO;
        buttonIndication2.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 5190) && (myPanoramicScrollview.contentOffset.x <= 7490)) {
        buttonIndicator3.hidden = YES;
        buttonIndication3.hidden = NO;
    } else {
        buttonIndicator3.hidden = NO;
        buttonIndication3.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 7490) && (myPanoramicScrollview.contentOffset.x <= 9000)) {
        buttonIndicator4.hidden = YES;
        buttonIndication4.hidden = NO;
    } else {
        buttonIndicator4.hidden = NO;
        buttonIndication4.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 9000) && (myPanoramicScrollview.contentOffset.x < 11980)) {
        buttonIndicator5.hidden = YES;
        buttonIndication5.hidden = NO;
    } else {
        buttonIndicator5.hidden = NO;
        buttonIndication5.hidden = YES;
    }
    if (myPanoramicScrollview.contentOffset.x >= 11980) {
        buttonIndicator6.hidden = YES;
        buttonIndication6.hidden = NO;
    } else {
        buttonIndicator6.hidden = NO;
        buttonIndication6.hidden = YES;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 5) {
        scrollView.userInteractionEnabled = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 5) {
        currentPage = (myScrollView.contentOffset.x + (0.5f * myScrollView.frame.size.width))/myScrollView.frame.size.width;
        if (currentPage != previousPage) {
            if (currentPage > previousPage) {
                [self swipePhoto:(currentPage - 4) andAdd:(currentPage + 3)];
            }
            if (currentPage < previousPage) {
                [self swipePhoto:(currentPage + 4) andAdd:(currentPage - 3)];
            }
            previousPage = currentPage;
        }
        scrollView.userInteractionEnabled = YES;
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
    
    UIView *myTranslucentView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, self.view.frame.size.height -40)];
    myTranslucentView.backgroundColor = [UIColor whiteColor];
    myTranslucentView.alpha = 0.8;
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
            [myImageView removeFromSuperview];
        }
    }
    
    for (UIView *myDetailOverlay in myScrollView.subviews) {
        if (myDetailOverlay.tag == (subViewToDelete + 1000)) {
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
    } else {
        for (UIView *myDetailOverlay in myScrollView.subviews) {
            if (myDetailOverlay.tag >= 1000) {
                myDetailOverlay.hidden = YES;
            }
        }
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
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
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
    if ([touch.view isKindOfClass:[UIBarButtonItem class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

-(void) detectOrientation {
    
    [button1 removeFromSuperview];
    [button2 removeFromSuperview];
    [button3 removeFromSuperview];
    [button4 removeFromSuperview];
    [button5 removeFromSuperview];
    [button6 removeFromSuperview];
    [topDownMapOverlay removeFromSuperview];
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        myScrollView.hidden = YES;
        myPanoramicScrollview.hidden = NO;
        imageView.contentMode = UIViewContentModeScaleToFill;
        myScrollView.contentSize = imageView.frame.size;
        
        button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        button4 = [UIButton buttonWithType:UIButtonTypeCustom];
        button5 = [UIButton buttonWithType:UIButtonTypeCustom];
        button6 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button1.frame = CGRectMake(((self.view.frame.size.width - 180)/7 * 1) + (0 * 30), 270, 30, 30);
        button2.frame = CGRectMake(((self.view.frame.size.width - 180)/7 * 2) + (1 * 30), 270, 30, 30);
        button3.frame = CGRectMake(((self.view.frame.size.width - 180)/7 * 3) + (2 * 30), 270, 30, 30);
        button4.frame = CGRectMake(((self.view.frame.size.width - 180)/7 * 4) + (3 * 30), 270, 30, 30);
        button5.frame = CGRectMake(((self.view.frame.size.width - 180)/7 * 5) + (4 * 30), 270, 30, 30);
        button6.frame = CGRectMake(((self.view.frame.size.width - 180)/7 * 6) + (5 * 30), 270, 30, 30);
        
        [button1 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button2 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button3 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button4 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button5 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button6 addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchDown];
        
        [button1 setBackgroundImage:[UIImage imageNamed:@"#1blue.png"] forState:UIControlStateNormal];
        [button2 setBackgroundImage:[UIImage imageNamed:@"#2blue.png"] forState:UIControlStateNormal];
        [button3 setBackgroundImage:[UIImage imageNamed:@"#3blue.png"] forState:UIControlStateNormal];
        [button4 setBackgroundImage:[UIImage imageNamed:@"#4blue.png"] forState:UIControlStateNormal];
        [button5 setBackgroundImage:[UIImage imageNamed:@"#5blue.png"] forState:UIControlStateNormal];
        [button6 setBackgroundImage:[UIImage imageNamed:@"#6blue.png"] forState:UIControlStateNormal];
        
        button1.tag = 1;
        button2.tag = 2;
        button3.tag = 3;
        button4.tag = 4;
        button5.tag = 5;
        button6.tag = 6;
        
        [self.view addSubview:button1];
        [self.view addSubview:button2];
        [self.view addSubview:button3];
        [self.view addSubview:button4];
        [self.view addSubview:button5];
        [self.view addSubview:button6];
        
        topDownMapOverlay = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 158), 0, 158, 150)];
        [topDownMapOverlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.4]];
        [self.view addSubview:topDownMapOverlay];
        
        topDownMapView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11, 118, 100)];
        [topDownMapView setImage:[UIImage imageNamed:@"CTTFrame_2px.png"]];
        topDownMapView.contentMode = UIViewContentModeScaleToFill;
        [topDownMapOverlay addSubview:topDownMapView];

        buttonIndicator1 = [[UIImageView alloc] initWithFrame:CGRectMake(16, 43, 15, 15)];
        [buttonIndicator1 setImage:[UIImage imageNamed:@"#1.png"]];
        buttonIndicator1.contentMode = UIViewContentModeScaleToFill;
        [topDownMapOverlay addSubview:buttonIndicator1];
        
        buttonIndicator2 = [[UIImageView alloc] initWithFrame:CGRectMake(33, 103, 15, 15)];
        [buttonIndicator2 setImage:[UIImage imageNamed:@"#2.png"]];
        buttonIndicator2.contentMode = UIViewContentModeScaleToFill;
        [topDownMapOverlay addSubview:buttonIndicator2];
        
        buttonIndicator3 = [[UIImageView alloc] initWithFrame:CGRectMake(62, 92, 15, 15)];
        [buttonIndicator3 setImage:[UIImage imageNamed:@"#3.png"]];
        buttonIndicator3.contentMode = UIViewContentModeScaleToFill;
        [topDownMapOverlay addSubview:buttonIndicator3];
        
        buttonIndicator4 = [[UIImageView alloc] initWithFrame:CGRectMake(83, 92, 15, 15)];
        [buttonIndicator4 setImage:[UIImage imageNamed:@"#4.png"]];
        buttonIndicator4.contentMode = UIViewContentModeScaleToFill;
        [topDownMapOverlay addSubview:buttonIndicator4];
        
        buttonIndicator5 = [[UIImageView alloc] initWithFrame:CGRectMake(110, 103, 15, 15)];
        [buttonIndicator5 setImage:[UIImage imageNamed:@"#5.png"]];
        buttonIndicator5.contentMode = UIViewContentModeScaleToFill;
        [topDownMapOverlay addSubview:buttonIndicator5];
        
        buttonIndicator6 = [[UIImageView alloc] initWithFrame:CGRectMake(129, 43, 15, 15)];
        [buttonIndicator6 setImage:[UIImage imageNamed:@"#6.png"]];
        buttonIndicator6.contentMode = UIViewContentModeScaleToFill;
        [topDownMapOverlay addSubview:buttonIndicator6];
        
        buttonIndication1 = [[UIImageView alloc] initWithFrame:CGRectMake(16, 43, 15, 15)];
        [buttonIndication1 setImage:[UIImage imageNamed:@"#1blue.png"]];
        buttonIndication1.contentMode = UIViewContentModeScaleToFill;
        buttonIndication1.hidden = YES;
        [topDownMapOverlay addSubview:buttonIndication1];

        buttonIndication2 = [[UIImageView alloc] initWithFrame:CGRectMake(33, 103, 15, 15)];
        [buttonIndication2 setImage:[UIImage imageNamed:@"#2blue.png"]];
        buttonIndication2.contentMode = UIViewContentModeScaleToFill;
        buttonIndication2.hidden = YES;
        [topDownMapOverlay addSubview:buttonIndication2];

        buttonIndication3 = [[UIImageView alloc] initWithFrame:CGRectMake(62, 92, 15, 15)];
        [buttonIndication3 setImage:[UIImage imageNamed:@"#3blue.png"]];
        buttonIndication3.contentMode = UIViewContentModeScaleToFill;
        buttonIndication3.hidden = YES;
        [topDownMapOverlay addSubview:buttonIndication3];

        buttonIndication4 = [[UIImageView alloc] initWithFrame:CGRectMake(83, 92, 15, 15)];
        [buttonIndication4 setImage:[UIImage imageNamed:@"#4blue.png"]];
        buttonIndication4.contentMode = UIViewContentModeScaleToFill;
        buttonIndication4.hidden = YES;
        [topDownMapOverlay addSubview:buttonIndication4];

        buttonIndication5 = [[UIImageView alloc] initWithFrame:CGRectMake(110, 103, 15, 15)];
        [buttonIndication5 setImage:[UIImage imageNamed:@"#5blue.png"]];
        buttonIndication5.contentMode = UIViewContentModeScaleToFill;
        buttonIndication5.hidden = YES;
        [topDownMapOverlay addSubview:buttonIndication5];

        buttonIndication6 = [[UIImageView alloc] initWithFrame:CGRectMake(129, 43, 15, 15)];
        [buttonIndication6 setImage:[UIImage imageNamed:@"#6blue.png"]];
        buttonIndication6.contentMode = UIViewContentModeScaleToFill;
        buttonIndication6.hidden = YES;
        [topDownMapOverlay addSubview:buttonIndication6];
        
        michiganLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 124, 104, 21)];
        michiganLabel.text = @"Michigan Ave";
        michiganLabel.textColor = [UIColor whiteColor];
        [topDownMapOverlay addSubview:michiganLabel];
        
        [self checkMyPanoramicScrollViewContentOffset];
        
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        myPanoramicScrollview.hidden = YES;
        myScrollView.hidden = NO;
    }
}

-(void)onButtonPressed:(UIButton *)button
{
    switch (button.tag) {
        case 1:
            myPanoramicScrollview.contentOffset = CGPointMake(1240, self.view.frame.size.width/2);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 2:
            myPanoramicScrollview.contentOffset = CGPointMake(5190, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 3:
            myPanoramicScrollview.contentOffset = CGPointMake(7490, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 4:
            myPanoramicScrollview.contentOffset = CGPointMake(9000, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 5:
            myPanoramicScrollview.contentOffset = CGPointMake(10000, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 6:
            myPanoramicScrollview.contentOffset = CGPointMake(11980, 50);
            [self checkMyPanoramicScrollViewContentOffset];
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

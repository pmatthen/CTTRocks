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
    int currentOrientation;
    int previousOrientation;
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
    UIImageView *coachMarkImageView;
}

@end

@implementation RocksScrollViewController
@synthesize rockArray;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.070 green:0.350 blue:0.60 alpha:1.0] /*#084283*/];
  

    if (!self.selectedRock) {
        self.selectedRock = 0;
        previousPage = 0;
        [self showHelpOverlay];
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
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc]
                                           initWithTitle:@"?"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                           action:@selector(showHelpOverlay)];
    
    NSArray *actionButtonItems = @[shareItem, infoItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.enabled = YES;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [myScrollView addGestureRecognizer:tapGestureRecognizer];
    
    [self setupGestureRecognizerAbsentNavbar];
    [self setupNavbarGestureRecognizer];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    myScrollView.tag = 5;
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    currentPage = (myScrollView.contentOffset.x + (0.5f * myScrollView.frame.size.width))/myScrollView.frame.size.width;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    
    dispatch_async(queue, ^{
        NSLog(@"Starting GCD");
        UIImage *image;
        image = [UIImage imageNamed:@"CTTPano.jpg"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            imageView = [[UIImageView alloc] initWithImage:image];
            myPanoramicScrollview.contentSize = imageView.frame.size;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            myPanoramicScrollview.delegate = self;
            myPanoramicScrollview.tag = 4;
            myPanoramicScrollview.hidden = YES;
            [myPanoramicScrollview addSubview:imageView];
        });
        NSLog(@"Done with GCD");
    });
    

}

-(void)showHelpOverlay
{
    if(![self.view.subviews containsObject: coachMarkImageView]){
    coachMarkImageView = [[UIImageView alloc] initWithFrame: CGRectMake(startingX, 0, self.view.frame.size.width, self.view.frame.size.height)];
    coachMarkImageView.image = [UIImage imageNamed: @"CoachMarks5.png"];
    [self.view addSubview: coachMarkImageView];
    }
}


-(void)resetScrollView
{
    NSLog(@"resetScrollView");
    for (UIImageView *myImageView in myScrollView.subviews) {
        [myImageView removeFromSuperview];
    }
    for (UIView *myDetailOverlay in myScrollView.subviews) {
        [myDetailOverlay removeFromSuperview];
    }
    [self photoLayout:self.selectedRock];
    startingX = (int)self.selectedRock * (int)self.view.frame.size.width;
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
    if (myPanoramicScrollview.contentOffset.x <= 5840) {
        buttonIndicator1.hidden = YES;
        buttonIndication1.hidden = NO;
    } else {
        buttonIndicator1.hidden = NO;
        buttonIndication1.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 5840) && (myPanoramicScrollview.contentOffset.x <= 7485)) {
        buttonIndicator2.hidden = YES;
        buttonIndication2.hidden = NO;
    } else {
        buttonIndicator2.hidden = NO;
        buttonIndication2.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 7485) && (myPanoramicScrollview.contentOffset.x <= 9690)) {
        buttonIndicator3.hidden = YES;
        buttonIndication3.hidden = NO;
    } else {
        buttonIndicator3.hidden = NO;
        buttonIndication3.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 9690) && (myPanoramicScrollview.contentOffset.x <= 10780)) {
        buttonIndicator4.hidden = YES;
        buttonIndication4.hidden = NO;
    } else {
        buttonIndicator4.hidden = NO;
        buttonIndication4.hidden = YES;
    }
    
    if ((myPanoramicScrollview.contentOffset.x > 10780) && (myPanoramicScrollview.contentOffset.x < 12415)) {
        buttonIndicator5.hidden = YES;
        buttonIndication5.hidden = NO;
    } else {
        buttonIndicator5.hidden = NO;
        buttonIndication5.hidden = YES;
    }
    if (myPanoramicScrollview.contentOffset.x >= 12415) {
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
        NSLog(@"current page = %d", currentPage);
        Rock *rock;
        rock = rockArray[currentPage];
        NSLog(@"position on facade = %i", rock.positionOnFacade);
        NSLog(@"currentpage = %i, previouspage = %d", currentPage, previousPage);
        if (currentPage != previousPage) {
            if (currentPage > previousPage) {
                [self swipePhoto:(currentPage - 2) andAdd:(currentPage + 1)];
            }
            if (currentPage < previousPage) {
                [self swipePhoto:(currentPage + 2) andAdd:(currentPage - 1)];
            }
            previousPage = currentPage;
        }
        scrollView.userInteractionEnabled = YES;
    }
}

-(void)determinePositionOnPanorama
{
    NSLog(@"myscrollview.contentoffset.x = %f", myScrollView.contentOffset.x);
    NSLog(@"previouspage = %d", previousPage);
    Rock *rock = rockArray[previousPage];
    NSLog(@"self.view.frame.size.width/2 = %f", self.view.frame.size.width/2);
    if ((rock.positionOnFacade - self.view.frame.size.width/2) < 0) {
        myPanoramicScrollview.contentOffset = CGPointMake(0, 50);
    } else if ((rock.positionOnFacade - self.view.frame.size.width/2) > (myPanoramicScrollview.contentSize.width - self.view.frame.size.width)) {
        myPanoramicScrollview.contentOffset = CGPointMake(myPanoramicScrollview.contentSize.width - (self.view.frame.size.width), 50);
    }  else {
        myPanoramicScrollview.contentOffset = CGPointMake(rock.positionOnFacade - (self.view.frame.size.width/2), 50);
    }
    [self checkMyPanoramicScrollViewContentOffset];
}

-(void)determinePositionOnScrollView
{
    NSLog(@"%f > %f", (myPanoramicScrollview.contentOffset.x - self.view.frame.size.width/2), (myPanoramicScrollview.contentSize.width - self.view.frame.size.width/2));
    if (myPanoramicScrollview.contentOffset.x < (self.view.frame.size.width/2)) {
        self.selectedRock = 0;
    } else if (myPanoramicScrollview.contentOffset.x > 14400) {
        self.selectedRock = rockArray.count - 1;
    } else {
        Rock *rock;
        rock = rockArray[0];
        if (myPanoramicScrollview.contentOffset.x < rock.positionOnFacade  ) {
            self.selectedRock = 0;
        }
        rock = rockArray[rockArray.count - 1];
        if ((myPanoramicScrollview.contentOffset.x - self.view.frame.size.width) > (rock.positionOnFacade - self.view.frame.size.width/2)) {
            self.selectedRock = rockArray.count - 1;
        } else {
            for (int n = 1; n < (rockArray.count - 1); n++) {
                Rock *previousRock = rockArray[n - 1];
                Rock *nextRock = rockArray[n + 1];
                rock = rockArray[n];
                if (((myPanoramicScrollview.contentOffset.x + self.view.frame.size.width/2) > previousRock.positionOnFacade) && ((myPanoramicScrollview.contentOffset.x + self.view.frame.size.width/2) < nextRock.positionOnFacade) ) {
                    self.selectedRock = n;
                }
            }
        }
    }
    previousPage = self.selectedRock;
    [self resetScrollView];
    NSLog(@"self.selectedrock = %i", self.selectedRock);
    NSLog(@"myscrollview.contentoffset.x = %f", myScrollView.contentOffset.x);
    NSLog(@"myscrollview.contentsize.width = %f",myScrollView.contentSize.width);
}

-(void)photoLayout:(int)photoPage
{
    if ((photoPage - 1) >= 0) {
        [self drawPhotos:(photoPage - 1)];
    }
    
    if (rockArray[photoPage]) {
        [self drawPhotos:photoPage];
    }
    
    if ( ((photoPage + 1) < rockArray.count) ) {
        [self drawPhotos:(photoPage + 1)];
    }
}

-(void)drawPhotos:(int)sub
{
    NSLog(@"drawing photo at sub %i", sub);
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
    [coachMarkImageView removeFromSuperview];

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
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    else
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void) setupGestureRecognizerAbsentNavbar {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar)];
    gestureRecognizer.numberOfTapsRequired = 1;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    UIView *navBarTapView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:navBarTapView];
    navBarTapView.backgroundColor = [UIColor clearColor];
    [navBarTapView setUserInteractionEnabled:YES];
    [navBarTapView addGestureRecognizer:gestureRecognizer];
}

- (void) setupNavbarGestureRecognizer {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar)];
    gestureRecognizer.numberOfTapsRequired = 1;
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
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) || ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        currentOrientation = 1;
        
        if (previousOrientation != currentOrientation) {
            [self determinePositionOnPanorama];
        }
        
        myScrollView.hidden = YES;
        myPanoramicScrollview.hidden = NO;
        
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
        previousOrientation = 1;
        
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        currentOrientation = 0;
        
        if (currentOrientation != previousOrientation) {
            [self determinePositionOnScrollView];
        }
        
        myPanoramicScrollview.hidden = YES;
        myScrollView.hidden = NO;
        previousOrientation = 0;
    }
}

-(void)onButtonPressed:(UIButton *)button
{
    switch (button.tag) {
        case 1:
            myPanoramicScrollview.contentOffset = CGPointMake(0, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 2:
            myPanoramicScrollview.contentOffset = CGPointMake(5841, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 3:
            myPanoramicScrollview.contentOffset = CGPointMake(7486, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 4:
            myPanoramicScrollview.contentOffset = CGPointMake(9691, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 5:
            myPanoramicScrollview.contentOffset = CGPointMake(10781, 50);
            [self checkMyPanoramicScrollViewContentOffset];
            break;
        case 6:
            myPanoramicScrollview.contentOffset = CGPointMake(12416, 50);
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

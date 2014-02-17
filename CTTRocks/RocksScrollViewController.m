//
//  ViewController.m
//  CTTRocks
//
//  Created by Josef Hilbert on 11.02.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "RocksScrollViewController.h"
#import "ILTranslucentView.h"
#import "Rock.h"

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface RocksScrollViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, UITabBarDelegate>
{
    __weak IBOutlet UIScrollView *myScrollView;
    __weak IBOutlet UIScrollView *myPanoramicScrollview;
    
    NSArray *imagePaths;
    float startingX;
    BOOL isOverlayOn;
    UIView *detailOverlay;
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
    
    //Programmatically add bar buttons
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didTapAction)];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(goToSearch)];
    NSArray *actionButtonItems = @[shareItem, searchItem];
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

-(void)goToSearch
{
    //
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
   
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.enabled = YES;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [myScrollView addGestureRecognizer:tapGestureRecognizer];
    isOverlayOn = NO;
    rockArray = [Rock rocks];
    Rock *rock;
    CGFloat width = 0.0;
    
    for (int n = 0; n < rockArray.count; n++) {
        rock = rockArray[n];

        UIImageView *myImageView = [[UIImageView alloc] initWithImage:rock.image];
        myImageView.contentMode = UIViewContentModeScaleToFill;
        myImageView.frame = CGRectMake(width, 0, self.view.frame.size.width, myScrollView.frame.size.height);
        [myScrollView addSubview:myImageView];
        
        width += myImageView.frame.size.width;
    }
    myScrollView.contentSize = CGSizeMake(width, myScrollView.frame.size.height);
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    startingX = (int)self.selectedRock * (int)self.view.frame.size.width;
    [myScrollView setContentOffset:CGPointMake(startingX, self.view.frame.size.height)];
    
    detailOverlay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, myScrollView.contentSize.width, myScrollView.contentSize.height)];
    [detailOverlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.1]];
    [self drawOverlay];
    [myScrollView addSubview:detailOverlay];
    detailOverlay.hidden = YES;

    self.setupGestureRecognizerAbsentNavbar;
    
    self.setupNavbarGestureRecognizer;
}


//Add share functionality
- (void)didTapAction {
    NSString *shareString = @"Tribune Tower, Chicago";
    UIImage *shareImage = ((Rock*)rockArray[self.selectedRock]).image;
    
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareImage, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  //  activityViewController.navigationItem.textColor =
    [self presentViewController:activityViewController animated:YES completion:nil];
}



- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [aScrollView setContentOffset:CGPointMake(aScrollView.contentOffset.x, 0.0)];
}

-(void)tapPhoto
{
    isOverlayOn = !(isOverlayOn);
    if (isOverlayOn) {
        detailOverlay.hidden = NO;
      //  [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        detailOverlay.hidden = YES;
       // [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
        return YES;
}


//- (BOOL)prefersStatusBarHidden
//{
//    if (isOverlayOn) {
//        return NO;
//    } else {
//        return YES;    }
//}



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

-(void)drawOverlay
{
    rockArray = [Rock rocks];
    for (int n = 0; n < rockArray.count; n++) {
        Rock *tempRock = rockArray[n];
        
        UIImageView *historicalImage = [[UIImageView alloc] initWithFrame:CGRectMake((n * self.view.frame.size.width) + 85, 60, 150, 150)];
        [historicalImage setImage:tempRock.imageOfBuilding];
        historicalImage.contentMode = UIViewContentModeScaleToFill;
        
//        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((n * self.view.frame.size.width) + 40, 230, 240, 270)];
//        textLabel.numberOfLines = 0;
//        textLabel.textColor = [UIColor whiteColor];
//        textLabel.textAlignment = NSTextAlignmentCenter;
//        [textLabel setFont:[UIFont fontWithName:@"Baskerville" size:16]];
//        textLabel.text = @"Less than a day after Washington and his troops crossed the Delaware, they inflicted a heavy defeat on British troops at Trenton. The Americans captured 900 Hessian mercenaries seving with the British. Less than a day after Washington and his troops crossed the Delaware, they inflicted a heavy defeat on British troops at Trenton. The Americans captured 900 Hessian mercenaries seving with the British.";
//        [textLabel sizeToFit];
  
        UITextView *textView;
        
        if (tempRock.text)
        {
            NSAttributedString *textString =  [[NSAttributedString alloc] initWithAttributedString:tempRock.text];
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textString];
            NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
            // Add layout manager to text storage object
            [textStorage addLayoutManager:textLayout];
            // Create a text container
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
            // Add text container to text layout manager
            [textLayout addTextContainer:textContainer];
 
            textView = [[UITextView alloc] initWithFrame:CGRectMake((n * self.view.frame.size.width) + 40, 230, 240, 270) textContainer:textContainer];
            
            textView.backgroundColor = [UIColor whiteColor];
            textView.editable = NO;
            textView.selectable = NO;
            textView.alpha = 0.8;
            [textView sizeToFit];
        }
        else
        {
           textView = [[UITextView alloc] initWithFrame:CGRectMake((n * self.view.frame.size.width) + 40, 230, 240, 270)];
        }
        
        UIView *myTranslucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake( ((n * self.view.frame.size.width) + 30), 30, 260, (textView.frame.origin.y + textView.frame.size.height))];
        myTranslucentView.backgroundColor = [UIColor blackColor];
        myTranslucentView.alpha = 0.4;
        
        [detailOverlay addSubview:myTranslucentView];
        [detailOverlay addSubview:historicalImage];
        [detailOverlay addSubview:textView];
    }
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
//        [self transformView2ToLandscape];
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

//-(void) transformView2ToLandscape {
//    
//    NSInteger rotationDirection;
//    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
//    
//    if(currentOrientation == UIDeviceOrientationLandscapeLeft){
//        rotationDirection = 4;
//    }else {
//        rotationDirection = -4;
//    }
//    
//    CGRect myFrame = CGRectMake(0, 0, 480, 300);
//    CGAffineTransform transform = [myPanoramicScrollview transform];
//    transform = CGAffineTransformRotate(transform, DEGREES_RADIANS(rotationDirection * 90));
//    [myPanoramicScrollview setFrame: myFrame];
//    CGPoint center = CGPointMake(myFrame.size.height/2.0, myFrame.size.width/2.0);
//    [myPanoramicScrollview setTransform: transform];
//    [myPanoramicScrollview setCenter: center];
//    
//}

@end




//
//        imageView.frame = CGRectMake(width, 0, self.view.frame.size.width, 200);
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        [scrollView addSubview:imageView];

//        UIView *lowerPart = [[UIView alloc] init];
//        lowerPart.tag = 001;
//        [scrollView addSubview:lowerPart];
//        lowerPart.frame = CGRectMake(width, 200, self.view.frame.size.width, screenHeight - 200);
//        lowerPart.backgroundColor = [UIColor colorWithRed:255/255.0f green:208/255.0f blue:114/255.0f alpha:1.0];
//
//        UILabel *title = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, 21))];
//        [title setText: rock.title];
//        [title setFont:fontForTitle];
//        title.textAlignment = NSTextAlignmentCenter;
//
//        [lowerPart addSubview:title];

//      location: combine country, state, location
//        UILabel *location = [[UILabel alloc] initWithFrame:(CGRectMake(10, 22, 250, 21))];
//        if ([rock.country isEqualToString:@"USA"])
//        {
//            location.text = [NSString stringWithFormat:@"%@ %@ %@",rock.country, rock.state, rock.city];
//        }
//        else
//        {
//            location.text = [NSString stringWithFormat:@"%@ %@",rock.country, rock.city];
//        }
//        [location setFont:fontForLocation];
//        [lowerPart addSubview:location];

//        UILabel *year = [[UILabel alloc] initWithFrame:(CGRectMake(270, 22, 50, 21))];
//        year.text = rock.year;
//        [year setFont:fontForLocation];
//        [lowerPart addSubview:year];

//        NSAttributedString *textString =  [[NSAttributedString alloc] initWithString:rock.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]}];
//        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textString];
//        NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
//        // Add layout manager to text storage object
//        [textStorage addLayoutManager:textLayout];
//        // Create a text container
//        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
//        // Add text container to text layout manager
//        [textLayout addTextContainer:textContainer];
//
//        UITextView *textView = [[UITextView alloc] initWithFrame:(CGRectMake(0, 42, self.view.frame.size.width, screenHeight - 200 - 42 - 64 - 48)) textContainer:textContainer];
//        [lowerPart addSubview:textView];
//        textView.backgroundColor = [UIColor colorWithRed:255/255.0f green:254/255.0f blue:216/255.0f alpha:1.0];
//        textView.text = rock.text;
//        textView.editable = NO;
//        textView.selectable = NO;
//
//        UIImageView *imageOfBuildingView = [[UIImageView alloc] initWithImage:rock.imageOfBuilding];
//        [lowerPart addSubview:imageOfBuildingView];
//        imageOfBuildingView.contentMode = UIViewContentModeScaleAspectFit;
//        imageOfBuildingView.frame = CGRectMake(0, 42, self.view.frame.size.width, screenHeight - 200 - 42 - 64 - 48);
//        imageOfBuildingView.clipsToBounds = YES;
//        imageOfBuildingView.backgroundColor = [UIColor blackColor];
//
//        imageOfBuildingView.alpha = 0;
//        imageOfBuildingView.tag = 100;

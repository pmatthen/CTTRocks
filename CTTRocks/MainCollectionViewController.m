//
//  MainCollectionViewController.m
//  CTT
//
//  Created by Josef Hilbert on 26.01.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "MainCollectionViewController.h"
#import "RocksScrollViewController.h"
#import "CTTCollectionViewCell.h"
#import "Rock.h"
#import "WelcomeViewController.h"
#import "AcknowledgementsViewController.h"

@interface MainCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

{
    NSArray *rocks;
    UIImage *imageForCell;
    
    UISearchBar *mySearchBar;

    IBOutlet UICollectionView *myCollectionView;
    __weak IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
    
    NSIndexPath *selectedIP;
    NSMutableArray *arrayOfAllIndexPaths;
    
    UIFont *fontForTitle;
    UIFont *fontForLocation;
    UIFont *fontForNumber;
    
}

@end

@implementation MainCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    
    fontForTitle = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    fontForLocation = [UIFont fontWithName:@"HelveticaNeue" size:17];
    fontForNumber = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    [myCollectionView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
    mySearchBar.delegate = self;
    [self.view addSubview:mySearchBar];
    self.navigationItem.title = @"Search";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tag = 1;
    
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    myCollectionView.backgroundColor = [UIColor whiteColor];
    
    myCollectionView.delegate = self;
    myCollectionView.dataSource = self;
    
    rocks = [Rock rocks];
    
    imageForCell = [UIImage imageNamed:@"640x150_rounded_opaque"];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
    {
        rocks = [Rock rocks];
    }
    else
    {
        rocks = [Rock rocksFiltered:searchText];
    }
    
    [myCollectionView performBatchUpdates:^{
        [myCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [myCollectionView reloadData];
    } completion:nil];
   }

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:@""];
    rocks = [Rock rocks];
    [myCollectionView performBatchUpdates:^{
        [myCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [myCollectionView reloadData];
    } completion:nil];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CTTCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    Rock *rock = rocks[indexPath.row];

    cell.imageViewRockThumbnail.image = rock.imageThumbnail;

    cell.imageViewRockThumbnail.contentMode = UIViewContentModeScaleAspectFit;

    cell.labelTitle.text = rock.title;
    [cell.labelTitle setFont:fontForTitle];
    
    if (indexPath.row % 2) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.671 green:0.741 blue:0.761 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.478 green:0.663 blue:0.78 alpha:1];
    }

    if ([rock.country isEqualToString:@"USA"]) {
        cell.labelLocation.text = [NSString stringWithFormat:@"%@ %@ %@",rock.country, rock.state, rock.location];
    }
    else {
        cell.labelLocation.text = [NSString stringWithFormat:@"%@ %@",rock.country, rock.location];
    }
    
    [cell.labelLocation setFont:fontForLocation];
    cell.labelNumber.text = [NSString stringWithFormat:@"%03d", (int)indexPath.row + 1];
    [cell.labelNumber setFont:fontForNumber];
    [arrayOfAllIndexPaths addObject:indexPath];
  
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    arrayOfAllIndexPaths = [NSMutableArray new];
    return rocks.count;
}

- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select %li", (long)indexPath.row);
    CTTCollectionViewCell *cell = ((CTTCollectionViewCell*)[myCollectionView cellForItemAtIndexPath:indexPath]);
    cell.imageView.alpha = 1.0;
    selectedIP = indexPath;
    
    [self performSegueWithIdentifier:@"unwindSegue" sender:indexPath];
}

- (void)collectionView:(UICollectionView *)cv didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did deselect");
    CTTCollectionViewCell *cell = ((CTTCollectionViewCell*)[myCollectionView cellForItemAtIndexPath:indexPath]);
    cell.imageView.alpha = 1.0;
}

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320, 65);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        if (reusableview==nil) {
            reusableview=[[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        }
  //      [reusableview addSubview:searchBar];
       
        return reusableview;
    }
    return nil;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"unwindSegue"])
    {
        RocksScrollViewController *vc = segue.destinationViewController;
        
        Rock *rock = rocks[selectedIP.row];
        
        for (int n = 0; n < vc.rockArray.count; n++) {
            Rock *tempRock = vc.rockArray[n];
            if (rock.positionOnFacade == tempRock.positionOnFacade) {
                vc.selectedRock = n;
                NSLog(@"n = %i", n);
            }
        }
//        
//        
//        vc.selectedRock = selectedIP.row;
//        vc.rockArray = rocks;
//        NSLog(@"segue to %li", (long)selectedIP.row);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

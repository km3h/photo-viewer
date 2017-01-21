//
//  PhotosViewController.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoViewController.h"

@interface PhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) PhotosViewControllerConstants photosViewControllerConstants;
@end

@implementation PhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PhotosViewControllerConstants constants = self.photosViewControllerConstants;
    constants.approximateCellWidth = 100.0;
    constants.cellMargin = 3.0;
    self.photosViewControllerConstants = constants;
    
    // collection view layout
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.itemSize = CGSizeMake(100, 100);
    collectionViewLayout.minimumInteritemSpacing = self.photosViewControllerConstants.cellMargin;
    collectionViewLayout.minimumLineSpacing = self.photosViewControllerConstants.cellMargin;
    
    //setup collection view
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.backgroundColor = [[UIColor alloc] initWithRed:.91 green:.91 blue:.91 alpha:1];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add collection view
    [self.view addSubview:self.collectionView];
    [self.collectionView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [self.collectionView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self reloadData];
    [self setLayout:self.view.bounds.size];
    if (self.albumId)
    {
        self.title = [NSString stringWithFormat:@"Album %@", self.albumId];
    }
    else
    {
        self.title = @"Select Album";
    }
    [super viewWillAppear:animated];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self setLayout:size];
}

-(void)setLayout:(CGSize)size
{
    //thumbnails are about 100 x 100 points in size
    CGFloat approximateNumberOfViewsInWidth = size.width / self.photosViewControllerConstants.approximateCellWidth;
    CGFloat numberOfViewInWidth = ceil(approximateNumberOfViewsInWidth);
    CGFloat cellWidth = size.width / numberOfViewInWidth - self.photosViewControllerConstants.cellMargin;
    UICollectionViewFlowLayout *collectionLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    [collectionLayout invalidateLayout];
}

-(void)reloadData
{
    [self.dataSource dataHandler: ^(NSDictionary *json) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = json[self.albumId];
            [self.collectionView reloadData];
        });
       }
    ];
}

// MARK: - Collection view

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *collectionCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [collectionCell.contentView addSubview:imageView];
    
    [imageView.leadingAnchor constraintEqualToAnchor:collectionCell.contentView.leadingAnchor].active = YES;
    [imageView.trailingAnchor constraintEqualToAnchor:collectionCell.contentView.trailingAnchor].active = YES;
    [imageView.topAnchor constraintEqualToAnchor:collectionCell.contentView.topAnchor].active = YES;
    [imageView.bottomAnchor constraintEqualToAnchor:collectionCell.contentView.bottomAnchor].active = YES;
    
    [self.dataSource photo:DataSourcePhotoTypeThumnail photo:self.photos[indexPath.row] handler:^(UIImage *image) {
        imageView.image = image;
    }];
    
    return collectionCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PhotoViewController" bundle: nil];
    PhotoViewController *controller = [storyboard instantiateInitialViewController];
    controller.photo = self.photos[indexPath.row];
    controller.dataSource = self.dataSource;
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(photoViewControllerCancelTapped)];
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(photoViewControllerSaveTapped)];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.modalPresentationStyle =  UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

// MARK: - photo modal actions

-(void)photoViewControllerCancelTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)photoViewControllerSaveTapped
{
    NSInteger row = ((NSIndexPath*)[self.collectionView.indexPathsForSelectedItems firstObject]).row;
    
    [self.dataSource photo:DataSourcePhotoTypeFullPhoto photo:self.photos[row] handler:^(UIImage *image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSaveCompletion:didFinishSavingWithError:contextInfo:), nil);

    }];
}

-(void)imageSaveCompletion:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Save Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:alertAction];
    
    if (!error)
    {
        ac.title = @"Saved";
        ac.message = @"The image was saved to your photos.";
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

@end

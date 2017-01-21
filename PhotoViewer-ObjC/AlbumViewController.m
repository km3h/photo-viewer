//
//  AlbumViewController.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "AlbumViewController.h"
#import "PhotosViewController.h"
#import "AlbumTableViewCell.h"

@interface AlbumViewController ()
@property (strong, nonatomic) PhotosViewController *photosViewController;
@property (strong, nonatomic) NSArray *albumIds;
@end

@implementation AlbumViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.splitViewController action:NSSelectorFromString(@"backButtonTapped")];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *controllers = self.splitViewController.viewControllers;
    self.photosViewController = (PhotosViewController*)((UINavigationController*)[controllers lastObject]).topViewController;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [self reloadData];
    [super viewWillAppear:animated];
}

-(void)reloadData
{
    [self.dataSource dataHandler:^(NSDictionary *json) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSArray *keys = [json allKeys];
            NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull n1, id  _Nonnull n2) { return [n1 intValue] > [n2 intValue];}];
            self.albumIds = sortedKeys;
            [self.tableView reloadData];
        });
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"showDetail"])
    {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        PhotosViewController *controller = (PhotosViewController*)((UINavigationController*)(segue.destinationViewController)).topViewController;
        NSNumber *albumId = self.albumIds[indexPath.row];
        controller.albumId = albumId;
        controller.dataSource = self.dataSource;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumIds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumTableViewCell *cell = (AlbumTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSNumber *object = self.albumIds[indexPath.row];
    cell.sideLabel.text = [NSString stringWithFormat:@"Album %@", object.description];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

@end

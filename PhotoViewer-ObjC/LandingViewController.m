//
//  landingViewController.m
//  PhotoViewer
//
//  Created by ASIM27 on 1/20/17.
//  Copyright © 2017 km3h. All rights reserved.
//

#import "landingViewController.h"
#import "DataSource.h"

@interface LandingViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) DataSource *dataSource;
@property (strong, nonatomic) UIPickerView *typePickerView;
@property (strong, nonatomic) UITextField *textFieldSessionType;
@end

@implementation LandingViewController

-(void)loadView
{
    self.view = [[UIView alloc] init];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"Photo Viewer", nil);
    titleLabel.font = [UIFont boldSystemFontOfSize:30];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:NSLocalizedString(@"Display Photos", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(displayPhotosButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:button];
    
    [titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:0].active = YES;
    [titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant: 20.0].active = YES;
    [titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0].active = YES;
    
    self.textFieldSessionType =  [[UITextField alloc] init];
    self.textFieldSessionType.borderStyle = UITextBorderStyleLine;
    self.textFieldSessionType.translatesAutoresizingMaskIntoConstraints = NO;
    self.textFieldSessionType.text = @"";
    self.typePickerView = [[UIPickerView alloc] init];
    self.textFieldSessionType.inputView = self.typePickerView;
    self.textFieldSessionType.delegate = self;
    [self.view addSubview:self.textFieldSessionType];
    
    [self.textFieldSessionType.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10].active = true;
    [self.textFieldSessionType.centerXAnchor constraintEqualToAnchor:titleLabel.centerXAnchor constant:10].active = true;
    
    [button.topAnchor constraintEqualToAnchor:self.textFieldSessionType.bottomAnchor constant:20].active = true;
    [button.centerXAnchor constraintEqualToAnchor:titleLabel.centerXAnchor constant:0].active = true;
    
    self.dataSource = [[DataSource alloc] init];
    self.dataSource.urlString = @"http://jsonplaceholder.typicode.com/photos";
    self.dataSource.urlSessionType = URLSessionTypeDelegate;
    [self displaySelectedSessionType:self.dataSource.urlSessionType];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displaySessionTypePicker:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.typePickerView.dataSource = self;
    self.typePickerView.delegate = self;
}

-(void)displayPhotosButtonTapped:(id)sender
{
    self.albumsPhotosSplitVC.dataSource = self.dataSource;
    [self presentViewController:self.albumsPhotosSplitVC animated:YES completion:nil];
}

-(void)displaySelectedSessionType:(enum URLSessionType)sessionType
{
    switch (sessionType)
    {
        case URLSessionTypeDelegate:
            self.textFieldSessionType.text = @"Session Type: Delegate";
            break;
        case URLSessionTypeCompletionHandler:
            self.textFieldSessionType.text = @"Session Type: Completion Handler";
            break;
        default:
            break;
    }
}

-(void)displaySessionTypePicker:(id)sender
{
    [self.textFieldSessionType resignFirstResponder];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return row == 0 ? @"Delegate" : @"Completion Handler";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    URLSessionType selectedSessionType = row == 0 ? URLSessionTypeDelegate : URLSessionTypeCompletionHandler;
    self.dataSource.urlSessionType = selectedSessionType;
    [self displaySelectedSessionType:selectedSessionType];
}

@end

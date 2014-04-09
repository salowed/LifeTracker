//
//  DSSelectedActitvityViewController.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/9/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSSelectedActitvityViewController.h"

@interface DSSelectedActitvityViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
- (IBAction)startClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *todayField;
@property (weak, nonatomic) IBOutlet UILabel *goalField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@end

@implementation DSSelectedActitvityViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startClicked:(id)sender {
}
@end

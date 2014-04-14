//
//  DSSelectedActitvityViewController.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/9/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSSelectedActitvityViewController.h"
#import "DSAppDelegate.h"

@interface DSSelectedActitvityViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
- (IBAction)startClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *todayField;
@property (weak, nonatomic) IBOutlet UILabel *goalField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic, strong) DSAppDelegate *appDelegate;
@property (nonatomic, strong) Activity *selectedActivity;

@end

@implementation DSSelectedActitvityViewController


- (DSAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (DSAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

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
    
    for(int i = 0; i < self.appDelegate.allActivities.count; i++){
        Activity *activity = self.appDelegate.allActivities[i];
        if([activity.name isEqualToString:self.activityTitle]){
            self.selectedActivity = activity;
            break;
        }
    }
    
    self.navigationBar.title = self.selectedActivity.name;
    
    if([self.selectedActivity.type isEqualToString:@"Time"]){
        int hour = [self.selectedActivity.time integerValue]/60;
        int minute = [self.selectedActivity.time integerValue] - (hour * 60);
        self.goalField.text = [NSString stringWithFormat:@"%d:%d", hour, minute];
        
        if([self.selectedActivity.startTime isEqualToString:@"NO"]){
            self.todayField.text = @"00:00";
            self.progressBar.progress = 0.0;
        }
        else if([self.selectedActivity.endTime isEqualToString:@"NO"]){
            float totalTime = [self.selectedActivity.time integerValue];
            
            float timeElasped = [self.selectedActivity.timeElasped intValue];
            
            hour = timeElasped/60;
            minute = timeElasped - (hour * 60);
            self.goalField.text = [NSString stringWithFormat:@"%d:%d", hour, minute];
            
            self.progressBar.progress = timeElasped/totalTime;
        }
        else{
            self.todayField.text = [NSString stringWithFormat:@"%d:%d", hour, minute];
            self.progressBar.progress = 1.0;
        }
    }
    else{
        self.goalField.text = [NSString stringWithFormat:@"Do %@", self.selectedActivity.name];
        if([self.selectedActivity.startTime isEqualToString:@"NO"]){
            self.todayField.text = @"Not Complete";
            self.progressBar.progress = 0.0;
        }
        else{
           self.todayField.text = @"Completed";
            self.progressBar.progress = 1.0;
        }
    }
    
    
    
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

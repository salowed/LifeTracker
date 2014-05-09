//
//  DSSelectedActitvityViewController.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/9/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSSelectedActitvityViewController.h"
#import "DSAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DSSelectedActitvityViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
- (IBAction)startClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *todayField;
@property (weak, nonatomic) IBOutlet UILabel *goalField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic, strong) DSAppDelegate *appDelegate;
@property (nonatomic, strong) Activity *selectedActivity;


@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *aaplPlot;
@property (nonatomic, strong) CPTBarPlot *googPlot;
@property (nonatomic, strong) CPTBarPlot *msftPlot;
@property (nonatomic, strong) CPTBarPlot *activityPlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;
@property (nonatomic, strong) CLLocationManager *locationManager;


-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
-(void)hideAnnotation:(CPTGraph *)graph;

@end

@implementation DSSelectedActitvityViewController

DSActivity *temp;
Activity *temp2;
BOOL timerRunning;
NSDate *date;
int startHour;
int startMin;
int startSec;
NSMutableArray* past7;



- (DSAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (DSAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    
    return _locationManager;
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
    
    [self.locationManager startUpdatingLocation];
    
    // Do any additional setup after loading the view.
    
    for(int i = 0; i < self.appDelegate.allActivities.count; i++){
        Activity *activity = self.appDelegate.allActivities[i];
        if([activity.name isEqualToString:self.activityTitle]){
            self.selectedActivity = activity;
            temp2 = activity;
            break;
        }
    }
    
    //make temp version of the selected activity
    temp = [[DSActivity alloc] init];
    temp.name = self.selectedActivity.name;
    temp.longitude =self.selectedActivity.longitude;
    temp.latitude =self.selectedActivity.latitude;
    temp.timerRunning =self.selectedActivity.timerRunning;
    temp.goalTime =self.selectedActivity.goalTime;
    temp.type =self.selectedActivity.type;
    temp.previousDays =self.selectedActivity.previousDays;
    
    past7 = [[NSMutableArray alloc] initWithArray:[self sumAndUpdateDays]];
    
    timerRunning = temp.timerRunning.boolValue;
    NSLog(@"%hhd", timerRunning);
    
    [self initPlot];
    
    //for(int i = 0; i < self.appDelegate.)
    
    /*temp2 = [[Activity alloc] init];
     temp2.name = self.selectedActivity.name;
     temp2.longitude =self.selectedActivity.longitude;
     temp2.latitude =self.selectedActivity.latitude;
     temp2.timerRunning =self.selectedActivity.timerRunning;
     temp2.goalTime =self.selectedActivity.goalTime;
     temp2.type =self.selectedActivity.type;
     temp2.previousDays =self.selectedActivity.previousDays;*/
    
    //NSLog([NSString stringWithFormat:@"Timer running when initializing: %@", temp2.timerRunning]);
    
    //////Sum all time from today
    //Get Current time
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd";
    NSString *currentDay = [dateFormatter stringFromDate: localDate];
    //NSLog([NSString stringWithFormat:@"current day: %@", currentDay]);
    
    //Pull last start time and initialize timer values
    NSString *prevDays = temp.previousDays;
    //NSLog([NSString stringWithFormat:@"prev day: %@",prevDays]);
    NSArray *tokenized = [prevDays componentsSeparatedByString:@","];
    int totalTimeToday = 0;
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    dateFormatter2.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
    
    //Sum the total time for the day
    for (int i = 0; i < tokenized.count; i+=2)
    {
        NSDate *logDate = [dateFormatter2 dateFromString:[tokenized objectAtIndex:i]];
        NSString *day = [dateFormatter stringFromDate: logDate];
        if ([day isEqualToString:currentDay])
        {
            NSString *loggedTime =[tokenized objectAtIndex:i+1];
            //NSLog(@"%d", totalTimeToday);
            if (loggedTime != nil) totalTimeToday += loggedTime.integerValue;
            //NSLog([NSString stringWithFormat:@"Logged: %@, Total: %d", loggedTime,totalTimeToday]);
        }
    }
    
    int h = totalTimeToday/3600;
    int m = (totalTimeToday - h*3600)/60;
    int s = (totalTimeToday - h*3600 - m*60);
    NSString *leadZeroSec;
    NSString* leadZero;
    if (m < 10) {
        leadZero = @"0";
    } else leadZero = @"";
    if (s < 10) {
        leadZeroSec = @"0";
    } else leadZeroSec = @"";
    self.todayField.text = [NSString stringWithFormat:@"%d:%@%d:%@%d", h,leadZero, m, leadZeroSec, s];
    
    if ([temp.timerRunning  isEqual: @"YES"])
    {
        NSLog(@"Loaded with timer running");
        self.startStopLabel.text = @"Stop";
        //Get Current time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
        
        //Pull last start time and initialize timer values
        NSString *prevDays = temp.previousDays;
        NSString *newestStartTime = [[prevDays componentsSeparatedByString:@","] objectAtIndex:0];
        NSDate *starter = [dateFormatter dateFromString:newestStartTime];
        NSTimeInterval since = [starter timeIntervalSinceDate:localDate];
        
        int h = since/3600;
        int m = (since - h*3600)/60;
        int s = -(since - h*3600 - m*60);
        NSString *leadZeroSec;
        NSString* leadZero;
        if (m < 10) {
            leadZero = @"0";
        } else leadZero = @"";
        if (s < 10) {
            leadZeroSec = @"0";
        } else leadZeroSec = @"";
        //Set labels to correct starting values
        self.sec.text = [NSString stringWithFormat:@"%@%d",leadZeroSec, s];
        self.min.text = [NSString stringWithFormat:@"%@%d",leadZero, m];
        self.hr.text = [NSString stringWithFormat:@"%d", h];
        
        //Start Timer
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(showTime)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    
    self.navigationBar.title = self.selectedActivity.name;
    
    if([self.selectedActivity.type isEqualToString:@"Time"]){
        int hour = [self.selectedActivity.goalTime integerValue]/60;
        int minute = [self.selectedActivity.goalTime integerValue] - (hour * 60);
        NSLog(@"%d", minute);
        NSString* leadZero;
        if (minute < 10) {
            leadZero = @"0";
        } else leadZero = @"";
        self.goalField.text = [NSString stringWithFormat:@"%d:%@%d:00", hour,leadZero, minute];
        
        
    }
    
    //NSLog(@"Progress:%d Total: %d Goal: %d",totalTimeToday/([self.selectedActivity.goalTime integerValue]*60),totalTimeToday,([self.selectedActivity.goalTime integerValue]*60));
    self.progressBar.progress = (double)totalTimeToday/([self.selectedActivity.goalTime integerValue]*60);
    
    [self sumAndUpdateDays];
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

#pragma mark - Timer stuff
- (IBAction)startClicked:(UIButton *)sender
{
    
    //If timer is not currently running
    if (!timerRunning)
    {
        //Swap timer
        timerRunning = YES;
        temp.timerRunning = @"YES";
        self.startStopLabel.text = @"Stop";
        
        //Get the current local date
        NSDate *localDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
        NSString *dateString = [dateFormatter stringFromDate: localDate];
        //Pull Existing activity log and append the new start to the beginning
        NSString *newLog = [NSString stringWithFormat:@"%@,0,", dateString];
        if (temp.previousDays != nil) {
            temp.previousDays = [NSString stringWithFormat:@"%@%@", newLog, temp.previousDays];
        }
        else temp.previousDays = [NSString stringWithFormat:@"%@", newLog];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(showTime)
                                                    userInfo:nil
                                                     repeats:YES];
        
        
        temp.latitude = [NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.latitude];
        temp.longitude = [NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.longitude];
        if ([self.appDelegate deleteActivity:temp2]) NSLog(@"Successfully Deleted");
        
        [self.appDelegate addActivityFromWrapper:temp];
        /*temp2 = [[DSActivity alloc] init];
         temp2.name = temp.name;
         temp2.longitude = temp.longitude;
         temp2.latitude = temp.latitude;
         temp2.timerRunning = temp.timerRunning;
         NSLog(temp2.timerRunning);
         temp2.goalTime = temp.goalTime;
         temp2.type = temp.type;
         temp2.previousDays = temp.previousDays;*/
        for(int i = 0; i < self.appDelegate.allActivities.count; i++){
            Activity *activity = self.appDelegate.allActivities[i];
            if([activity.name isEqualToString:self.activityTitle]){
                temp2 = activity;
                break;
            }
        }
        
        //[self.appDelegate addActivityFromWrapper:temp];
    }
    //If Timer is currently running
    else {
        //Stop Timer and swap timer related booleans/labels
        [self.timer invalidate];
        timerRunning = NO;
        temp.timerRunning = @"NO";
        self.startStopLabel.text = @"Start";
        
        //Get the current date and time
        NSDate *localDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
        
        //Pull the logs for the activity
        NSString *prevDays = temp.previousDays;
        NSString *newestStartTime = [[prevDays componentsSeparatedByString:@","] objectAtIndex:0];
        NSDate *starter = [dateFormatter dateFromString:newestStartTime];
        
        //Time since the last log
        NSTimeInterval since = [localDate timeIntervalSinceDate:starter];
        NSArray *prev = [prevDays componentsSeparatedByString:@","];
        NSString *final = @"";
        for (int i = 0; i < [prev count]; i++)
        {
            if (i == 1)
            {
                final = [final stringByAppendingString:[NSString stringWithFormat:@"%.0f", since]];
            }
            else
            {
                final = [final stringByAppendingString:[prev objectAtIndex:i]];
            }
            if (i+1 != [prev count]) final = [final stringByAppendingString:@","];
        }
        temp.previousDays = final;
        
        [self.appDelegate deleteActivity:temp2];
        [self.appDelegate addActivityFromWrapper:temp];
        
        for(int i = 0; i < self.appDelegate.allActivities.count; i++){
            Activity *activity = self.appDelegate.allActivities[i];
            if([activity.name isEqualToString:self.activityTitle]){
                temp2 = activity;
                break;
            }
        }
        
        //NSLog(temp.previousDays);
        //[self.appDelegate addActivityFromWrapper:temp];
        
        
        //////Sum all time from today
        //Get Current time
        localDate = [NSDate date];
        dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd";
        NSString *currentDay = [dateFormatter stringFromDate: localDate];
        
        //Pull last start time and initialize timer values
        prevDays = temp.previousDays;
        NSLog(@"prev day");
        NSArray *tokenized = [prevDays componentsSeparatedByString:@","];
        int totalTimeToday = 0;
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
        dateFormatter2.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
        
        for (int i = 0; i < tokenized.count-1; i+=2)
        {
            NSDate *logDate = [dateFormatter2 dateFromString:[tokenized objectAtIndex:i]];
            NSString *day = [dateFormatter stringFromDate: logDate];
            if ([day isEqualToString:currentDay])
            {
                NSString *loggedTime =[tokenized objectAtIndex:i+1];
                totalTimeToday += loggedTime.integerValue;
            }
        }
        
        //Update the today string to show logged time
        int h = totalTimeToday/3600;
        int m = (totalTimeToday - h*3600)/60;
        int s = (totalTimeToday - h*3600 - m*60);
        
        NSString* leadZero;
        NSString* leadZeroS;
        if (m < 10) {
            leadZero = @"0";
        } else leadZero = @"";
        if (s < 10) {
            leadZeroS = @"0";
        } else leadZeroS = @"";
        self.todayField.text = [NSString stringWithFormat:@"%d:%@%d:%@%d", h, leadZero, m,leadZeroS, s];
        
        //update progress bar
        self.progressBar.progress = (double)totalTimeToday/([temp.goalTime integerValue]*60);
        
        //update graph
        [self viewDidLoad];
    }
}

- (void)showTime
{
    int hours = self.hr.text.intValue;
    int minutes = self.min.text.intValue;
    int seconds = self.sec.text.intValue;
    int hundredths = 0;
    
    NSArray *timeArray = [NSArray arrayWithObjects:self.hun, self.sec.text, self.min.text, self.hr.text, nil];
    
    for (int i = [timeArray count] - 1; i >= 0; i--)
    {
        int timeComponent = [[timeArray objectAtIndex:i] intValue];
        switch (i) {
            case 3:
                hours = timeComponent;
                break;
            case 2:
                minutes = timeComponent;
                break;
            case 1:
                seconds = timeComponent;
                break;
            case 0:
                hundredths = timeComponent;
                hundredths++;
                break;
                
            default:
                break;
        }
        
    }
    if (hundredths == 100) {
        seconds++;
        hundredths = 0;
    }
    else if (seconds == 60) {
        minutes++;
        seconds = 0;
    }
    else if (minutes == 60) {
        hours++;
        minutes = 0;
    }
    self.hr.text = [NSString stringWithFormat:@"%.2d", hours];
    self.min.text = [NSString stringWithFormat:@"%.2d", minutes];
    self.sec.text = [NSString stringWithFormat:@"%.2d", seconds];
    self.hun = [NSString stringWithFormat:@"%d", hundredths];
    
}

- (NSMutableArray*)sumAndUpdateDays
{
    //Parse the past days string for individual logs
    NSString *prevDays = temp.previousDays;
    NSArray *tokenized = [prevDays componentsSeparatedByString:@","];
    
    //get today's day
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd";
    NSString *currentDay = [dateFormatter stringFromDate: localDate];
    
    //Date formatter for parsing out the logged dates
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    dateFormatter2.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
    
    //get maximum number of days in previous month
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc]init];
    dateFormatter3.dateFormat = @"MM";
    int prevMonth = [[dateFormatter3 stringFromDate: localDate] integerValue] - 1;
    if (prevMonth == 0) prevMonth = 12;
    NSDate *prevMonthDate = [dateFormatter3 dateFromString:[NSString stringWithFormat:@"%d", prevMonth]];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSRange currentRange = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:prevMonthDate];
    NSNumber* numberOfDays = [NSNumber numberWithInt:currentRange.length];
    NSNumber* currentDayInt = [NSNumber numberWithInt:[currentDay integerValue]];
    
    NSMutableArray *last7days = [NSMutableArray arrayWithObjects:
                                 currentDayInt, [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:((currentDayInt.intValue-1)% numberOfDays.intValue)], [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:((currentDayInt.intValue-2)% numberOfDays.intValue)], [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:((currentDayInt.intValue-3)% numberOfDays.intValue)], [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:((currentDayInt.intValue-4)% numberOfDays.intValue)], [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:((currentDayInt.intValue-5)% numberOfDays.intValue)], [NSNumber numberWithInt:0],
                                 [NSNumber numberWithInt:((currentDayInt.intValue-6)% numberOfDays.intValue)], [NSNumber numberWithInt:0],
                                 nil];
    
    for (int i = 0; i < last7days.count; i+=2)
    {
        if ([[last7days objectAtIndex:i] integerValue] == 0)
        {
            [last7days replaceObjectAtIndex:i withObject:numberOfDays];
        }
    }
    //Sum the total time for the day and remove any logs from more than 7 days ago
    NSString *updatedPrevDays;
    if (tokenized != nil)
    {
        for (int i = 0; i < tokenized.count-1; i+=2)
        {
            if ([tokenized objectAtIndex:i] != Nil){
                //get the day of this logged
                NSDate *logDate = [dateFormatter2 dateFromString:[tokenized objectAtIndex:i]];
                NSString *day = [dateFormatter stringFromDate: logDate];
                
                //check if the day is one of the last 7 (ie the day exists in the last7days array
                NSUInteger index = [last7days indexOfObject:[NSNumber numberWithInt:day.intValue]];
                if (index <= last7days.count)
                {
                    int loggedTime = [[tokenized objectAtIndex:i+1] integerValue];
                    [last7days replaceObjectAtIndex:index+1
                                         withObject:[NSNumber numberWithInt:([[last7days objectAtIndex:(index+1)] integerValue] + loggedTime)]];
                    if (updatedPrevDays != nil)
                    {
                        updatedPrevDays = [NSString stringWithFormat:@"%@%@,%@,",
                                           updatedPrevDays, [tokenized objectAtIndex:i], [tokenized objectAtIndex:i+1]];
                    } else {
                        updatedPrevDays = [NSString stringWithFormat:@"%@,%@,", [tokenized objectAtIndex:i], [tokenized objectAtIndex:i+1]];
                    }
                    
                    
                }
            }
        }
    }
    
    temp.previousDays = updatedPrevDays;
    
    //////////////  Update temp.previous days here with fake information to do testing ///////////////
    //temp.previousDays = @"05/07/14/13:00:36.185,5,05/07/14/13:00:23.629,7,05/07/14/12:48:08.564,2,05/07/14/12:46:56.173,10,05/06/14/12:43:29.201,5,05/06/14/12:42:39.145,22,05/05/14/12:42:19.636,19,05/05/14/12:41:36.980,42,05/04/14/06:47:24.610,11,05/04/14/06:47:21.897,2,05/03/14/06:46:53.338,16,05/01/14/06:41:41.469,21,";
    
    return last7days;
    [self viewDidLoad];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat const CPDBarWidth = 0.125f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize hostView    = hostView_;
@synthesize aaplPlot    = aaplPlot_;
@synthesize googPlot    = googPlot_;
@synthesize msftPlot    = msftPlot_;
@synthesize activityPlot    = activityPlot_;

@synthesize priceAnnotation = priceAnnotation_;

#pragma mark - Rotation
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    //return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
//    return NO;
//}

#pragma mark - Chart behavior
-(void)initPlot {
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph {
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	graph.plotAreaFrame.masksToBorder = NO;
	self.hostView.hostedGraph = graph;
	// 2 - Configure the graph
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
	graph.paddingBottom = 25.0f;
	graph.paddingLeft  = 20.0f;
	graph.paddingTop    = 1.0f;
	graph.paddingRight  = 1.0f;
	// 3 - Set up styles
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor blackColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	// 4 - Set up title
	NSString *title = @"Time spent over last 7 days";
	graph.title = title;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 20.0f);
	// 5 - Set up plot space
	CGFloat xMin = 0.0f;
	CGFloat xMax = 7.0f;//[[[CPDStockPriceStore sharedInstance] datesInWeek] count];
	CGFloat yMin = 0.0f;
    CGFloat yMax = 0.0f;
    
    int max = [[past7 valueForKeyPath:@"@max.intValue"] intValue];
    if (max > temp.goalTime.intValue*60*1.1) {
        yMax = max*1.1;
    } else {
        yMax = temp.goalTime.intValue*60*1.1;
    }
    
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
	// 1 - Set up the three plots
    //	self.aaplPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    //	self.aaplPlot.identifier = CPDTickerSymbolAAPL;
    //	self.googPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    //	self.googPlot.identifier = CPDTickerSymbolGOOG;
    //	self.msftPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    //	self.msftPlot.identifier = CPDTickerSymbolMSFT;
	self.activityPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
	self.activityPlot.identifier = CPDActivity;
	// 2 - Set up line style
	CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
	barLineStyle.lineColor = [CPTColor blackColor];
	barLineStyle.lineWidth = 0.5;
	// 3 - Add plots to graph
	CPTGraph *graph = self.hostView.hostedGraph;
	CGFloat barX = CPDBarInitialX;
	NSArray *plots = [NSArray arrayWithObjects://self.aaplPlot, self.googPlot, self.msftPlot,
                      self.activityPlot, nil];
	for (CPTBarPlot *plot in plots) {
		plot.dataSource = self;
		plot.delegate = self;
		plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
		plot.barOffset = CPTDecimalFromDouble(barX);
		plot.lineStyle = barLineStyle;
		[graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
		barX += CPDBarWidth;
	}
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle * lineStyle                      = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth              = 3.f;
    lineStyle.lineColor              = [CPTColor blackColor];
    lineStyle.dashPattern            = [NSArray arrayWithObjects:[NSNumber numberWithFloat:3.0f], [NSNumber numberWithFloat:3.0f], nil];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.identifier    = @"horizontalLineForAverage";
    dataSourceLinePlot.dataSource    = self;
    [graph addPlot:dataSourceLinePlot toPlotSpace:graph.defaultPlotSpace];
}

-(void)configureAxes {
	// 1 - Configure styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blackColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:1];
	// 2 - Get the graph's axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	// 3 - Configure the x-axis
	axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"M";
    NSString *currentMonth = [dateFormatter stringFromDate: localDate];
    NSString *prevMonthString = currentMonth;
    if ([[past7 objectAtIndex:0] intValue] < [[past7 objectAtIndex:12] intValue])
    {
        int prevMonth = currentMonth.intValue-1;
        prevMonthString = [NSString stringWithFormat:@"%d", prevMonth];
    }
    
	axisSet.xAxis.title = [NSString stringWithFormat:@"%@/%@ - %@/%@",currentMonth, [past7 objectAtIndex:0], prevMonthString, [past7 objectAtIndex:12]];
	axisSet.xAxis.titleTextStyle = axisTitleStyle;
	axisSet.xAxis.titleOffset = 10.0f;
	axisSet.xAxis.axisLineStyle = axisLineStyle;
	// 4 - Configure the y-axis
	axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
	axisSet.yAxis.title = @"";
	axisSet.yAxis.titleTextStyle = axisTitleStyle;
	axisSet.yAxis.titleOffset = 5.0f;
	axisSet.yAxis.axisLineStyle = axisLineStyle;
}

-(void)hideAnnotation:(CPTGraph *)graph {
	if ((graph.plotAreaFrame.plotArea) && (self.priceAnnotation)) {
		[graph.plotAreaFrame.plotArea removeAnnotation:self.priceAnnotation];
		self.priceAnnotation = nil;
        NSLog(@"called annotation");
	}
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return 8.0f;//[[[CPDStockPriceStore sharedInstance] datesInWeek] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    //NSLog(@"%@", CPTBarPlotFieldBarTip);
	if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < 7)) {//[[[CPDStockPriceStore sharedInstance] datesInWeek] count])) {
		if ([plot.identifier isEqual:CPDTickerSymbolAAPL]) {
			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolAAPL] objectAtIndex:index];
		} else if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolGOOG] objectAtIndex:index];
		} else if ([plot.identifier isEqual:CPDTickerSymbolMSFT]) {
			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolMSFT] objectAtIndex:index];
		} else if ([plot.identifier isEqual:CPDActivity]) {
            NSArray *arg = [NSArray arrayWithObjects:
                            [past7 objectAtIndex:1],
                            [past7 objectAtIndex:3],
                            [past7 objectAtIndex:5],
                            [past7 objectAtIndex:7],
                            [past7 objectAtIndex:9],
                            [past7 objectAtIndex:11],
                            [past7 objectAtIndex:13], nil];
			return [arg objectAtIndex:index];
        }
	}
    
    NSDecimalNumber *num = nil;
    
    // If method is called to fetch data about drawing horizontal average line, then return your generated average value.
    if( [plot.identifier isEqual:@"horizontalLineForAverage"])
    {
        if(fieldEnum == CPTScatterPlotFieldX )
        {
            // this line will remain as it is
            num =(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:index];
        }
        else
        {
            num = (NSDecimalNumber *) [NSDecimalNumber numberWithDouble:temp.goalTime.intValue*60];
        }
        return num;
    }
    
	return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
	// 1 - Is the plot hidden?
	if (plot.isHidden == YES) {
		return;
	}
	// 2 - Create style, if necessary
	static CPTMutableTextStyle *style = nil;
	if (!style) {
		style = [CPTMutableTextStyle textStyle];
		style.color= [CPTColor blackColor];
		style.fontSize = 16.0f;
		style.fontName = @"Helvetica-Bold";
	}
	// 3 - Create annotation, if necessary
	NSNumber *price = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
    
    self.priceAnnotation = nil;
	if (!self.priceAnnotation) {
		NSNumber *x = [NSNumber numberWithInt:0];
		NSNumber *y = [NSNumber numberWithInt:0];
		NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
		self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
	}
	// 4 - Create number formatter, if needed
    //	static NSNumberFormatter *formatter = nil;
    //	if (!formatter) {
    //		formatter = [[NSNumberFormatter alloc] init];
    //		[formatter setMaximumFractionDigits:2];
    //	}
	// 5 - Create text layer for annotation
    int hr = price.intValue/3600;
    int min = (price.intValue - hr*3600)/60;
    int sec = (price.intValue - hr*3600 - min*60);
    NSString* leadZero;
    NSString* leadZeroS;
    if (min < 10) {
        leadZero = @"0";
    } else leadZero = @"";
    if (sec < 10) {
        leadZeroS = @"0";
    } else leadZeroS = @"";
    
	NSString *priceValue = [NSString stringWithFormat:@"%d:%@%d:%@%d", hr, leadZero, min,leadZeroS, sec];//[formatter stringFromNumber:price];
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
	self.priceAnnotation.contentLayer = textLayer;
    NSLog(@"attemtped content layer");
	// 6 - Get plot index based on identifier
	NSInteger plotIndex = 0;
    //	if ([plot.identifier isEqual:CPDTickerSymbolAAPL] == YES) {
    //		plotIndex = 0;
    //	} else if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
    //		plotIndex = 1;
    //	} else if ([plot.identifier isEqual:CPDTickerSymbolMSFT] == YES) {
    //		plotIndex = 2;
    //	} else
    if ([plot.identifier isEqual:CPDActivity] == YES) {
		plotIndex = 3;
	}
	// 7 - Get the anchor point for annotation
	CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth) - .3;
	NSNumber *anchorX = [NSNumber numberWithFloat:x];
    CGFloat y = [price floatValue] + temp.goalTime.intValue*60*.04;
	NSNumber *anchorY = [NSNumber numberWithFloat:y];
	self.priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
	// 8 - Add the annotation
	[plot.graph.plotAreaFrame.plotArea addAnnotation:self.priceAnnotation];
}

@end

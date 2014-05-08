/*
 * Copyright (c) 2010-2012 Matias Muhonen <mmu@iki.fi>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "DayViewExampleController.h"
#import "MAEvent.h"
#import "MAEventKitDataSource.h"
#import "Activity.h"

// Uncomment the following line to use the built in calendar as a source for events:
//#define USE_EVENTKIT_DATA_SOURCE 1

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface DayViewExampleController(PrivateMethods)
@property (readonly) MAEvent *event;
@property (readonly) MAEventKitDataSource *eventKitDataSource;
@end

@implementation DayViewExampleController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (DSAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (DSAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

- (void)viewDidLoad {
	/* The default is not to autoscroll, so let's override the default here */
	//dayView.autoScrollToFirstEvent = YES;
    
}

/* Implementation for the MADayViewDataSource protocol */

static NSDate *date = nil;

#ifdef USE_EVENTKIT_DATA_SOURCE

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
    return [self.eventKitDataSource dayView:dayView eventsForDate:startDate];
}

#else
- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
	date = startDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd";
    NSString *currentDay = [dateFormatter stringFromDate: date];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(int j = 0; j < self.appDelegate.allActivities.count; j++){
        
        MAEvent *event = [[MAEvent alloc] init];
        Activity *temp = self.appDelegate.allActivities[j];
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        event.backgroundColor = color;
        event.textColor = [UIColor whiteColor];
        event.allDay = NO;
        event.title = [temp name];
        
        
        NSString *prevDays = temp.previousDays;
        NSArray *tokenized = [prevDays componentsSeparatedByString:@","];
        
        
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
        dateFormatter2.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
        
        
        if (tokenized != nil)
        {
            int check = 0;
            NSDate *tempDate = [dateFormatter2 dateFromString:[tokenized objectAtIndex:0]];
            for (int i = 0; i < tokenized.count-1; i+=2)
            {
                if ([tokenized objectAtIndex:i] != Nil){
                    //get the day of this logged
                    NSDate *logDate = [dateFormatter2 dateFromString:[tokenized objectAtIndex:i]];
                    
                    
                    NSString *day = [dateFormatter stringFromDate: logDate];
                    if([currentDay isEqual:day]){
                        if(check == 0){
                            tempDate = [dateFormatter2 dateFromString:[tokenized objectAtIndex:i]];
                            check = 1;
                            event.start = logDate;
                            int loggedTime = [[tokenized objectAtIndex:i+1] integerValue];
                            event.end = [NSDate dateWithTimeInterval:loggedTime sinceDate:logDate];
                            [arr addObject:event];
                            NSLog(@"TEST %d", loggedTime);
                        }
                        else{
                            NSTimeInterval difference = [logDate timeIntervalSinceDate:tempDate];
                            
                            if(difference > 1800 || i == 0){
                                tempDate = [dateFormatter2 dateFromString:[tokenized objectAtIndex:i]];
                                event.start = logDate;
                                int loggedTime = [[tokenized objectAtIndex:i+1] integerValue];
                                event.end = [NSDate dateWithTimeInterval:loggedTime sinceDate:logDate];
                                [arr addObject:event];
                                NSLog(@"TEST %d", loggedTime);
                            }
                        }
                        
                    }
                    
                }
            }
        }
        
    }
    
    NSArray *array = [arr copy];
	return array;
}
#endif

/*
 - (MAEvent *)event {
 static int counter;
 static BOOL flag;
 
 NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
 
 [dict setObject:[NSString stringWithFormat:@"number %i", counter++] forKey:@"test"];
 
 unsigned int r = arc4random() % 24;
 int rr = arc4random() % 3;
 
 MAEvent *event = [[MAEvent alloc] init];
 event.backgroundColor = ((flag = !flag) ? [UIColor purpleColor] : [UIColor brownColor]);
 event.textColor = [UIColor whiteColor];
 event.allDay = NO;
 event.userInfo = dict;
 
 if (rr == 0) {
 event.title = @"Event lorem ipsum es dolor test. This a long text, which should clip the event view bounds.";
 } else if (rr == 1) {
 event.title = @"Foobar.";
 } else {
 event.title = @"Dolor test.";
 }
 
 NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:date];
 [components setHour:r];
 [components setMinute:0];
 [components setSecond:0];
 
 event.start = [CURRENT_CALENDAR dateFromComponents:components];
 
 [components setHour:r+rr];
 [components setMinute:0];
 
 event.end = [CURRENT_CALENDAR dateFromComponents:components];
 
 return event;
 }
 */

- (MAEventKitDataSource *)eventKitDataSource {
    if (!_eventKitDataSource) {
        _eventKitDataSource = [[MAEventKitDataSource alloc] init];
    }
    return _eventKitDataSource;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}




@end

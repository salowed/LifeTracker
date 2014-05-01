//
//  DSSelectedActitvityViewController.h
//  LifeTracker
//
//  Created by Daniel Salowe on 4/9/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSSelectedActitvityViewController : UIViewController<CPTBarPlotDataSource, CPTBarPlotDelegate>
@property (strong, nonatomic) NSString *activityTitle;

@end

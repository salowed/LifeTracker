//
//  Activity.h
//  LifeTracker
//
//  Created by Daniel Salowe on 4/8/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * aboveBelow;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) NSString * active;
@property (nonatomic, retain) NSString * completed;

@end
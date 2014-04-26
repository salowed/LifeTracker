//
//  Activity.h
//  LifeTracker
//
//  Created by Daniel Salowe on 4/26/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Activity : NSManagedObject

@property (nonatomic, retain) NSString * completed;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * previousDays;
@property (nonatomic, retain) NSString * goalTime;
@property (nonatomic, retain) NSString * type;

@end

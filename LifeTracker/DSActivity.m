//
//  DSActivity.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/8/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSActivity.h"

@implementation DSActivity

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init]) {
        _name = [decoder decodeObjectForKey:@"name"];
        _type = [decoder decodeObjectForKey:@"type"];
        _goalTime = [decoder decodeObjectForKey:@"goalTime"];
        _timerRunning = [decoder decodeObjectForKey:@"timerRunning"];
        _longitude = [decoder decodeObjectForKey:@"longitude"];
        _longitude = [decoder decodeObjectForKey:@"latitude"];
        _previousDays = [decoder decodeObjectForKey:@"previousDays"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeObject:_goalTime forKey:@"goalTime"];
    [coder encodeObject:_timerRunning forKey:@"timerRunning"];
    [coder encodeObject:_longitude forKey:@"longitude"];
    [coder encodeObject:_longitude forKey:@"latitude"];
    [coder encodeObject:_previousDays forKey:@"previousDays"];
    
}


@end

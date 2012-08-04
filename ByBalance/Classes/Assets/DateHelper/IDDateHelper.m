//
//  IDDateHelper.m
//  idevs date helper
//
//  Created by Andrew Sinkevitch on 30.3.12.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "IDDateHelper.h"

@implementation IDDateHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(IDDateHelper);

#pragma mark - ObjectLife

- (id) init
{
    self = [super init];
    if (self)
    {
        formatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [formatter release];
    [super dealloc];
}

#pragma mark - Public

- (NSString *) dateToMysqlDate:(NSDate *)date
{
	if (date == nil) return @"";

	[formatter setDateFormat:@"yyyy-MM-dd"];
	return [formatter stringFromDate:date];
}

- (NSString *) dateToMysqlDateTime:(NSDate *)date
{
	if (date == nil) return @"";
	
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return [formatter stringFromDate:date];
}

- (NSDate *) mysqlDateToDate:(NSString *)strDate
{
    if (strDate == nil) return nil;
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:strDate];
}

- (NSDate *) mysqlDateTimeToDate:(NSString *)strDate
{
    if (strDate == nil) return nil;
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:strDate];
}

- (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day 
{
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
} 

- (NSString *) timeIntervalToPlayback:(NSTimeInterval) interval
{
    if (interval < 0) return @"";
    if (interval == 0) return  @"00:00";
    
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    [formatter setDateFormat:@"mm:ss"];
	return [formatter stringFromDate:date];
    
    /*int mins, secs;
    
    mins = interval / 60;
    secs = interval - (mins * 60);
    
    return [NSString stringWithFormat:@"", mins, secs];
     */
    
}

@end

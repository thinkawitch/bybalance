//
//  IDDateHelper.m
//  idevs date helper
//
//  Created by Andrew Sinkevitch on 30.3.12.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "IDDateHelper.h"

@implementation IDDateHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(IDDateHelper, sharedIDDateHelper);

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
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
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

//
- (NSString *) formatAsMonthDay:(NSDate *)date
{
    [formatter setDateFormat:@"dd MMM"];
    return [formatter stringFromDate:date];
}

- (NSString *) formatAsMonthDayTime:(NSDate *)date
{
    [formatter setDateFormat:@"dd MMM"];
    
    NSString * part1 = [formatter stringFromDate:date];
    NSString * part2 = [NSDateFormatter localizedStringFromDate:date
                                                      dateStyle:NSDateFormatterNoStyle
                                                      timeStyle:NSDateFormatterShortStyle];
    
    return [NSString stringWithFormat:@"%@ %@", part1, part2];
}

- (NSString *) formatSmartAsDayOrTime:(NSDate *)date
{
    NSDate * now =[NSDate date];
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents * comp1 = [calendar components:unitFlags fromDate:now];
    NSDateComponents * comp2 = [calendar components:unitFlags fromDate:date];
    
    BOOL sameDay = ([comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year]);
    
    if (sameDay)
    {
        return [NSDateFormatter localizedStringFromDate:date
                                              dateStyle:NSDateFormatterNoStyle
                                              timeStyle:NSDateFormatterShortStyle];
    }
    else
    {
        return [self formatAsMonthDay:date];
    }
}

@end

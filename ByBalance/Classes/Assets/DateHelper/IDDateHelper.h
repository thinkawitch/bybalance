//
//  IDDateHelper.h
//  idevs date helper
//
//  Created by Andrew Sinkevitch on 30.3.12.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDDateHelper : NSObject
{
@private
    NSDateFormatter * formatter;
}

+ (IDDateHelper *) sharedIDDateHelper;

- (NSString *) dateToMysqlDate:(NSDate *)date;
- (NSString *) dateToMysqlDateTime:(NSDate *)date;

- (NSDate *) mysqlDateToDate:(NSString *)strDate;
- (NSDate *) mysqlDateTimeToDate:(NSString *)strDate;

- (NSDate *) dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

- (NSString *) timeIntervalToPlayback:(NSTimeInterval) interval;

//
- (NSString *) formatAsMonthDay:(NSDate *)date;
- (NSString *) formatAsMonthDayTime:(NSDate *)date;
- (NSString *) formatSmartAsDayOrTime:(NSDate *)date;


@end

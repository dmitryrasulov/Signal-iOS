//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "DateUtil.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalCoreKit/NSString+OWS.h>
#import <SignalMessaging/SignalMessaging-Swift.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const DATE_FORMAT_WEEKDAY = @"EEEE";

@implementation DateUtil

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
    });
    return formatter;
}

+ (NSDateFormatter *)dateBreakRelativeDateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.doesRelativeDateFormatting = YES;
    });

    return formatter;
}

+ (NSDateFormatter *)dateBreakThisWeekDateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        // "Monday", "Tuesday", etc.
        formatter.dateFormat = @"EEEE";
    });

    return formatter;
}

+ (NSDateFormatter *)dateBreakThisYearDateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        // Tue, Jun 6
        [formatter setLocalizedDateFormatFromTemplate:@"EE, MMM d"];
    });

    return formatter;
}

+ (NSDateFormatter *)dateBreakOldDateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.doesRelativeDateFormatting = YES;
    });

    return formatter;
}

+ (NSDateFormatter *)weekdayFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:DATE_FORMAT_WEEKDAY];
    });
    return formatter;
}

+ (NSDateFormatter *)timeFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterNoStyle];
    });
    return formatter;
}

+ (NSDateFormatter *)monthAndDayFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setLocalizedDateFormatFromTemplate: @"MMM d"];
    });
    return formatter;
}

+ (NSDateFormatter *)shortDayOfWeekFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        formatter.dateFormat = @"E";
    });
    return formatter;
}

+ (BOOL)dateIsOlderThanToday:(NSDate *)date
{
    return [self dateIsOlderThanToday:date now:[NSDate date]];
}

+ (BOOL)dateIsOlderThanToday:(NSDate *)date now:(NSDate *)now
{
    NSInteger dayDifference = [self daysFromFirstDate:date toSecondDate:now];
    return dayDifference > 0;
}

+ (BOOL)dateIsOlderThanYesterday:(NSDate *)date
{
    return [self dateIsOlderThanYesterday:date now:[NSDate date]];
}

+ (BOOL)dateIsOlderThanYesterday:(NSDate *)date now:(NSDate *)now
{
    NSInteger dayDifference = [self daysFromFirstDate:date toSecondDate:now];
    return dayDifference > 1;
}

+ (BOOL)dateIsOlderThanOneWeek:(NSDate *)date
{
    return [self dateIsOlderThanOneWeek:date now:[NSDate date]];
}

+ (BOOL)dateIsOlderThanOneWeek:(NSDate *)date now:(NSDate *)now
{
    NSInteger dayDifference = [self daysFromFirstDate:date toSecondDate:now];
    return dayDifference > 6;
}

+ (BOOL)dateIsToday:(NSDate *)date
{
    return [self dateIsToday:date now:[NSDate date]];
}

+ (BOOL)dateIsToday:(NSDate *)date now:(NSDate *)now
{
    NSInteger dayDifference = [self daysFromFirstDate:date toSecondDate:now];
    return dayDifference == 0;
}

+ (BOOL)dateIsThisYear:(NSDate *)date
{
    return [self dateIsThisYear:date now:[NSDate date]];
}

+ (BOOL)dateIsThisYear:(NSDate *)date now:(NSDate *)now
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return (
        [calendar component:NSCalendarUnitYear fromDate:date] == [calendar component:NSCalendarUnitYear fromDate:now]);
}

+ (BOOL)dateIsYesterday:(NSDate *)date
{
    return [self dateIsYesterday:date now:[NSDate date]];
}

+ (BOOL)dateIsYesterday:(NSDate *)date now:(NSDate *)now
{
    NSInteger dayDifference = [self daysFromFirstDate:date toSecondDate:now];
    return dayDifference == 1;
}

// Returns the difference in days, ignoring hours, minutes, seconds.
// If both dates are the same date, returns 0.
// If firstDate is a day before secondDate, returns 1.
//
// Note: Assumes both dates use the "current" calendar.
+ (NSInteger)daysFromFirstDate:(NSDate *)firstDate toSecondDate:(NSDate *)secondDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit units = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:units fromDate:firstDate];
    NSDateComponents *comp2 = [calendar components:units fromDate:secondDate];
    [comp1 setHour:12];
    [comp2 setHour:12];
    NSDate *date1 = [calendar dateFromComponents:comp1];
    NSDate *date2 = [calendar dateFromComponents:comp2];
    return [[calendar components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0] day];
}

// Returns the difference in years, ignoring shorter units of time.
// If both dates fall in the same year, returns 0.
// If firstDate is from the year before secondDate, returns 1.
//
// Note: Assumes both dates use the "current" calendar.
+ (NSInteger)yearsFromFirstDate:(NSDate *)firstDate toSecondDate:(NSDate *)secondDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit units = NSCalendarUnitEra | NSCalendarUnitYear;
    NSDateComponents *comp1 = [calendar components:units fromDate:firstDate];
    NSDateComponents *comp2 = [calendar components:units fromDate:secondDate];
    [comp1 setHour:12];
    [comp2 setHour:12];
    NSDate *date1 = [calendar dateFromComponents:comp1];
    NSDate *date2 = [calendar dateFromComponents:comp2];
    return [[calendar components:NSCalendarUnitYear fromDate:date1 toDate:date2 options:0] year];
}

+ (NSString *)formatPastTimestampRelativeToNow:(uint64_t)pastTimestamp
{
    OWSCAssertDebug(pastTimestamp > 0);

    uint64_t nowTimestamp = [NSDate ows_millisecondTimeStamp];
    BOOL isFutureTimestamp = pastTimestamp >= nowTimestamp;

    NSDate *pastDate = [NSDate ows_dateWithMillisecondsSince1970:pastTimestamp];
    NSString *dateString;
    if (isFutureTimestamp || [self dateIsToday:pastDate]) {
        dateString = NSLocalizedString(@"DATE_TODAY", @"The current day.");
    } else if ([self dateIsYesterday:pastDate]) {
        dateString = NSLocalizedString(@"DATE_YESTERDAY", @"The day before today.");
    } else {
        dateString = [[self dateFormatter] stringFromDate:pastDate];
    }
    return [[dateString stringByAppendingString:@" "]
        stringByAppendingString:[[self timeFormatter] stringFromDate:pastDate]];
}

+ (NSString *)formatTimestampShort:(uint64_t)timestamp
{
    return [self formatDateShort:[NSDate ows_dateWithMillisecondsSince1970:timestamp]];
}

+ (NSString *)formatDateShort:(NSDate *)date
{
    OWSAssertDebug(date);

    NSDate *now = [NSDate date];
    NSInteger dayDifference = [self daysFromFirstDate:date toSecondDate:now];
    BOOL dateIsOlderThanToday = dayDifference > 0;
    BOOL dateIsOlderThanOneWeek = dayDifference > 6;

    NSString *dateTimeString;
    if (![DateUtil dateIsThisYear:date]) {
        dateTimeString = [[DateUtil dateFormatter] stringFromDate:date];
    } else if (dateIsOlderThanOneWeek) {
        dateTimeString = [[DateUtil monthAndDayFormatter] stringFromDate:date];
    } else if (dateIsOlderThanToday) {
        dateTimeString = [[DateUtil shortDayOfWeekFormatter] stringFromDate:date];
    } else {
        dateTimeString = [[DateUtil timeFormatter] stringFromDate:date];
    }

    return dateTimeString;
}

+ (NSString *)formatDateForConversationDateBreaks:(NSDate *)date
{
    OWSAssertDebug(date);

    if (![self dateIsThisYear:date]) {
        // last year formatter: Nov 11, 2017
        return [self.dateBreakOldDateFormatter stringFromDate:date];
    } else if ([self dateIsOlderThanOneWeek:date]) {
        // this year formatter: Tue, Jun 23
        return [self.dateBreakThisYearDateFormatter stringFromDate:date];
    } else if ([self dateIsOlderThanYesterday:date]) {
        // day of week formatter: Thursday
        return [self.dateBreakThisWeekDateFormatter stringFromDate:date];
    } else {
        // relative format: Today / Yesterday
        return [self.dateBreakRelativeDateFormatter stringFromDate:date];
    }
}

+ (NSString *)formatTimestampAsTime:(uint64_t)timestamp
{
    return [self formatDateAsTime:[NSDate ows_dateWithMillisecondsSince1970:timestamp]];
}

+ (NSString *)formatDateAsTime:(NSDate *)date
{
    OWSAssertDebug(date);

    NSString *dateTimeString = [[DateUtil timeFormatter] stringFromDate:date];
    return dateTimeString;
}

+ (NSString *)formatTimestampAsDate:(uint64_t)timestamp
{
    return [self formatDateAsDate:[NSDate ows_dateWithMillisecondsSince1970:timestamp]];
}

+ (NSString *)formatDateAsDate:(NSDate *)date
{
    OWSAssertDebug(date);

    NSString *dateTimeString;

    NSInteger yearsDiff = [self yearsFromFirstDate:date toSecondDate:[NSDate new]];
    if (yearsDiff > 0) {
        dateTimeString = [[DateUtil otherYearMessageFormatter] stringFromDate:date];
    } else {
        dateTimeString = [[DateUtil thisYearMessageFormatter] stringFromDate:date];
    }

    return dateTimeString;
}

+ (NSDateFormatter *)otherYearMessageFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setLocalizedDateFormatFromTemplate:@"MMM d, yyyy"];
    });
    return formatter;
}

+ (NSDateFormatter *)thisYearMessageFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setLocalizedDateFormatFromTemplate:@"MMM d"];
    });
    return formatter;
}

+ (NSDateFormatter *)thisWeekMessageFormatterShort
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"E"];
    });
    return formatter;
}

+ (NSDateFormatter *)thisWeekMessageFormatterLong
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"EEEE"];
    });
    return formatter;
}

+ (NSString *)formatMessageTimestamp:(uint64_t)timestamp
                 shouldUseLongFormat:(BOOL)shouldUseLongFormat
{
    NSDate *date = [NSDate ows_dateWithMillisecondsSince1970:timestamp];
    uint64_t nowTimestamp = [NSDate ows_millisecondTimeStamp];
    NSDate *nowDate = [NSDate ows_dateWithMillisecondsSince1970:nowTimestamp];

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *relativeDiffComponents =
        [calendar components:NSCalendarUnitMinute | NSCalendarUnitHour fromDate:date toDate:nowDate options:0];

    // Note: we are careful to treat "future" dates as "now".
    NSInteger yearsDiff = [self yearsFromFirstDate:date toSecondDate:nowDate];
    NSInteger daysDiff = [self daysFromFirstDate:date toSecondDate:nowDate];
    NSInteger hoursDiff = MAX(0, [relativeDiffComponents hour]);
    NSInteger minutesDiff = MAX(0, [relativeDiffComponents minute]);

    if (yearsDiff > 0) {
        // "Long date" + locale-specific "short" time format.
        NSString *dayOfWeek = [self.otherYearMessageFormatter stringFromDate:date];
        NSString *formattedTime = [[self timeFormatter] stringFromDate:date];
        return [[dayOfWeek stringByAppendingString:@" "] stringByAppendingString:formattedTime];

    } else if (daysDiff >= 7) {
        // "Short date" + locale-specific "short" time format.
        NSString *dayOfWeek = [self.thisYearMessageFormatter stringFromDate:date];
        NSString *formattedTime = [[self timeFormatter] stringFromDate:date];
        return [[dayOfWeek stringByAppendingString:@" "] stringByAppendingString:formattedTime];

    } else if (daysDiff > 0) {
        // "Day of week" + locale-specific "short" time format.
        NSDateFormatter *thisWeekMessageFormatter = (shouldUseLongFormat
                                                     ? self.thisWeekMessageFormatterLong
                                                     : self.thisWeekMessageFormatterShort);
        NSString *dayOfWeek = [thisWeekMessageFormatter stringFromDate:date];
        NSString *formattedTime = [[self timeFormatter] stringFromDate:date];
        return [[dayOfWeek stringByAppendingString:@" "] stringByAppendingString:formattedTime];

    } else if (hoursDiff > 0) {
        if (shouldUseLongFormat && hoursDiff == 1) {
            // Long format has a distinction between singular and plural
            return NSLocalizedString(@"DATE_ONE_HOUR_AGO_LONG", @"Full string for a relative time of one hour ago.");
        }

        NSString *shortFormat = NSLocalizedString(@"DATE_HOURS_AGO_FORMAT", @"Format string for a relative time, expressed as a certain number of hours in the past. Embeds {{The number of hours}}.");
        NSString *longFormat = NSLocalizedString(@"DATE_HOURS_AGO_LONG_FORMAT", @"Full format string for a relative time, expressed as a certain number of hours in the past. Embeds {{The number of hours}}.");

        NSString *formatString = shouldUseLongFormat ? longFormat : shortFormat;
        NSString *hoursString = [OWSFormat formatInt:hoursDiff];
        return [NSString stringWithFormat:formatString, hoursString];

    } else if (minutesDiff > 0) {
        if (shouldUseLongFormat && minutesDiff == 1) {
            // Long format has a distinction between singular and plural
            return NSLocalizedString(@"DATE_ONE_MINUTE_AGO_LONG", @"Full string for a relative time of one minute ago.");
        }

        NSString *shortFormat = NSLocalizedString(@"DATE_MINUTES_AGO_FORMAT", @"Format string for a relative time, expressed as a certain number of minutes in the past. Embeds {{The number of minutes}}.");
        NSString *longFormat = NSLocalizedString(@"DATE_MINUTES_AGO_LONG_FORMAT", @"Full format string for a relative time, expressed as a certain number of minutes in the past. Embeds {{The number of minutes}}.");

        NSString *formatString = shouldUseLongFormat ? longFormat : shortFormat;
        NSString *minutesString = [OWSFormat formatInt:minutesDiff];
        return [NSString stringWithFormat:formatString, minutesString];

    } else {
        return NSLocalizedString(@"DATE_NOW", @"The present; the current time.");
    }
}

+ (BOOL)isTimestampFromLastHour:(uint64_t)timestamp
{
    NSDate *date = [NSDate ows_dateWithMillisecondsSince1970:timestamp];
    uint64_t nowTimestamp = [NSDate ows_millisecondTimeStamp];
    NSDate *nowDate = [NSDate ows_dateWithMillisecondsSince1970:nowTimestamp];

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSInteger hoursDiff
        = MAX(0, [[calendar components:NSCalendarUnitHour fromDate:date toDate:nowDate options:0] hour]);
    return hoursDiff < 1;
}

+ (NSString *)exemplaryNowTimeFormat
{
    return NSLocalizedString(@"DATE_NOW", @"The present; the current time.");
}

+ (NSString *)exemplaryMinutesTimeFormat
{
    NSString *minutesString = [OWSFormat formatInt:59];
    return [NSString stringWithFormat:NSLocalizedString(@"DATE_MINUTES_AGO_FORMAT",
                                          @"Format string for a relative time, expressed as a certain number of "
                                          @"minutes in the past. Embeds {{The number of minutes}}."),
                     minutesString]
        .uppercaseString;
}

+ (BOOL)isSameDayWithTimestamp:(uint64_t)timestamp1 timestamp:(uint64_t)timestamp2
{
    return [self isSameDayWithDate:[NSDate ows_dateWithMillisecondsSince1970:timestamp1]
                              date:[NSDate ows_dateWithMillisecondsSince1970:timestamp2]];
}

+ (BOOL)isSameDayWithDate:(NSDate *)date1 date:(NSDate *)date2
{
    NSInteger dayDifference = [self daysFromFirstDate:date1 toSecondDate:date2];
    return dayDifference == 0;
}

@end

NS_ASSUME_NONNULL_END

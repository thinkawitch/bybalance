//
//  IDPrimitiveHelper.m
//  idevs primitive objects helper
//
//  Created by Andrew Sinkevitch on 30.3.12.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "IDPrimitiveHelper.h"

@implementation IDPrimitiveHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(IDPrimitiveHelper, sharedIDPrimitiveHelper);

- (NSString *) stringValue:(id) aValue
{
	if ([aValue isKindOfClass:[NSString class]])
	{
		return aValue;
	}
	return @"";
}

- (NSString *) trimmedString:(id) value
{
    if (![value isKindOfClass:[NSString class]]) return @"";
    
    return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSNumber *) numberIntegerValue:(id) aValue
{
    if ([aValue isKindOfClass:[NSNumber class]])
	{
		return aValue;
	}
	else if ([aValue isKindOfClass:[NSString class]])
	{
		return [NSNumber numberWithInteger:[self integerValue:aValue]];
	}
	return [NSNumber numberWithInt:0];
}

- (NSNumber *) numberFloatValue:(id) aValue
{
    if ([aValue isKindOfClass:[NSNumber class]])
	{
		return aValue;
	}
	else if ([aValue isKindOfClass:[NSString class]])
	{
		return [NSNumber numberWithFloat:[self floatValue:aValue]];
	}
	return [NSNumber numberWithInt:0];
}

- (NSDecimalNumber *) numberDecimalValue:(id) aValue
{
    if ([aValue isKindOfClass:[NSDecimalNumber class]])
	{
		return aValue;
	}
    else if ([aValue isKindOfClass:[NSNumber class]])
    {
        return [NSDecimalNumber decimalNumberWithDecimal:[aValue decimalValue]];
    }
	else if ([aValue isKindOfClass:[NSString class]])
	{
		if ([aValue length])
        {
            NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:aValue];
            if (![num isEqualToNumber:[NSDecimalNumber notANumber]]) return num;
        }
	}
	return [[NSDecimalNumber alloc] initWithInt:0];
}

- (NSInteger) integerValue:(id) aValue
{
	if ([aValue isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber *) aValue integerValue];
	}
	else if ([aValue isKindOfClass:[NSString class]])
	{
		return [(NSString *) aValue integerValue];
	}
	return 0;
}

- (CGFloat) floatValue:(id) aValue
{
	if ([aValue isKindOfClass:[NSNumber class]])
	{
		return [(NSNumber *) aValue floatValue];
	}
	else if ([aValue isKindOfClass:[NSString class]])
	{
		return [(NSString *) aValue floatValue];
	}
	return 0.f;
}

//
- (BOOL) stringIsNumeric:(NSString *) str
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    return !!number; // If the string is not numeric, number will be nil
}

@end

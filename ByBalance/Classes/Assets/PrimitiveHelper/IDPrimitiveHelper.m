//
//  IDPrimitiveHelper.m
//  idevs primitive objects helper
//
//  Created by Andrew Sinkevitch on 30.3.12.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "IDPrimitiveHelper.h"

@implementation IDPrimitiveHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(IDPrimitiveHelper);

- (NSString *) stringValue:(id) aValue
{
	if ([aValue isKindOfClass:[NSString class]])
	{
		return aValue;
	}
	return [NSString stringWithString:@""];
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
            return [NSDecimalNumber decimalNumberWithString:aValue];
        }
	}
	return [NSDecimalNumber decimalNumberWithString:@"0"];
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

@end

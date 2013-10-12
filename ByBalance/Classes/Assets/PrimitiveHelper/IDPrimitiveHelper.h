//
//  IDPrimitiveHelper.h
//  idevs primitive objects helper
//
//  Created by Andrew Sinkevitch on 30.3.12.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDPrimitiveHelper : NSObject

+ (IDPrimitiveHelper *) sharedIDPrimitiveHelper;

- (NSString *) stringValue:(id) aValue;

- (NSNumber *) numberIntegerValue:(id) aValue;
- (NSNumber *) numberFloatValue:(id) aValue;
- (NSDecimalNumber *) numberDecimalValue:(id) aValue;

- (NSInteger) integerValue:(id) aValue;
- (CGFloat) floatValue:(id) aValue;

@end

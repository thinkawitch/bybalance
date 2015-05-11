//
//  AppGroupMacros.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 11/05/15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#ifndef ByBalance_AppGroupMacros_h
#define ByBalance_AppGroupMacros_h

#import "AppGroupSettings.h"
#import "IDPrimitiveHelper.h"
#import "IDDateHelper.h"

#define GROUP_SETTINGS [AppGroupSettings sharedAppGroupSettings]
#define PRIMITIVE_HELPER [IDPrimitiveHelper sharedIDPrimitiveHelper]
#define DATE_HELPER [IDDateHelper sharedIDDateHelper]

#endif

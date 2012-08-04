//
//  MacrosAndDefines.h
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "AppSettings.h"
#import "AppContext.h"
#import "IDDateHelper.h"
#import "IDPrimitiveHelper.h"

#define SETTINGS [AppSettings sharedAppSettings]
#define APP_CONTEXT [AppContext sharedAppContext]
#define DATE_HELPER [IDDateHelper sharedIDDateHelper]
#define PRIMITIVE_HELPER [IDPrimitiveHelper sharedIDPrimitiveHelper]
#define NEWVCFROMNIB(name) [[name alloc] initWithNibName:NSStringFromClass([name class]) bundle:nil]

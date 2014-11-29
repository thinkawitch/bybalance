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
#import "BBBalanceChecker.h"
#import "BBBasesManager.h"

#define SETTINGS [AppSettings sharedAppSettings]
#define APP_CONTEXT [AppContext sharedAppContext]
#define DATE_HELPER [IDDateHelper sharedIDDateHelper]
#define PRIMITIVE_HELPER [IDPrimitiveHelper sharedIDPrimitiveHelper]
#define BALANCE_CHECKER [BBBalanceChecker sharedBBBalanceChecker]
#define BASES_MANAGER [BBBasesManager sharedBBBasesManager]

#define NEWVCFROMNIB(name) [[name alloc] initWithNibName:NSStringFromClass([name class]) bundle:nil]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

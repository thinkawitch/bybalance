//
//  AppGlobal.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 15.06.12.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "AppGlobal.h"

#pragma mark - Text and Messages
//
NSString * const kAppNoInternetAlertTitle = @"";
NSString * const kAppNoInternetAlertText =  @"Нет подключения к интернет"; //@"You have no internet connection";
//
NSString * const kAppEmailRegexp = @"^([\\w\\-\\.]+)@((\\[([0-9]{1,3}\\.){3}[0-9]{1,3}\\])|(([\\w\\-]+\\.)+)([a-zA-Z]{2,4}))$";

#pragma mark - Account types
//


#pragma mark - Dictionary keys
//
NSString * const kDictKeyAccount = @"account";
NSString * const kDictKeyBaseItem = @"baseItem";
NSString * const kDictKeyLoaderInfo = @"loaderInfo";
NSString * const kDictKeyHtml = @"html";

#pragma mark - Notifications
//
NSString * const kNotificationOnAccountsListUpdated = @"ON_ACCOUNTS_LIST_UPDATED";
NSString * const kNotificationOnBalanceCheckStart = @"ON_BALANCE_CHECK_START";
NSString * const kNotificationOnBalanceCheckProgress = @"ON_BALANCE_CHECK_PROGRESS";
NSString * const kNotificationOnBalanceChecked = @"ON_BALANCE_CHECKED";
NSString * const kNotificationOnBalanceCheckStop = @"ON_BALANCE_CHECK_STOP";

#pragma mark - Cells sizes
//
CGFloat const kHomeCellHeight = 73.f + 1.f;
CGFloat const kAccountTypeCellHeight = 73.f + 1.f;
CGFloat const kBalanceHistoryCellHeight = 30.f + 1.f;
CGFloat const kAboutCellHeight = 39.f + 1.f;

//
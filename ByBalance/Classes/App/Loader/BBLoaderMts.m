//
//  BBLoaderMts.m
//  ByBalance
//
//  Created by Andrew Sinkevitch on 01/09/2012.
//  Copyright (c) 2012 sinkevitch.name. All rights reserved.
//

#import "BBLoaderMts.h"

@implementation BBLoaderMts

- (void) login
{
    NSURL * url = [NSURL URLWithString:item.loginUrl];
    
	NSLog(@"url: %@", url);
    ASIFormDataRequest * request = [self requestWithURL:url];
    
    request.delegate = self;
    //request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:kServerCommandGetAllVideos], nil] 
    //                                               forKeys:[NSArray arrayWithObjects:kDictKeyApiServerCommandType, nil]];
    
    [request addRequestHeader:@"Referer" value:item.loginUrl];
    [request setPostValue:@"/wEPDwUKMTU5Mzk3MTA0NA9kFgJmD2QWAgICDxYCHgVjbGFzcwUFbG9naW4WAgICD2QWBgIBDw8WAh4JTWF4TGVuZ3RoAglkZAIDDw8WAh4DS0VZBSJjdGwwMF9NYWluQ29udGVudF9jYXB0Y2hhMzA2MjI5NzAwZGQCBQ8PFgYeBFRleHRlHghDc3NDbGFzcwUGc3VibWl0HgRfIVNCAgJkZGRq1lFdf8Isy5ch/s7SUIwpqQoOoA==" forKey:@"__VIEWSTATE"];
    [request setPostValue:item.username forKey:@"ctl00$MainContent$tbPhoneNumber"];
    [request setPostValue:item.password forKey:@"ctl00$MainContent$tbPassword"];
    [request setPostValue:@"Войти" forKey:@"ctl00$MainContent$btnEnter"];
    
    
    [request startAsynchronous];
}

- (void) getDetails
{
    
}

@end

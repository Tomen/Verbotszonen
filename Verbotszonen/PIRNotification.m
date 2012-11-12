//
//  PIRNotification.m
//  Verbotszonen
//
//  Created by tomen on 12.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRNotification.h"

@implementation PIRNotification

-(id)initWithDict:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        self.message = dict[@"message"];
        self.timestamp = [NSDate dateWithTimeIntervalSince1970:((NSNumber *)dict[@"timestamp"]).intValue];
    }
    return self;
}

+(void)scheduleNotifications:(NSArray *)notifications
{
    UIApplication *application = [UIApplication sharedApplication];
    [application cancelAllLocalNotifications];
    
    for (PIRNotification *notification in notifications) {
        //dont show notifications that lie in the past
        if ([notification.timestamp compare:[NSDate date]] != NSOrderedDescending) {
            continue;
        }
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = notification.timestamp;
        localNotification.alertBody = notification.message;
        [application scheduleLocalNotification:localNotification];
    }
}

@end

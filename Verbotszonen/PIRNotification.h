//
//  PIRNotification.h
//  Verbotszonen
//
//  Created by tomen on 12.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PIRNotification : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *timestamp;

-(id)initWithDict:(NSDictionary *)dict;
+(void)scheduleNotifications:(NSArray *)notifications; //resets the previous notifications and schedules the list of notifications

@end

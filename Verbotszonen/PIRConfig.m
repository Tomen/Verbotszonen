//
//  PIRConfig.m
//  Verbotszonen
//
//  Created by tomen on 11.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRConfig.h"
#import "PIRDefinitions.h"

@implementation PIRConfig

-(id)initWithDict:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        NSArray *rawZones = dict[@"zones"];
        if (rawZones) {
            NSMutableArray *zones = [NSMutableArray array];
            for (NSDictionary *rawZone in rawZones) {
                PIRZone *zone = [[PIRZone alloc] initWithDict:rawZone];
                if (zone) {
                    [zones addObject:zone];
                }
            }
            self.zones = zones;
        }
    }
    return self;
}

+(void)fetchOnComplete:(void(^)(PIRConfig *config))onComplete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL URLWithString:PIR_URL_CONFIG];
        if (!url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onComplete(nil);
            });
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onComplete(nil);
            });
            return;
        }
        
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            NSLog(@"error while loading config: %@", error.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                onComplete(nil);
            });
            return;
        }
        
        if (!dict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onComplete(nil);
            });
            return;
        }
        
        PIRConfig *config = [[PIRConfig alloc] initWithDict:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            onComplete(config);
        });
    });
}

@end

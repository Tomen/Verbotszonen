//
//  PIRConfig.h
//  Verbotszonen
//
//  Created by tomen on 11.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIRZone.h"

@interface PIRConfig : NSObject

@property (nonatomic, strong) NSArray *zones;

+(void)fetchOnComplete:(void(^)(PIRConfig *config))onComplete;

@end

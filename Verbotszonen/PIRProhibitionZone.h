//
//  PIRProhibitionZone.h
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PIRProhibitionZone : NSObject

+(void)fetchAllProhibitionZonesOnComplete:(void(^)(NSArray *prohibitionZones))onComplete;

@end

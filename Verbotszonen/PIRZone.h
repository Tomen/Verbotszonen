//
//  PIRProhibitionZone.h
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PIRZone : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *gpx;
@property (nonatomic, strong) NSString *description;

-(id)initWithDict:(NSDictionary *)dict;
-(void)fetchPolygonOnComplete:(void(^)(MKPolygon *polygon))onComplete;
-(BOOL)coordinateIsWithinZone:(CLLocationCoordinate2D)coordinate;
+(NSArray *)zonesForCoordinate:(CLLocationCoordinate2D)coordinate fromZones:(NSArray *)zones;

@end

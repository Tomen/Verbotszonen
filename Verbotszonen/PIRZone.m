//
//  PIRProhibitionZone.m
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRZone.h"

@interface PIRZone ()
@property (nonatomic, assign) NSMutableArray *polygons;
@end


//TE: This is my first time parsing xml. Please forgive me :P
@interface PIRProhibitionZoneParser : NSObject<NSXMLParserDelegate>

-(PIRZone *)parseZoneFromData:(NSData *)data;

@property (nonatomic, strong) NSMutableArray *latElements;
@property (nonatomic, strong) NSMutableArray *lonElements;
@property (nonatomic, strong) NSMutableArray *polygons;

@end

@implementation PIRProhibitionZoneParser

-(void)reset
{
    self.latElements = [NSMutableArray array];
    self.lonElements = [NSMutableArray array];
	self.polygons = [NSMutableArray array];
}

-(PIRZone *)parseZoneFromData:(NSData *)data
{
    [self reset];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    PIRZone *zone = [PIRZone new];
    [parser parse];
    
	zone.polygons = self.polygons;
    
    return zone;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
	/* parse all trkseg nodes into different polygons */
    if([elementName isEqualToString:@"trk"]) {
        
		int n = self.latElements.count;
		CLLocationCoordinate2D *coordinates = malloc(n * sizeof(CLLocationCoordinate2D));
        
		for (int i = 0; i < n; i++) {
            
			coordinates[i] = CLLocationCoordinate2DMake(
                                                        [self.latElements[i] doubleValue], [self.lonElements[i] doubleValue] );
		}
        
		MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:n];
		[self.polygons addObject: polygon];
		free(coordinates);
        
		[self.latElements removeAllObjects];
		[self.lonElements removeAllObjects];
	}
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"trkpt"])
    {
        [self.latElements addObject:attributeDict[@"lat"]];
        [self.lonElements addObject:attributeDict[@"lon"]];
    }
}

@end

@implementation PIRZone

-(id)initWithDict:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        self.title = dict[@"title"];
        self.gpx = dict[@"gpx"];
        self.description = dict[@"description"];
    }
    return self;
}

-(void)fetchPolygonOnComplete:(void(^)(MKPolygon *polygon))onComplete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL URLWithString:self.gpx];
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
        
        PIRProhibitionZoneParser *parser = [PIRProhibitionZoneParser new];
        PIRZone *zone = [parser parseZoneFromData:data];
        
        MKPolygon *polygon = [zone.polygons objectAtIndex:0];
        
        /* the first polygon should be the outer bounds */
        if(zone.polygons.count > 1) {
            polygon = [MKPolygon polygonWithPoints:polygon.points
                                             count:polygon.pointCount interiorPolygons:[zone.polygons subarrayWithRange:NSMakeRange(1, zone.polygons.count-1)] ];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            onComplete(polygon);
        });
    });
    
}

@end

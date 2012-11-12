//
//  PIRProhibitionZone.m
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRZone.h"

@interface PIRZone ()
@property (nonatomic, strong) MKPolygon *polygon;
@end


//TE: This is my first time parsing xml. Please forgive me :P
@interface PIRPolygonParser : NSObject<NSXMLParserDelegate>

-(MKPolygon *)parsePolygonFromData:(NSData *)data;

@property (nonatomic, strong) NSMutableArray *latElements;
@property (nonatomic, strong) NSMutableArray *lonElements;
@property (nonatomic, strong) NSMutableArray *polygons;

@end

@implementation PIRPolygonParser

-(void)reset
{
    self.latElements = [NSMutableArray array];
    self.lonElements = [NSMutableArray array];
	self.polygons = [NSMutableArray array];
}

-(MKPolygon *)parsePolygonFromData:(NSData *)data
{
    [self reset];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
        
    MKPolygon *polygon = [self.polygons objectAtIndex:0];
    
    /* the first polygon should be the outer bounds */
    if(self.polygons.count > 1) {
        polygon = [MKPolygon polygonWithPoints:polygon.points
                                         count:polygon.pointCount interiorPolygons:[self.polygons subarrayWithRange:NSMakeRange(1, self.polygons.count-1)] ];
    }
    
    return polygon;
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"trkpt"])
    {
        [self.latElements addObject:attributeDict[@"lat"]];
        [self.lonElements addObject:attributeDict[@"lon"]];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
	/* parse all trkseg nodes into different polygons */
    if([elementName isEqualToString:@"trk"]) {
        
		int n = self.latElements.count;
		CLLocationCoordinate2D *coordinates = malloc(n * sizeof(CLLocationCoordinate2D));
        
		for (int i = 0; i < n; i++) {
            
			coordinates[i] = CLLocationCoordinate2DMake( [self.latElements[i] doubleValue], [self.lonElements[i] doubleValue] );
		}
        
		MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:n];
		[self.polygons addObject: polygon];
		free(coordinates);
        
		[self.latElements removeAllObjects];
		[self.lonElements removeAllObjects];
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
        
        PIRPolygonParser *parser = [PIRPolygonParser new];
        self.polygon = [parser parsePolygonFromData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            onComplete(self.polygon);
        });
    });
    
}

//TE: dont exactly know what this does. see: http://stackoverflow.com/questions/10109677/detect-if-a-point-is-inside-a-mkpolygon-overlay
-(BOOL)coordinateIsWithinZone:(CLLocationCoordinate2D)coordinate
{
    if (!self.gpx) {
        //if we dont have polygon data, we assume the zone is omnipresent
        return YES;
    }
    
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:self.polygon];
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    CGPoint polygonViewPoint = [polygonView pointForMapPoint:mapPoint];
    return CGPathContainsPoint(polygonView.path, NULL, polygonViewPoint, NO);
}

+(NSArray *)zonesForCoordinate:(CLLocationCoordinate2D)coordinate fromZones:(NSArray *)zones
{
    NSMutableArray *result = [NSMutableArray array];
    for (PIRZone *zone in zones) {
        if ([zone coordinateIsWithinZone:coordinate]) {
            [result addObject:zone];
        }
    }
    
    return result;
}


@end

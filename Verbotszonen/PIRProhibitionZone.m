//
//  PIRProhibitionZone.m
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRProhibitionZone.h"

@interface PIRProhibitionZone ()
@property (nonatomic, assign) CLLocationCoordinate2D *coordinates;
@property (nonatomic, assign) int count;
@end


//This is my first time parsing xml. Please forgive me :P
@interface PIRProhibitionZoneParser : NSObject<NSXMLParserDelegate>
-(PIRProhibitionZone *)parseZoneFromURL:(NSURL *)url;
@property (nonatomic, strong) NSMutableArray *latElements;
@property (nonatomic, strong) NSMutableArray *lonElements;
@end

@implementation PIRProhibitionZoneParser

-(void)reset
{
    self.latElements = [NSMutableArray array];
    self.lonElements = [NSMutableArray array];
}

-(PIRProhibitionZone *)parseZoneFromURL:(NSURL *)url
{
    [self reset];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser.delegate = self;
    PIRProhibitionZone *zone = [PIRProhibitionZone new];
    [parser parse];
    
    //Create the coordinates
    zone.count = self.latElements.count;
    zone.coordinates = malloc(zone.count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < zone.count; i++) {
        zone.coordinates[i].latitude = ((NSNumber *)self.latElements[i]).doubleValue;
        zone.coordinates[i].longitude = ((NSNumber *)self.lonElements[i]).doubleValue;
    }
    
    return zone;
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




@implementation PIRProhibitionZone

+(void)fetchAllProhibitionZonesOnComplete:(void(^)(NSArray *prohibitionZones))onComplete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Alkoholverbotszone_Graz" withExtension:@"gpx"];
        PIRProhibitionZoneParser *parser = [PIRProhibitionZoneParser new];
        PIRProhibitionZone *zone = [parser parseZoneFromURL:url];

        NSMutableArray *prohibitionZones = [NSMutableArray array];
        MKPolygon *polygon = [MKPolygon polygonWithCoordinates:zone.coordinates count:zone.count];
        [prohibitionZones addObject:polygon];
        
        
        //CLLocationCoordinate2D coordinates[3];
        //    coordinates[0] = CLLocationCoordinate2DMake(47.06692343082683, 15.444714708591887);
        //    coordinates[1] = CLLocationCoordinate2DMake(47.066099884065004, 15.444723799233914);
        //    coordinates[2] = CLLocationCoordinate2DMake(47.0661563012082, 15.444461180686384);
        //coordinates[0] = CLLocationCoordinate2DMake(47, 15);
        //coordinates[1] = CLLocationCoordinate2DMake(48, 15);
        //coordinates[2] = CLLocationCoordinate2DMake(47, 16);
        
        

        
        dispatch_async(dispatch_get_main_queue(), ^{
            onComplete(prohibitionZones);
        });
        
    });
    
}

@end

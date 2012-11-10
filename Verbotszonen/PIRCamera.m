//
//  PIRCamera.m
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRCamera.h"

@interface PIRCamera ()

//make the MKAnnotation coordinate property assignable
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation PIRCamera

- (id)initWithDict:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        //temporary helpers so we dont have to name a thousend variables
        NSDictionary *tempDict;
        NSArray *tempArr;
        
        
        //coordinate
        tempDict = dict[@"geometry"];
        if (!tempDict) {
            return nil;
        }
        
        tempArr = tempDict[@"coordinates"];
        if (!tempArr) {
            return nil;
        }
        
        if (tempArr.count != 2) {
            return nil;
        }
    
        NSNumber *lon = tempArr[0];
        NSNumber *lat = tempArr[1];
        if (![lat isKindOfClass:[NSNumber class]] || ![lon isKindOfClass:[NSNumber class]]) {
            return nil;
        }
        self.coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
        
        
        //name
        tempDict = dict[@"properties"];
        self.name = tempDict[@"name"];
        
    
    }
    return self;
}

+(void)fetchAllOnComplete:(void(^)(NSArray *cameras))onComplete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //fetch camera data
        NSData *camerasData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://orwell.at/export.json"]];
        if (!camerasData) {
            return;
        }
        
        //parse data->dict
        NSError *error = nil;
        NSDictionary *camerasDict = [NSJSONSerialization JSONObjectWithData:camerasData options:0 error:&error];
        if (error) {
            NSLog(@"error while parsing json: %@", [error description]);
            return;
        }
        
        //parse dict->object
        NSMutableArray *cameras = [NSMutableArray array];
        NSArray *rawCameras = camerasDict[@"features"];
        for (NSDictionary *rawCamera in rawCameras) {
            PIRCamera *camera = [[PIRCamera alloc] initWithDict:rawCamera];
            if (camera) {
                [cameras addObject:camera];
            }
        }
        
        //perform completion handler
        dispatch_async(dispatch_get_main_queue(), ^{
            onComplete(cameras);
        });
    });
}

#pragma mark MKAnnotation

-(NSString *)title
{
    return self.name;
}

-(NSString *)subtitle
{
    return nil;
}

@end

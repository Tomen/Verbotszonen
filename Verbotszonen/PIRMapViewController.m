//
//  PIRMapViewController.m
//  Verbotszonen
//
//  Created by tomen on 12.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRMapViewController.h"

@interface PIRMapViewController ()

@end

@implementation PIRMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(47.066667, 15.433333), MKCoordinateSpanMake(0.05, 0.05));
    self.mapView.showsUserLocation = YES;
}

-(void)setCameras:(NSArray *)cameras
{
    _cameras = cameras;
    if (!self.isViewLoaded) {
        [self loadView];
    }
    [self.mapView addAnnotations:cameras];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}
@end

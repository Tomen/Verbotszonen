//
//  PIRMainViewController.m
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRMainViewController.h"
#import "PIRCameraViewController.h"
#import "PIRCamera.h"
#import "PIRZone.h"
#import "PIRConfig.h"
#import "PIRDefinitions.h"
#import "PIRMapViewController.h"

@interface PIRMainViewController ()
@property (nonatomic, strong) NSArray *allZones;
@property (nonatomic, strong) NSArray *currentZones;
@property (nonatomic, assign) CLLocationCoordinate2D userCoordinate;
@property (nonatomic, strong) NSArray *cameras;
@property (nonatomic, strong) NSArray *activityItems;
@end

@implementation PIRMainViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    
    CGFloat width = self.tableView.bounds.size.width;
    CGFloat mapHeight = 120;
    
    UIImageView *mapHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar.png"]];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, mapHeaderView.bounds.size.height, width, mapHeight)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(47.066667, 15.433333), MKCoordinateSpanMake(0.05, 0.05));
    self.mapView.userInteractionEnabled = NO;
    
    UIImageView *mapFooterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listheader.png"]];
    CGRect mapFooterViewFrame = mapFooterView.frame;
    mapFooterViewFrame.origin.y = self.mapView.frame.origin.y + self.mapView.bounds.size.height;
    mapFooterView.frame = mapFooterViewFrame;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, mapFooterViewFrame.origin.y + mapFooterViewFrame.size.height)];
    [tableHeaderView addSubview:mapHeaderView];
    [tableHeaderView addSubview:self.mapView];
    [tableHeaderView addSubview:mapFooterView];

    self.tableView.tableHeaderView = tableHeaderView;
    UIView *tableViewTopView = [[UIView alloc] initWithFrame:
                         CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                    320.0f, self.view.bounds.size.height)];
    tableViewTopView.backgroundColor = [UIColor blackColor];
	[self.tableView addSubview:tableViewTopView];
	self.tableView.showsVerticalScrollIndicator = YES;
    
    [self checkFirstTime];

    
    [PIRCamera fetchAllOnComplete:^(NSArray *cameras) {
        self.cameras = cameras;
        [self.mapView addAnnotations:cameras];
        [self updateTable];
    }];
    
    
    
    [PIRConfig fetchOnComplete:^(PIRConfig *config) {

        if (!config) {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Bitte überprüfen Sie Ihre Internetverbindung." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }

        self.allZones = config.zones;

        for (PIRZone *zone in config.zones) {
            [zone fetchPolygonOnComplete:^(MKPolygon *polygon) {
                [self updateTable];
                if (polygon) {
                    [self.mapView addOverlay:polygon];
                }
            }];
        }
        
        [PIRNotification scheduleNotifications:config.notifications];
        
        //the share feature is only enabled in ios6
        if (config.activityItems && NSClassFromString(@"UIActivityViewController")) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onTapShare)];
        }
    }];
}

-(void)checkFirstTime
{
    //show first time view controller
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:@"didCompleteFirstTime"]) {
        [self performSegueWithIdentifier:@"showFirstTime" sender:nil];
    }
    else
    {
        self.mapView.showsUserLocation = YES;
    }
}

-(void)updateTable
{
    self.currentZones = [PIRZone zonesForCoordinate:self.userCoordinate fromZones:self.allZones];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        PIRWebViewController *vc = (PIRWebViewController *)segue.destinationViewController;
        vc.urlPath = PIR_URL_ABOUT;
        vc.title = @"Info";
    }
    else if([segue.identifier isEqualToString:@"showCamera"])
    {
        PIRCameraViewController *vc = (PIRCameraViewController *)segue.destinationViewController;
        vc.camera = sender;
    }
    else if([segue.identifier isEqualToString:@"showFirstTime"])
    {
        PIRFirstTimeViewController *vc = (PIRFirstTimeViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"showZoneDetails"])
    {
        PIRWebViewController *vc = (PIRWebViewController *)segue.destinationViewController;
        vc.cameraButtonVisible = YES;
        PIRZone *zone = sender;
        vc.urlPath = zone.description;
        vc.title = zone.title;
    }
    else if([segue.identifier isEqualToString:@"showMap"])
    {
        PIRMapViewController *vc = (PIRMapViewController *)segue.destinationViewController;
        vc.cameras = self.cameras;
    }
    
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

-(void)onTapShare
{
    self.activityItems = @[ [NSURL URLWithString:@"http://verbotszonen.at"] ];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:self.activityItems applicationActivities:nil];
    [self presentModalViewController:vc animated:YES];
}

#pragma mark MKMapViewDelegate

/*
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *cameraAnnotationIdentifier = @"cameraAnnotationIdentifier";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:cameraAnnotationIdentifier];
    if (!annotationView) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:cameraAnnotationIdentifier];
        pin.pinColor = MKPinAnnotationColorRed;
        pin.canShowCallout = YES;
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.rightCalloutAccessoryView = rightButton;
        return pin;
    }
    annotationView.annotation = annotation;
    return annotationView;
}
*/
 
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"showCamera" sender:view.annotation];
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonView *overlayView = [[MKPolygonView alloc] initWithOverlay:overlay];
        overlayView.strokeColor = [UIColor redColor];
        overlayView.lineWidth = 1;
        overlayView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
        return overlayView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        self.mapView.region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.001, 0.001));
        self.userCoordinate = userLocation.coordinate;
        [self updateTable];
    }
}

#pragma mark PIRFirstTimeViewControllerDelegate

-(void)firstTimeViewControllerDidComplete:(UIViewController *)vc
{
    [vc dismissModalViewControllerAnimated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@YES forKey:@"didCompleteFirstTime"];
    [defaults synchronize];
    
    //implicitly will ask the user for permission
    self.mapView.showsUserLocation = YES;
}

#pragma mark UITableViewDataSource

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentZones.count + 1; //+1 for camera
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *reuseIdentifier;
    id model;
    
    if (indexPath.row < self.currentZones.count) {
        reuseIdentifier = @"zoneCell";
        model = self.currentZones[indexPath.row];
    }
    else if(indexPath.row == self.currentZones.count) //Camera
    {
        reuseIdentifier = @"cameraCell";
        model = self.cameras;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    [cell performSelector:@selector(setModel:) withObject:model];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.currentZones.count) {
        PIRZone *zone = self.currentZones[indexPath.row];
        
        if (zone.description) {
            [self performSegueWithIdentifier:@"showZoneDetails" sender:zone];
        }
    }
    else if(indexPath.row == self.currentZones.count) //Camera
    {
        [self performSegueWithIdentifier:@"showMap" sender:nil];
    }
}


@end

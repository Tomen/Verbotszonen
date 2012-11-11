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
#import "PIRProhibitionZone.h"

@interface PIRMainViewController ()

@end

@implementation PIRMainViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 200)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    self.tableView.tableHeaderView = self.mapView;
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(47.066667, 15.433333), MKCoordinateSpanMake(0.05, 0.05));
    [self checkFirstTime];

    
    [PIRCamera fetchAllOnComplete:^(NSArray *cameras) {
        //[self.mapView addAnnotations:cameras];
    }];
    
    [PIRProhibitionZone fetchAllProhibitionZonesOnComplete:^(NSArray *prohibitionZones) {
        [self.mapView addOverlays:prohibitionZones];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(PIRFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
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
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark MKMapViewDelegate

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
        //[rightButton addTarget:self action:@selector(onTapShowCamera:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = rightButton;
        return pin;
    }
    annotationView.annotation = annotation;
    return annotationView;
}

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
        self.mapView.region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.002, 0.002));
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


@end

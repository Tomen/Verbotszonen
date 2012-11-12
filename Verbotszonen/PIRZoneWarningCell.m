//
//  PIRZoneWarningCell.m
//  Verbotszonen
//
//  Created by tomen on 12.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRZoneWarningCell.h"
#import <CoreLocation/CoreLocation.h>
#import "PIRZone.h"

#define PIRZoneWarningCellKey @"PIRZoneWarningCellKey"

@implementation PIRZoneWarningCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *warningsOn = [defaults objectForKey:PIRZoneWarningCellKey];
        self.warningSwitch.on = warningsOn.boolValue;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onValueChanged:(id)sender {
    CLLocationManager *locationManager = [CLLocationManager new];
    NSSet *monitoredRegions = [locationManager monitoredRegions];
    for (CLRegion *region in monitoredRegions) {
        [locationManager stopMonitoringForRegion:region];
    }
    
    if (self.warningSwitch.on) {
        for (PIRZone *zone in self.zones) {
            [zone startMonitoring];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(self.warningSwitch.on) forKey:PIRZoneWarningCellKey];
    [defaults synchronize];
}

@end

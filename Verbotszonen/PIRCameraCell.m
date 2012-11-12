//
//  PIRCameraCell.m
//  Verbotszonen
//
//  Created by tomen on 12.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRCameraCell.h"
#import "PIRCamera.h"
#import <CoreLocation/CoreLocation.h>

@implementation PIRCameraCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(NSArray *)cameras
{
    _cameras = cameras;
    int nearCameraCount = [PIRCamera nearCameraCountForCameras:self.cameras coordinate:[CLLocationManager new].location.coordinate];
    self.textLabel.text = [NSString stringWithFormat:@"%i Überwachungskameras", nearCameraCount];
    self.detailTextLabel.text = @"im Umkreis von 500 Metern";
}

@end

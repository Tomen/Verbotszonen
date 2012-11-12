//
//  PIRZoneWarningCell.h
//  Verbotszonen
//
//  Created by tomen on 12.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PIRZoneWarningCell : UITableViewCell

@property (nonatomic, strong, setter = setModel:) NSArray *zones;

@property (weak, nonatomic) IBOutlet UISwitch *warningSwitch;
- (IBAction)onValueChanged:(id)sender;

@end

//
//  PIRZoneCell.h
//  Verbotszonen
//
//  Created by tomen on 12.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PIRZone.h"

@interface PIRZoneCell : UITableViewCell
@property (nonatomic, strong, setter = setModel:) PIRZone *zone;
@end

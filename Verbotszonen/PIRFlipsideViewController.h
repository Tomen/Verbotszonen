//
//  PIRFlipsideViewController.h
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PIRFlipsideViewController;

@protocol PIRFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(PIRFlipsideViewController *)controller;
@end

@interface PIRFlipsideViewController : UIViewController

@property (weak, nonatomic) id <PIRFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end

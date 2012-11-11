//
//  PIRFirstTimeViewController.h
//  Verbotszonen
//
//  Created by tomen on 11.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRWebViewController.h"

@protocol PIRFirstTimeViewControllerDelegate <NSObject>

-(void)firstTimeViewControllerDidComplete:(UIViewController *)vc;

@end

@interface PIRFirstTimeViewController : PIRWebViewController

@property (nonatomic, weak) NSObject<PIRFirstTimeViewControllerDelegate> *delegate;

- (IBAction)onTapDone:(id)sender;

@end

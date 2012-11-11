//
//  PIRFirstTimeViewController.m
//  Verbotszonen
//
//  Created by tomen on 11.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRFirstTimeViewController.h"
#import "PIRDefinitions.h"

@interface PIRFirstTimeViewController ()

@end

@implementation PIRFirstTimeViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.urlPath = PIR_URL_WELCOME;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapDone:(id)sender {
    [self.delegate firstTimeViewControllerDidComplete:self];
}

@end

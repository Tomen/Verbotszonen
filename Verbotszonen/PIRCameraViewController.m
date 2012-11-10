//
//  PIRCameraViewController.m
//  Verbotszonen
//
//  Created by tomen on 10.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRCameraViewController.h"

@interface PIRCameraViewController ()

@end

@implementation PIRCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"Name: %@\nAdresse: ", self.camera.name];
    if (self.camera.street) {
        [description appendFormat:@"%@", self.camera.street];
    }
    if (self.camera.zip) {
        [description appendFormat:@", %@", self.camera.zip];
    }
    if (self.camera.town) {
        [description appendFormat:@", %@", self.camera.town];
    }
    self.descriptionLabel.text = description;
    
    CGSize textSize = [description sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.bounds.size.width, 10000)];
    CGRect frame = self.descriptionLabel.frame;
    frame.size.height = textSize.height;
    self.descriptionLabel.frame = frame;
    
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!self.camera.thumbnail) {
            return;
        }
        
        NSString *webPath = [NSString stringWithFormat:@"http://www.orwell.at%@", self.camera.thumbnail];
        
        NSURL *imageURL = [NSURL URLWithString:webPath];
        if (!imageURL) {
            return;
        }
        
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        if (!imageData) {
            return;
        }
        
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            self.imageView.image = image;
            CGFloat width = self.view.bounds.size.width;
            CGFloat height = image.size.height / image.size.width * self.view.bounds.size.width;
            self.imageView.frame = CGRectMake(0, self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 20, width, height);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.imageView.frame.origin.y + self.imageView.frame.size.height);
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setActivityIndicator:nil];
    [self setImageView:nil];
    [self setDescriptionLabel:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end

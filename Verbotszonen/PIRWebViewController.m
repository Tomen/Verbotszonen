//
//  PIRWebViewController.m
//  Verbotszonen
//
//  Created by tomen on 11.11.12.
//  Copyright (c) 2012 Piratenpartei Österreichs. All rights reserved.
//

#import "PIRWebViewController.h"

@interface PIRWebViewController ()

@end

@implementation PIRWebViewController
{
    BOOL _didLoadFirstRequest;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.cameraButton.hidden = !self.cameraButtonVisible;
    [self.view bringSubviewToFront:self.cameraButton];

    self.view.backgroundColor = [UIColor colorWithRGBHex:0x303030];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.bounces = NO;
    
    NSURL *url = [NSURL URLWithString:self.urlPath];
    if (!url) {
        return;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    if (!urlRequest) {
        return;
    }
    
    [self.webView loadRequest:urlRequest];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (!_didLoadFirstRequest) {
        _didLoadFirstRequest = YES;
        return YES;
    }
    
    return NO;
}

- (IBAction)cameraButtonPressed:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Damit das nicht Wirklichkeit wird: Am 25.11.2012 Piraten wählen! Für Freiheit und Vielfalt im öffentlichen Raum und gegen Pauschalverbote!" delegate:self cancelButtonTitle:@"Mehr Informationen" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://piratenpartei-steiermark.at"]];
}

@end

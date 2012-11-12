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
    [super viewWillAppear:animated];
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
    
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
}

@end

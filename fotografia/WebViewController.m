//
//  WebViewController.m
//  fotografia
//
//  Created by Adam on 12/10/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

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
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:_weburl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    _webview.scalesPageToFit = YES;
    _webview.scrollView.bounces = false;
    [_webview loadRequest:request];
    
}

- (IBAction)donbtnclick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"start load");
    [_indicatorview startAnimating];
    [_indicatorview setHidden:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"load error");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicatorview stopAnimating];
    [_indicatorview setHidden:YES];
}

@end

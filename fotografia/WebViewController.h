//
//  WebViewController.h
//  fotografia
//
//  Created by Adam on 12/10/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *indicatorview;
@property(nonatomic, retain) IBOutlet UIWebView *webview;
@property(nonatomic, strong) NSString *weburl;
@end

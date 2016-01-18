//
//  PastVideoMovieViewController.m
//  fotografia
//
//  Created by Adam on 12/10/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "PastVideoMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PastVideoMovieViewController ()
{
    MPMoviePlayerController *moviePlayer;
    UIActivityIndicatorView *spinner;
}
@end

@implementation PastVideoMovieViewController
@synthesize videolinkurl;

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
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videolinkurl]];
    moviePlayer.view.frame = CGRectMake(0, 0, self.videoview.frame.size.width, self.videoview.frame.size.height);
    [self.videoview addSubview:moviePlayer.view];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[spinner setCenter:CGPointMake(160, 220)];
    [moviePlayer.view addSubview:spinner];
    [spinner startAnimating];
    [moviePlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    // Do any additional setup after loading the view.
}

-(void)movieLoadStateDidChanged:(id)sender{
    if(MPMovieLoadStatePlaythroughOK ) {
        spinner.hidden = YES;
        [spinner stopAnimating];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
}

-(IBAction)donebtnclick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [moviePlayer stop];
}

@end

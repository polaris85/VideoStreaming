//
//  ThirdtabViewController.m
//  fotografia
//
//  Created by Adam on 11/27/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "ThirdtabViewController.h"
#import "PastEventSearchController.h"
#import "fotografiaAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WebViewController.h"
@interface ThirdtabViewController ()
{
    MPMoviePlayerController *moviePlayer;
    UIActivityIndicatorView *spinner;
    fotografiaAppDelegate *app;
}
@end

@implementation ThirdtabViewController

@synthesize datePicker;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    app = [[UIApplication sharedApplication]delegate];
    
    _bannerview.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(banerclick:)];
    [_bannerview addGestureRecognizer:tap];
    [self performSelectorInBackground:@selector(placeImageInUI) withObject:nil];
}

- (void)placeImageInUI
{
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:app.banneimgrurl]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    [_bannerview setImage:image];
}

-(void)banerclick:(UITapGestureRecognizer*)tap{
    
    UIStoryboard *storyboard;
    if(IS_IPHONE)
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"  bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4"  bundle:nil];
    WebViewController *webcontroller = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webcontroller.weburl = app.bannerlinkurl;
    
    NSLog(@"weburl=%@",app.bannerlinkurl);
    [self presentViewController:webcontroller animated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(moviePlayer.fullscreen)
    {
        app.video_fullscreen = true;
    }
    else
    {
        if(!app.video_fullscreen)
        {
            if(moviePlayer!=nil)
            {
                [moviePlayer stop];
                [moviePlayer.view removeFromSuperview];
                moviePlayer = nil;
                spinner = nil;
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        }
    }
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (UIDeviceOrientationIsLandscape([self interfaceOrientation])) {
        if(IS_IPHONE)
        {
            _bannerview.frame = CGRectMake(0, 20, 568, 47);
            _playview.frame = CGRectMake(0, 67, 284, 190);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.playview.frame.size.width, self.playview.frame.size.height);
            _otherview.frame = CGRectMake(284, 67, 284, 190);
        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 480, 47);
            _playview.frame = CGRectMake(0, 67, 240, 190);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.playview.frame.size.width, self.playview.frame.size.height);
            _otherview.frame = CGRectMake(240, 67, 240, 190);
        }
    }
    else
    {
        if(IS_IPHONE)
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _playview.frame = CGRectMake(0, 67, 320, 222);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.playview.frame.size.width, self.playview.frame.size.height);
            _otherview.frame = CGRectMake(0, 288, 320, 231);

        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _playview.frame = CGRectMake(0, 67, 320, 211);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.playview.frame.size.width, self.playview.frame.size.height);
            _otherview.frame = CGRectMake(0, 276, 320, 150);
        }
    }
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!app.video_fullscreen)
    {
        int index = arc4random() % [app.autovideoarray count];
        
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[app.autovideoarray objectAtIndex:index]]];
        moviePlayer.view.frame = CGRectMake(0, 0, self.playview.frame.size.width, self.playview.frame.size.height);
        [self.playview addSubview:moviePlayer.view];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner setCenter:self.playview.center];
        [moviePlayer.view addSubview:spinner];
        [spinner startAnimating];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoadStateDidChanges:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        [moviePlayer play];
    }
    app.video_fullscreen = false;
}



-(void)movieLoadStateDidChanges:(id)sender{
    if(MPMovieLoadStatePlayable ) {
        NSLog(@"second STATE CHANGED");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        spinner.hidden = YES;
        [spinner stopAnimating];
    }
}



- (IBAction)startdatebtnclick:(id)sender
{
    start_endlbl_chooseflag = true;
    NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"SelectDateKey", @"")]
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Okey",nil, nil];
    [sheet showInView:self.view];
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [sheet addSubview:datePicker];
}


- (IBAction)enddatebtnclick:(id)sender
{
    start_endlbl_chooseflag = false;
    NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"SelectDateKey", @"")]
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Okey",nil, nil];
    [sheet showInView:self.view];
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [sheet addSubview:datePicker];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSDate *date = datePicker.date;
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *fullDate = [format stringFromDate:date];
        if(start_endlbl_chooseflag)
            [_startdatelbl setText:fullDate];
        else
            [_enddatalbl setText:fullDate];
    }
}

- (IBAction)viewbtnclick:(id)sender
{
    
    if([_startdatelbl.text isEqualToString:@""])
    {
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"" message:@"Please Choose a StartDate." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
        return;
    }
    else if ([_enddatalbl.text isEqualToString:@""])
    {
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"" message:@"Please Choose a EndDate." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
        return;
    }
    else
    {
        NSString *start_date = _startdatelbl.text;
        NSString *end_date = _enddatalbl.text;
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [f dateFromString:start_date];
        NSDate *endDate = [f dateFromString:end_date];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        int different_days = [components day];
        if(different_days<=0 || different_days>90)
        {
            UIAlertView *alertview  = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Choose Right Dates, Date range is 3 months." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertview show];
        }
        else
        {
            NSString *pasteventurl = [NSString stringWithFormat:@"%@eventstartdate=%@&eventenddate=%@", PAST_EVENT_API,_startdatelbl.text,_enddatalbl.text];
            UIStoryboard *storyboard;
            if(IS_IPHONE)
                storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"  bundle:nil];
            else
                storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4"  bundle:nil];
            PastEventSearchController *searchcontroller = [storyboard instantiateViewControllerWithIdentifier:@"PastEventSearchController"];
            searchcontroller.pasteventurl = pasteventurl;
            [self.navigationController pushViewController:searchcontroller animated:YES];
            app.video_fullscreen = false;
        }
    }
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  VideoplayViewController.m
//  fotografia
//
//  Created by Adam on 11/28/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "VideoplayViewController.h"
#import "VSPlayerViewController.h"
#import "WebViewController.h"
#import "fotografiaAppDelegate.h"

@interface VideoplayViewController ()
{
    VSPlayerViewController *playerVc;
    fotografiaAppDelegate *app;
}
@end

@implementation VideoplayViewController

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
    app = [[UIApplication sharedApplication]delegate];
    
    NSString *document;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    document = [path objectAtIndex:0];
    document = [document stringByAppendingPathComponent:@"imageCache/"];
     _objmanager = [[HJObjManager alloc]initWithLoadingBufferSize:6 memCacheSize:20];
    HJMOFileCache *fileCache = [[HJMOFileCache alloc]initWithRootPath:document];
    _objmanager.fileCache = fileCache;
    
    [_titlelbl setText:_event_title];
    // Do any additional setup after loading the view.
    
    NSLog(@"imageurl=%@",[_event_logoimageurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    [_eventlogo_imageview clear];
    [_eventlogo_imageview showLoadingWheel];
    [_eventlogo_imageview setUrl:[NSURL URLWithString:[_event_logoimageurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [_objmanager manage:_eventlogo_imageview];
    
    if(_event_linkurl == (id)[NSNull null])
        _eventlinklbl.text = @"";
    else
        _eventlinklbl.text = _event_linkurl;
    
    if(_event_description == (id)[NSNull null])
        _eventdescriptionlbl.text = @"";
    else
        _eventdescriptionlbl.text = _event_description;
    
    [_titlelbl setNumberOfLines:2];
    [_titlelbl sizeToFit];
    
    [_eventdescriptionlbl setNumberOfLines:6];
    [_eventdescriptionlbl sizeToFit];

    _bannerview.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(banerclick:)];
    [_bannerview addGestureRecognizer:tap];
    [self performSelectorInBackground:@selector(placeImageInUI) withObject:nil];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (UIDeviceOrientationIsLandscape([self interfaceOrientation])) {
        if(IS_IPHONE)
        {
            _bannerview.frame = CGRectMake(0, 20, 568, 47);
            _videoplayview.frame = CGRectMake(0, 67, 284, 190);
            if(playerVc!=nil)
                playerVc.view.frame = CGRectMake(0, 67, self.videoplayview.frame.size.width, self.videoplayview.frame.size.height);
            _otherview.frame = CGRectMake(284, 67, 284, 190);
        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 480, 47);
            _videoplayview.frame = CGRectMake(0, 67, 240, 190);
            if(playerVc!=nil)
                playerVc.view.frame = CGRectMake(0, 67, self.videoplayview.frame.size.width, self.videoplayview.frame.size.height);
            _otherview.frame = CGRectMake(240, 67, 240, 190);
        }
    }
    else
    {
        if(IS_IPHONE)
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _videoplayview.frame = CGRectMake(0, 67, 320, 222);
            if(playerVc!=nil)
                playerVc.view.frame = CGRectMake(0, 67, self.videoplayview.frame.size.width, self.videoplayview.frame.size.height);
            _otherview.frame = CGRectMake(0, 288, 320, 231);
        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _videoplayview.frame = CGRectMake(0, 67, 320, 211);
            if(playerVc!=nil)
                playerVc.view.frame = CGRectMake(0, 67, self.videoplayview.frame.size.width, self.videoplayview.frame.size.height);
            _otherview.frame = CGRectMake(0, 277, 320, 150);
        }
    }
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


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![_event_videochannel isEqualToString:@""])
    {
        playerVc = [[VSPlayerViewController alloc] initWithURL:[NSURL URLWithString:_event_videochannel] decoderOptions:[NSDictionary dictionaryWithObject:VSDECODER_OPT_VALUE_RTSP_TRANSPORT_TCP forKey:VSDECODER_OPT_KEY_RTSP_TRANSPORT]];
        [playerVc setBack_check_flag:true];
        [playerVc.view setFrame:CGRectMake(0, 150, _videoplayview.frame.size.width, _videoplayview.frame.size.height)];
        [self.view addSubview:playerVc.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(playerVc.back_check_flag)
            [playerVc close:self];
        [playerVc setBack_check_flag:true];
    
    [super viewDidDisappear:YES];
}

- (IBAction) backbtnclick:(id)sender
{
        [playerVc setBack_check_flag:false];
        [playerVc close:self];
       [self.navigationController popViewControllerAnimated:YES];

}


@end

//
//  FourthtabViewController.m
//  fotografia
//
//  Created by Adam on 11/27/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "FourthtabViewController.h"
#import "WebViewController.h"
#import "fotografiaAppDelegate.h"
@interface FourthtabViewController ()
{
    fotografiaAppDelegate *app;
}
@end

@implementation FourthtabViewController
@synthesize mutablenextarray;


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
    [self.navigationController.navigationBar setHidden:YES];
    
    mutablenextarray= [[NSMutableArray alloc]init];
    
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    [_HUD setLabelText:@"Loading..."];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:Contact_API]];
    self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
            _logoview.frame = CGRectMake(0, 67, 284, 175);
            _otherview.frame = CGRectMake(284, 67, 284, 200);
        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 480, 47);
            _logoview.frame = CGRectMake(0, 77, 240, 175);
            _otherview.frame = CGRectMake(240, 67, 240, 200);
        }
    }
    else
    {
        if(IS_IPHONE)
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _logoview.frame = CGRectMake(22, 45, 278, 170);
            _otherview.frame = CGRectMake(0, 201, 320, 230);
        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _logoview.frame = CGRectMake(0, 20, 320, 195);
            _otherview.frame = CGRectMake(0, 186, 320, 230);
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
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4"  bundle:nil];    WebViewController *webcontroller = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webcontroller.weburl = app.bannerlinkurl;
    
    NSLog(@"weburl=%@",app.bannerlinkurl);
    [self presentViewController:webcontroller animated:YES completion:nil];
}



- (void)connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse *)response
{
    _responseData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)data
{
    if(data!=nil)
        [self.responseData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error=%@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_HUD hide:YES];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _responseArray = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:nil];
    
   
    [_emaillbl setText:[NSString stringWithFormat:@"- Email: %@",[[[_responseArray objectForKey:@"webtv"] objectAtIndex:0]objectForKey:@"email"]]];
    [_addresslbl setText:[NSString stringWithFormat:@"%@",[[[_responseArray objectForKey:@"webtv"] objectAtIndex:0]objectForKey:@"adress"]]];
  
    [_telefonelbl setText:[NSString stringWithFormat:@" Telefone: %@",[[[_responseArray objectForKey:@"webtv"] objectAtIndex:0]objectForKey:@"telefone"]]];

    [_mobilelbl setText:[NSString stringWithFormat:@" Telefone: %@",[[[_responseArray objectForKey:@"webtv"] objectAtIndex:0]objectForKey:@"mobile"]]];
//    [_keywordslbl setText:[[[_responseArray objectForKey:@"webtv"] objectAtIndex:0]objectForKey:@"keywords"]];
//    [_keywordslbl setNumberOfLines:0];
//    [_keywordslbl sizeToFit];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

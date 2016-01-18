//
//  SplashViewController.m
//  fotografia
//
//  Created by Adam on 12/12/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "SplashViewController.h"
#import "fotografiaAppDelegate.h"
#import "fotografiaViewController.h"
#import "ThirdtabViewController.h"
#import "FourthtabViewController.h"

@interface SplashViewController ()
{
    fotografiaAppDelegate *app;
}
@end

@implementation SplashViewController
@synthesize customTabBarController;
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
    // Do any additional setup after loading the view.
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    [_HUD setLabelText:@""];
    
     mutablenextarray= [[NSMutableArray alloc]init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:AUTO_VIDEO_API]];
    self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
    _responseArray = [self cleanJsonToObject:self.responseData];
    NSArray *videoarray = [_responseArray objectForKey:@"eventsvideos"];
    for (int i=0; i<[videoarray count]; i++) {
        NSString *videourlstr = [[videoarray objectAtIndex:0] objectForKey:@"PROGRESSIVEURL"];
        [app.autovideoarray addObject:videourlstr];
    }
    app.banneimgrurl = [[[videoarray objectAtIndex:0] objectForKey:@"bannerurl"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url=%@", app.banneimgrurl);
    app.bannerlinkurl = [[[videoarray objectAtIndex:0] objectForKey:@"bannerlink"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    UIStoryboard * storyboard;
    if(IS_IPHONE)
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"  bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4"  bundle:nil];
    
    customTabBarController = [[MokriyaUITabBarController alloc] init];
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    // first tab
    fotografiaViewController *firstviewcontroller = [storyboard instantiateViewControllerWithIdentifier:@"fotografiaViewController"];
    UINavigationController *firstnavigationController = [[UINavigationController alloc]initWithRootViewController:firstviewcontroller];
    [firstnavigationController.tabBarItem setImage:[UIImage imageNamed:@""]];
    [viewControllers addObject:firstnavigationController];
    
    
    // second tab
    ThirdtabViewController *thirdviewcontroller = [storyboard instantiateViewControllerWithIdentifier:@"ThirdtabViewController"];
    UINavigationController *thirdnavigationController = [[UINavigationController alloc]initWithRootViewController:thirdviewcontroller];
    [thirdnavigationController.tabBarItem setImage:[UIImage imageNamed:@""]];
    [viewControllers addObject:thirdnavigationController];
    
    
    // third tab
    FourthtabViewController *fourthviewcontroller = [storyboard instantiateViewControllerWithIdentifier:@"FourthtabViewController"];
    UINavigationController *fourthnavigationController = [[UINavigationController alloc]initWithRootViewController:fourthviewcontroller];
    [fourthnavigationController.tabBarItem setImage:[UIImage imageNamed:@""]];
    [viewControllers addObject:fourthnavigationController];
    
    
    customTabBarController.viewControllers = viewControllers;
    customTabBarController.allViewControllers = viewControllers;
    
    customTabBarController.tabBarImagesArray = [NSMutableArray arrayWithObjects:
                                                [UIImage imageNamed:@"next_on.png"],
                                                [UIImage imageNamed:@"past_on.png"],
                                                [UIImage imageNamed:@"contact_on.png"],
                                                nil];
    
    customTabBarController.tabBarSelectedStateImagesArray = [NSMutableArray arrayWithObjects:
                                                             [UIImage imageNamed:@"next_off.png"],
                                                             [UIImage imageNamed:@"past_off.png"],
                                                             [UIImage imageNamed:@"contact_off.png"],
                                                             nil];
    customTabBarController.tabBarTitlesArray = [NSMutableArray arrayWithObjects:
                                                @"",
                                                @"",
                                                @"",
                                                nil];
    
    
    
    [customTabBarController customizeTabBar];
    [self.navigationController pushViewController:customTabBarController animated:NO];
}


- (id)cleanJsonToObject:(id)data {
    NSError* error;
    if (data == (id)[NSNull null]){
        return [[NSObject alloc] init];
    }
    id jsonObject;
    if ([data isKindOfClass:[NSData class]]){
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    } else {
        jsonObject = data;
    }
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [jsonObject mutableCopy];
        for (int i = array.count-1; i >= 0; i--) {
            id a = array[i];
            if (a == (id)[NSNull null]){
                [array removeObjectAtIndex:i];
            } else {
                array[i] = [self cleanJsonToObject:a];
            }
        }
        return array;
    } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [jsonObject mutableCopy];
        for(NSString *key in [dictionary allKeys]) {
            id d = dictionary[key];
            if (d == (id)[NSNull null]){
                dictionary[key] = @"";
            } else {
                dictionary[key] = [self cleanJsonToObject:d];
            }
        }
        return dictionary;
    } else {
        return jsonObject;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

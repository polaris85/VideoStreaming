//
//  PastEventDetailViewController.m
//  fotografia
//
//  Created by Adam on 12/5/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "PastEventDetailViewController.h"
#import "VSPlayerViewController.h"
#import "PastVideoMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WebViewController.h"
#import "fotografiaAppDelegate.h"

@interface PastEventDetailViewController ()
{
    MPMoviePlayerController *moviePlayer;
    UIActivityIndicatorView *spinner;
    fotografiaAppDelegate *app;
}
@end

@implementation PastEventDetailViewController
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
    
    mutablenextarray= [[NSMutableArray alloc]init];
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    [_HUD setLabelText:@"Loading..."];
    
    NSString *vidoelisturl = [NSString stringWithFormat:@"http://naminhaterra.com/webservices/json/videos/index.php?eventid=%@&ordem=titulo&ordem1=DESC", _event_id];
    NSLog(@"url=%@", vidoelisturl);
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:vidoelisturl]];
    self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Do any additional setup after loading the view.
    
    NSString *document;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    document = [path objectAtIndex:0];
    document = [document stringByAppendingPathComponent:@"imageCache/"];
    _objmanager = [[HJObjManager alloc]initWithLoadingBufferSize:6 memCacheSize:20];
    HJMOFileCache *fileCache = [[HJMOFileCache alloc]initWithRootPath:document];
    _objmanager.fileCache = fileCache;
    
    fileCache.fileCountLimit = 300;
    fileCache.fileAgeLimit = 60*60*24*7;
    [fileCache trimCacheUsingBackgroundThread];
    
     [_eventtitlelbl setText:_event_title];
    
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
    mutablenextarray = [_responseArray objectForKey:@"eventsvideos"];
    NSLog(@"array=%@", mutablenextarray);
    NSLog(@"array=%d", [mutablenextarray count]);
    _responseArray = [self cleanJsonToObject:self.responseData];
    mutablenextarray = [_responseArray objectForKey:@"eventsvideos"];
    NSLog(@"array=%@", mutablenextarray);
    NSLog(@"array=%d", [mutablenextarray count]);
    
    
    [_pasteventvideotbl reloadData];
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

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSUInteger count = [mutablenextarray count];
    return count > 0 ? count : 0;}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier11 = @"pastvideocell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier11];

    NSUInteger count = [mutablenextarray count];
    if(count > 0)
    {
        HJManagedImageV *imageV = (HJManagedImageV*)[cell viewWithTag:100];
        [imageV clear];
        [imageV showLoadingWheel];
        [imageV setUrl:[NSURL URLWithString:[[mutablenextarray objectAtIndex:indexPath.row]valueForKey:@"thumb"]]];
        [_objmanager manage:imageV];
        [cell.contentView addSubview:imageV];
        
        UILabel *videotitle= (UILabel*)[cell viewWithTag:101];
        videotitle.text =  [[mutablenextarray objectAtIndex:indexPath.row]valueForKey:@"titulo"];
        NSLog(@"title=%@",[[mutablenextarray objectAtIndex:indexPath.row]valueForKey:@"thumb"]);
        UILabel *videoviews= (UILabel*)[cell viewWithTag:102];
        videoviews.text =  [NSString stringWithFormat:@"Views: %@",[[mutablenextarray objectAtIndex:indexPath.row]valueForKey:@"count"]];

    }
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath
                                                                    *)indexPath {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    
    NSString *videolinkurl = [[((NSArray *)[self.responseArray objectForKey:@"eventsvideos"]) objectAtIndex:indexPath.row] valueForKey:@"PROGRESSIVEURL"];
    if(moviePlayer!=nil)
        [moviePlayer.view removeFromSuperview];
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videolinkurl]];
    moviePlayer.view.frame = CGRectMake(0, 0, self.playview.frame.size.width, self.playview.frame.size.height);
    [self.playview addSubview:moviePlayer.view];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:self.playview.center];
    [moviePlayer.view addSubview:spinner];
    [spinner startAnimating];
    [moviePlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pastmovieLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(moviePlayer!=nil)
        [moviePlayer pause];
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
            _otherview.frame = CGRectMake(0, 270, 320, 160);
        }
    }
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (moviePlayer!=nil) {
        [moviePlayer play];
    }
}

-(void)pastmovieLoadStateDidChange:(id)sender{
    NSLog(@"STATE CHANGED");
    if(MPMovieLoadStatePlaythroughOK ) {
        NSLog(@"State is Playable OK");
        NSLog(@"Enough data has been buffered for playback to continue uninterrupted..");
        spinner.hidden = YES;
        [spinner stopAnimating];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backbtnclick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end

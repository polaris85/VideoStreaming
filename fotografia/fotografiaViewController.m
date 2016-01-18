//
//  fotografiaViewController.m
//  fotografia
//
//  Created by Adam on 11/24/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "fotografiaViewController.h"
#import "VideoplayViewController.h"
#import "fotografiaAppDelegate.h"
#import "WebViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface fotografiaViewController ()
{
    fotografiaAppDelegate *app;
    MPMoviePlayerController *moviePlayer;
    UIActivityIndicatorView *spinner;
}
@end

@implementation fotografiaViewController
@synthesize nexteventstbl;
@synthesize mutablenextarray;
@synthesize imageviewload;
@synthesize bannerurl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    app = [[UIApplication sharedApplication]delegate];
  
    [self.navigationController.navigationBar setHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
    [imageviewload startAnimating];
    mutablenextarray= [[NSMutableArray alloc]init];
    
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    [_HUD setLabelText:@"Loading..."];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:NEXT_EVENT_API]];
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
            _logoview.frame = CGRectMake(0, 67, 284, 190);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.logoview.frame.size.width, self.logoview.frame.size.height);
            _otherview.frame = CGRectMake(284, 67, 284, 190);
        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 480, 47);
            _logoview.frame = CGRectMake(0, 67, 240, 190);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.logoview.frame.size.width, self.logoview.frame.size.height);
            _otherview.frame = CGRectMake(240, 67, 240, 190);
        }
    }
    else
    {
        if(IS_IPHONE)
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _logoview.frame = CGRectMake(0, 67, 320, 222);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.logoview.frame.size.width, self.logoview.frame.size.height);
            _otherview.frame = CGRectMake(0, 288, 320, 231);
        }
        else
        {
            _bannerview.frame = CGRectMake(0, 20, 320, 47);
            _logoview.frame = CGRectMake(0, 67, 320, 211);
            if(moviePlayer!=nil)
                moviePlayer.view.frame = CGRectMake(0, 0, self.logoview.frame.size.width, self.logoview.frame.size.height);
            _otherview.frame = CGRectMake(0, 276, 320, 150);
        }
    }
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
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

        }
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!app.video_fullscreen)
    {
        int index = arc4random() % [app.autovideoarray count];
        _autovideourl = [app.autovideoarray objectAtIndex:index];
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[app.autovideoarray objectAtIndex:index]]];
        moviePlayer.view.frame = CGRectMake(0, 0, self.logoview.frame.size.width, self.logoview.frame.size.height);
        [self.logoview addSubview:moviePlayer.view];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner setCenter:self.logoview.center];
        [moviePlayer.view addSubview:spinner];
        [spinner startAnimating];
        [moviePlayer play];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoadStateDidChanges:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviefinishStateDidChanges:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
    }
    app.video_fullscreen = false;
}

- (void)moviefinishStateDidChanges:(id)sender{
    NSLog(@"video finished");
}

-(void)movieLoadStateDidChanges:(id)sender{
    if(MPMovieLoadStatePlayable ) {
        NSLog(@"first STATE CHANGED");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        spinner.hidden = YES;
        [spinner stopAnimating];
    }
    
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
    _responseArray = [self cleanJsonToObject:self.responseData];
     NSUInteger count = [((NSArray *)[_responseArray objectForKey:@"nextevents"]) count];
    
    int itemcount = 0;
    while(itemcount<count)
    {
        NSString *eventtitlestr = [[((NSArray *)[_responseArray objectForKey:@"nextevents"]) objectAtIndex:itemcount] objectForKey:@"eventtitle"];
        if(eventtitlestr == (id)[NSNull null])
        {
            NSLog(@"Error=null");
        }
        else
        {
            [mutablenextarray addObject:[((NSArray *)[_responseArray objectForKey:@"nextevents"]) objectAtIndex:itemcount]];
        }
    
        itemcount++;
    }
    NSLog(@"test=%@", mutablenextarray);

    [nexteventstbl reloadData];
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


- (void)placeImageInUI
{

    NSString *imageurl =app.banneimgrurl;
    bannerurl = app.bannerlinkurl;
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageurl]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    [_bannerview setImage:image];
    [imageviewload stopAnimating];
    [imageviewload setHidden:YES];
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
    return count > 0 ? count : 1;}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier11 = @"nexteventcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier11];
    
    NSUInteger count = [mutablenextarray count];
    if(count > 0)
    {
        UILabel *eventtitlelbl= (UILabel*)[cell viewWithTag:103];
        NSString *eventtitlestr = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventtitle"];
        
        if(eventtitlestr == (id)[NSNull null])
            eventtitlelbl.text = @"ttttt";
        else
            eventtitlelbl.text = eventtitlestr;
        
        NSString *startdatestr = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventstartdate"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *startdateday = [df dateFromString: startdatestr];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* componentsdate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:startdateday];
        
        
        UILabel *daylbl = (UILabel*)[cell viewWithTag:101];
        daylbl.text = [NSString stringWithFormat:@"%d", [componentsdate day]];
        
        [df setDateFormat:@"MMMM"];
        NSString *startdatemonth = [df stringFromDate:startdateday];
        startdatemonth = [startdatemonth substringToIndex:3];
        UILabel *monthlbl = (UILabel*)[cell viewWithTag:102];
        monthlbl.text = startdatemonth;
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        UILabel *startdatelbl = (UILabel*)[cell viewWithTag:104];
        startdatelbl.text = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventstarttime"];
        
        
        UILabel *otherlbl = (UILabel*)[cell viewWithTag:105];
        otherlbl.text = [NSString stringWithFormat:@"%@ / %@",[[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"EventTypeName"],[[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"EventLocation"]];
        
        UILabel *directolbl = (UILabel*)[cell viewWithTag:106];
        NSString *islive = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventislive"];
        NSLog(@"test=%@=%d", islive, indexPath.row);
        
        if([islive intValue]==1)
            directolbl.text = @"DIRETO";
        else
            directolbl.text = @"";
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath
                                                                    *)indexPath {
    NSString *chooseevent_islive = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventislive"];
        app.video_fullscreen = false;
        NSString *chooseevent_linkurl = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventurlexternalpage"];
        NSString *chooseevent_logoimage = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventurllogoimage"];
        
        UIStoryboard *storyboard;
        if(IS_IPHONE)
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"  bundle:nil];
        else
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4"  bundle:nil];
        
        VideoplayViewController *playcontroller = [storyboard instantiateViewControllerWithIdentifier:@"VideoplayViewController"];
        playcontroller.event_title = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventtitle"];
        if([chooseevent_islive intValue]==1)
            playcontroller.event_videochannel = [NSString stringWithFormat:@"rtsp://mobilestr3.livestream.com/livestreamiphone/%@", [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventchannel"]];
        else
            playcontroller.event_videochannel = @"";
        
//        playcontroller.event_videochannel = _autovideourl;
        playcontroller.event_logoimageurl = [NSString stringWithFormat:@"http://www.naminhaterra.com/ADMIN/%@", chooseevent_logoimage];
        playcontroller.event_linkurl = chooseevent_linkurl;
        playcontroller.event_description = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventdescription"];
        [self.navigationController pushViewController:playcontroller animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)banerclick:(UITapGestureRecognizer*)tap{

    UIStoryboard *storyboard;
    if(IS_IPHONE)
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"  bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4"  bundle:nil];
    
        WebViewController *webcontroller = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webcontroller.weburl = bannerurl;
        [self presentViewController:webcontroller animated:YES completion:nil];
}

@end

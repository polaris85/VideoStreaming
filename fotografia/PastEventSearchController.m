//
//  PastEventSearchController.m
//  fotografia
//
//  Created by Adam on 12/12/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import "PastEventSearchController.h"
#import "PastEventDetailViewController.h"
#import "WebViewController.h"
#import "fotografiaAppDelegate.h"
@interface PastEventSearchController ()
{
    fotografiaAppDelegate *app;
}
@end

@implementation PastEventSearchController
@synthesize pasteventstbl;
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
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    [_HUD setLabelText:@"Loading..."];
    app = [[UIApplication sharedApplication]delegate];
    
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
    
    
    // Do any additional setup after loading the view.
    [pasteventstbl setHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
    
    mutablenextarray= [[NSMutableArray alloc]init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_pasteventurl]];
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
            _otherview.frame = CGRectMake(0, 20, 568, 82);
            pasteventstbl.frame = CGRectMake(0, 102, 568, 200);
        }
        else
        {
            _otherview.frame = CGRectMake(0, 20, 480, 82);
            pasteventstbl.frame = CGRectMake(0, 102, 480, 200);
        }
    }
    else
    {
        if(IS_IPHONE)
        {
            _otherview.frame = CGRectMake(0, 20, 320, 82);
            pasteventstbl.frame = CGRectMake(0, 102, 320, 417);
        }
        else
        {
            _otherview.frame = CGRectMake(0, 20, 320, 82);
            pasteventstbl.frame = CGRectMake(0, 102, 320, 329);
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
    //    _responseArray = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:nil];
    _responseArray = [self cleanJsonToObject:self.responseData];
    NSUInteger count = [((NSArray *)[_responseArray objectForKey:@"pastevents"]) count];
    
    int itemcount = 0;
    while(itemcount<count)
    {
        NSString *eventtitlestr = [[((NSArray *)[_responseArray objectForKey:@"pastevents"]) objectAtIndex:itemcount] objectForKey:@"eventtitle"];
        if(eventtitlestr == (id)[NSNull null])
        {
            NSLog(@"Error=null");
        }
        else
        {
            [mutablenextarray addObject:[((NSArray *)[_responseArray objectForKey:@"pastevents"]) objectAtIndex:itemcount]];
        }
        
        itemcount++;
    }
    NSLog(@"test=%@", mutablenextarray);
    if([mutablenextarray count]>0)
    {
        [pasteventstbl setHidden:NO];
    }
    [pasteventstbl reloadData];
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



#pragma mark uitableview delgate

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
    static NSString *CellIdentifier11 = @"pasteventcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier11];
    
    NSUInteger count = [mutablenextarray count];
    if(count > 0)
    {
        NSString *chooseevent_logoimage = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventurllogoimage"];
        
        HJManagedImageV *imageV = (HJManagedImageV*)[cell viewWithTag:101];
        [imageV clear];
        [imageV showLoadingWheel];
        [imageV setUrl:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.naminhaterra.com/ADMIN/%@", chooseevent_logoimage]]];
        [_objmanager manage:imageV];
        [cell.contentView addSubview:imageV];
        
        
        UILabel *eventtitlelbl= (UILabel*)[cell viewWithTag:102];
        eventtitlelbl.text = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventtitle"];
        UILabel *eventdesclbl= (UILabel*)[cell viewWithTag:103];
        eventdesclbl.text = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventdescription"];
       [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath
                                                                    *)indexPath {
    
    UIStoryboard *storyboard;
    if(IS_IPHONE)
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"  bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4"  bundle:nil];
    PastEventDetailViewController *playcontroller = [storyboard instantiateViewControllerWithIdentifier:@"PastEventDetailViewController"];
    playcontroller.event_title = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventtitle"];
    playcontroller.event_id = [[mutablenextarray objectAtIndex:indexPath.row] objectForKey:@"eventid"];
    [self.navigationController pushViewController:playcontroller animated:YES];
}

-(IBAction)backbtnclick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  VSPlayerViewController.m
//  VideoStream
//
//  Created by Tarum Nadus on 11/16/12.
//  Copyright (c) 2012 MobileTR. All rights reserved.
//

#import "VSPlayerViewController.h"
#import "VSGLES2View.h"
#import "VSStreamInfoView.h"

#import <MediaPlayer/MediaPlayer.h>

NSString *kVSPlayerStateChangedNotification = @"VSPlayerStateChangedNotification";
NSString *kVSPlayerStateChangedUserInfoStateKey = @"state";
NSString *kVSPlayerStateChangedUserInfoErrorCodeKey = @"errCode";

#define BAR_BUTTON_TAG_DONE             1000
#define BAR_BUTTON_TAG_SCALE            1001

#define PANEL_BUTTON_TAG_PP_TOGGLE      2001
#define PANEL_BUTTON_TAG_INFO           2002

static NSString * errorText(VSError errCode);

@interface VSPlayerViewController () {
    
    //UI elements
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_labelBarTitle;
    UIToolbar *_toolBar;
    UIBarButtonItem *_barButtonDone;
    UIBarButtonItem *_barButtonSpaceLeft;
    UIBarButtonItem *_barButtonContainer;
    UIBarButtonItem *_barButtonSpaceRight;
    UIBarButtonItem *_barButtonScale;
    UIView *_viewCenteredOnBar;
    NSMutableArray *_toolBarItems;
    UIImageView *_imgViewAudioOnly;
    
    UIView *_viewControlPanel;
    UIImageView *_imgViewControlPanel;
    UILabel *_labelElapsedTime;
    UIButton *_buttonPanelPP;
    UIButton *_buttonPanelInfo;
    UIImageView *_imgViewSpeaker;
    
    MPVolumeView *_volumeSlider;
    
    VSStreamInfoView *_viewInfo;
    
    //Gesture recognizers
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
    UITapGestureRecognizer *_singleTapGestureRecognizer;
    UITapGestureRecognizer *_closeInfoViewGestureRecognizer;
    
    BOOL _panelIsHidden;
    NSTimer *_timerPanelHidden;
    BOOL _closedByUser;
    
    NSTimer *_timerDuration;
    int _duration;
    
    NSTimer *_timerInfoViewUpdate;
    
    //stream related
    NSURL *_contentURL;
    VSDecodeManager *_decodeManager;
    NSDictionary *_decodeOptions;
 }

- (IBAction)onBarButtonsTapped:(id)sender;
- (IBAction)onControlPanelButtonsTapped:(id)sender;

@end

@implementation VSPlayerViewController

@synthesize barTitle = _barTitle;
@synthesize statusBarHidden = _statusBarHidden;
@synthesize back_check_flag = _back_check_flag;
@synthesize check_fullscreen = _check_fullscreen;
- (id)initWithURL:(NSURL *)url decoderOptions:(NSDictionary *)options {
    
    self = [super init];
    if (self) {
        // Custom initialization
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        if(!url) url = [NSURL URLWithString:@"http://url.is.null"];
        _contentURL = [url retain];
        _barTitle = [[url lastPathComponent] retain];
        _decodeOptions = [options retain];
        _panelIsHidden = NO;
        _statusBarHidden = YES;
        _duration = 0;
        _closedByUser = NO;
        
        return self;
    }
    return nil;
}

#pragma mark View life cycle


- (void)loadView
{
    CGRect bounds = CGRectMake(0, 0, 320, 265);
    self.view = [[[UIView alloc] initWithFrame:bounds] autorelease];
    self.view.backgroundColor = [UIColor blackColor];
    /* Control panel: _viewControlPanel */
    int mrgnBtPanel = 10.0;
    int hPanel = 93.0;
    int wPanel = 314.0;
    int yPanel = self.view.bounds.size.height - hPanel - mrgnBtPanel;
    int xPanel = (self.view.bounds.size.width - wPanel)/2.0;
    _viewControlPanel = [[UIView alloc] initWithFrame:CGRectMake(xPanel, yPanel, wPanel, hPanel)];
    _viewControlPanel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _viewControlPanel.contentMode = UIViewContentModeCenter;
    _viewControlPanel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_viewControlPanel];
    
    /* Control panel: _imgViewControlPanel */
    _imgViewControlPanel = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 314.0, 93.0)];
    _imgViewControlPanel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _imgViewControlPanel.contentMode = UIViewContentModeCenter;
    _imgViewControlPanel.backgroundColor = [UIColor clearColor];
    [_viewControlPanel addSubview:_imgViewControlPanel];
    
    /* Control panel: _buttonPanelPP */
    _buttonPanelPP = [[UIButton alloc] initWithFrame:CGRectMake(142.0, 13.0, 30.0, 27.0)];
    _buttonPanelPP.showsTouchWhenHighlighted = YES;
    _buttonPanelPP.tag = PANEL_BUTTON_TAG_PP_TOGGLE;
    [_buttonPanelPP addTarget:self action:@selector(onControlPanelButtonsTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_viewControlPanel addSubview:_buttonPanelPP];
    
    /* Control panel: _buttonPanelInfo */
    _buttonPanelInfo = [[UIButton alloc] initWithFrame:CGRectMake(246.0, 11.0, 30.0, 30.0)];
    _buttonPanelInfo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _buttonPanelInfo.showsTouchWhenHighlighted = YES;
    _buttonPanelInfo.contentMode = UIViewContentModeCenter;
    _buttonPanelInfo.tag = PANEL_BUTTON_TAG_INFO;
    [_buttonPanelInfo addTarget:self action:@selector(onControlPanelButtonsTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[_viewControlPanel addSubview:_buttonPanelInfo];
    
    /* Control panel: _imgViewSpeaker */
    _imgViewSpeaker = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 50.0, 21.0, 23.0)];
    _imgViewSpeaker.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_viewControlPanel addSubview:_imgViewSpeaker];
    
    /* Control panel: _labelElapsedTime */
    _labelElapsedTime = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 16.0, 64.0, 21.0)];
    _labelElapsedTime.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _labelElapsedTime.contentMode = UIViewContentModeLeft;
    _labelElapsedTime.text = @"00:00";
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
        //running on iOS 6.0 or higher
        _labelElapsedTime.textAlignment = NSTextAlignmentLeft;
    } else {
        //running on iOS 5.x
        _labelElapsedTime.textAlignment = UITextAlignmentLeft;
    }
#else
    _labelElapsedTime.textAlignment = UITextAlignmentLeft;
#endif
    _labelElapsedTime.backgroundColor = [UIColor clearColor];
    _labelElapsedTime.opaque = NO;
    _labelElapsedTime.textColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1.000];
    _labelElapsedTime.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    [_viewControlPanel addSubview:_labelElapsedTime];
    
    /* Control panel: _volumeSlider */
    _volumeSlider = [[MPVolumeView alloc] initWithFrame:CGRectMake(53.0, 51.0, 219.0, 23.0)];
    _volumeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_viewControlPanel addSubview:_volumeSlider];
    
    /* Toolbar on top: _toolBar */
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    _toolBar.autoresizesSubviews = YES;
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _toolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:_toolBar];
    _toolBarItems = [NSMutableArray array];
    
    /* Toolbar on top: _barButtonDone */
    _barButtonScale = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(onBarButtonsTapped:)];
    _barButtonScale.tag = BAR_BUTTON_TAG_SCALE;
    [_toolBarItems addObject:_barButtonScale];
    
    /* Toolbar on top: _barButtonSpaceLeft */
    _barButtonSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolBarItems addObject:_barButtonSpaceLeft];
    
    /* Toolbar on top: _viewCenteredOnBar */
    _viewCenteredOnBar = [[UIView alloc] initWithFrame:CGRectMake(100.0, 6.0, 120.0, 33.0)];
    _viewCenteredOnBar.autoresizesSubviews = YES;
    _viewCenteredOnBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _viewCenteredOnBar.backgroundColor = [UIColor clearColor];
    
    /* Toolbar on top: _labelBarTitle */
    _labelBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(28.0, 6.0, 92.0, 21.0)];
    _labelBarTitle.autoresizesSubviews = YES;
    _labelBarTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _labelBarTitle.backgroundColor = [UIColor clearColor];
    _labelBarTitle.contentMode = UIViewContentModeLeft;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
        //running on iOS 6.0 or higher
        _labelBarTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _labelBarTitle.minimumScaleFactor = 0.3;
        _labelBarTitle.textAlignment = NSTextAlignmentCenter;
    } else {
        //running on iOS 5.x
        _labelBarTitle.lineBreakMode = UILineBreakModeTailTruncation;
        _labelBarTitle.minimumFontSize = 10.0;
        _labelBarTitle.textAlignment = UITextAlignmentCenter;
    }
#else
    _labelBarTitle.lineBreakMode = UILineBreakModeTailTruncation;
    _labelBarTitle.minimumFontSize = 10.0;
    _labelBarTitle.textAlignment = UITextAlignmentCenter;
#endif
    
    
    _labelBarTitle.numberOfLines = 1;
    _labelBarTitle.opaque = NO;
    _labelBarTitle.backgroundColor = [UIColor clearColor];
    _labelBarTitle.shadowOffset = CGSizeMake(0.0, -1.0);
    _labelBarTitle.textColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1.000];
    _labelBarTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    _labelBarTitle.text = TR(@"Loading...");
    [_viewCenteredOnBar addSubview:_labelBarTitle];
    
    /* Toolbar on top: _activityIndicator */
    
    
    /* Toolbar on top: _barButtonContainer */
    _barButtonContainer = [[UIBarButtonItem alloc] initWithCustomView:_viewCenteredOnBar];
    [_toolBarItems addObject:_barButtonContainer];
    
    /* Toolbar on top: _barButtonSpaceRight */
    _barButtonSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:NULL action:NULL];
    [_toolBarItems addObject:_barButtonSpaceRight];
    
    /* Toolbar on top: _barButtonScale */
    _barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onBarButtonsTapped:)];
    _barButtonDone.style = UIBarButtonItemStylePlain;
    _barButtonDone.tag = BAR_BUTTON_TAG_DONE;
   
//    [_toolBarItems addObject:_barButtonDone];

//    [_toolBar setItems:_toolBarItems];
    
    /* Center subviews: _imgViewAudioOnly */
    int hAudioOnly = 156.0;
    int wAudioOnly = 185.0;
    int yAudioOnly = (self.view.bounds.size.height - hAudioOnly)/2.0;
    int xAudioOnly = (self.view.bounds.size.width - wAudioOnly)/2.0;
    _imgViewAudioOnly = [[UIImageView alloc] initWithFrame:CGRectMake(xAudioOnly, yAudioOnly, wAudioOnly, hAudioOnly)];
    _imgViewAudioOnly.autoresizesSubviews = YES;
    _imgViewAudioOnly.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _imgViewAudioOnly.contentMode = UIViewContentModeCenter;
    _imgViewAudioOnly.hidden = YES;
    _imgViewAudioOnly.opaque = NO;
    [self.view addSubview:_imgViewAudioOnly];
    
    int hViewInfo = 230.0;
    int hViewInfoMargin = 10.0;
    int wViewInfo = 280.0;
    int yViewInfo = (self.view.bounds.size.height - hViewInfo)/2.0 - hViewInfoMargin;
    int xViewInfo = (self.view.bounds.size.width - wViewInfo)/2.0;
    _viewInfo = [[VSStreamInfoView alloc] initWithFrame:CGRectMake(xViewInfo, yViewInfo, wViewInfo, hViewInfo)];
    _viewInfo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _viewInfo.contentMode = UIViewContentModeCenter;
    _viewInfo.hidden = YES;
    [self addGesturesToInfoView:_viewInfo];
    [self.view addSubview:_viewInfo];
    /* set the images */
    _imgViewControlPanel.image = [UIImage imageNamed:@"VSImages.bundle/vs-panel-bg.png"];
    _imgViewSpeaker.image = [UIImage imageNamed:@"VSImages.bundle/vs-panel-button-speaker.png"];
    _imgViewAudioOnly.image = [UIImage imageNamed:@"VSImages.bundle/vs-audio-only.png"];
    [_buttonPanelPP setImage:[UIImage imageNamed:@"VSImages.bundle/vs-panel-button-play.png"] forState:UIControlStateNormal];
    [_buttonPanelInfo setImage:[UIImage imageNamed:@"VSImages.bundle/vs-panel-button-info.png"] forState:UIControlStateNormal];
    [_barButtonScale setImage:[UIImage imageNamed:@"VSImages.bundle/vs-bar-button-zoom-out.png"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    [super viewWillAppear:animated];
    if (_statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    _activityIndicator.frame = CGRectMake(self.view.frame.size.width/2-30, self.view.frame.size.height/2-45,50, 50);
    saverect = self.view.bounds;
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.backgroundColor = [UIColor clearColor];
    [_activityIndicator startAnimating];
    [self.view addSubview:_activityIndicator];

    [self setPanelButtonsEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        _decodeManager = [[VSDecodeManager alloc] init];
        _decodeManager.delegate = self;
        
//        [_decodeManager setLogLevel:kVSLogLevelAll];
        
        VSError error = [_decodeManager connectWithStreamURL:_contentURL options:_decodeOptions];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (error == kVSErrorNone) {
                //create glview to render video pictures
                _renderView = [[VSGLES2View alloc] initWithFrame:self.view.bounds];
           
                if ([_renderView initGLWithDecodeManager:_decodeManager] == kVSErrorNone) {
                    [self.view insertSubview:_renderView atIndex:0];
                    [self addGesturesToGLView:_renderView];
                    
                    //readframes and start decoding
                    [_decodeManager performSelector:@selector(start)];
                    return;
                } else
                    goto onError;
            } else
                goto onError;
            
        onError:
            [self performSelector:@selector(close:) withObject:nil afterDelay:1.0];
        });
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)addGesturesToGLView:(UIView *)viewGesture {
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [viewGesture addGestureRecognizer:_doubleTapGestureRecognizer];
    _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [_singleTapGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];
    [viewGesture addGestureRecognizer:_singleTapGestureRecognizer];
}

- (void)removeGesturesFromGLView:(UIView *)viewGesture {
    if (_singleTapGestureRecognizer) {
        [viewGesture removeGestureRecognizer:_singleTapGestureRecognizer];
    }
    if (_doubleTapGestureRecognizer) {
        [viewGesture removeGestureRecognizer:_doubleTapGestureRecognizer];
    }
}

- (void)addGesturesToInfoView:(UIView *)viewGesture {
    _closeInfoViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInfoView)];
    _closeInfoViewGestureRecognizer.numberOfTapsRequired = 1;
    [viewGesture addGestureRecognizer:_closeInfoViewGestureRecognizer];
}

- (void)removeGesturesFromInfoView:(UIView *)viewGesture {
    if (_closeInfoViewGestureRecognizer) {
        [viewGesture removeGestureRecognizer:_closeInfoViewGestureRecognizer];
    }
}

#pragma mark View controller rotation methods & callbacks

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
- (BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIDeviceOrientationPortraitUpsideDown);
}

#pragma mark Subview & timer actions

- (IBAction)onBarButtonsTapped:(id)sender {
    
    int tag = [(UIBarButtonItem *)sender tag];
    
    if (tag == BAR_BUTTON_TAG_DONE) {
                [self performSelector:@selector(close:) withObject:sender afterDelay:0.1];
    } else if (tag == BAR_BUTTON_TAG_SCALE) {
        [self performSelector:@selector(scale)];
    }
}

- (IBAction)onControlPanelButtonsTapped:(id)sender {
    int tag = [(UIButton *)sender tag];
    if (tag == PANEL_BUTTON_TAG_PP_TOGGLE) {
        [self performSelector:@selector(togglePlay)];
    } else if (tag == PANEL_BUTTON_TAG_INFO) {
        [self performSelector:@selector(showInfoView)];
    }
    [self showControlPanel:YES];
}

- (void)showControlPanel:(BOOL)show
{
    _panelIsHidden = !show;
    
    if (_timerPanelHidden && [_timerPanelHidden isValid]) {
        [_timerPanelHidden invalidate];
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGFloat alpha = _panelIsHidden ? 0 : 1;
                         _toolBar.alpha = alpha;
                         _viewControlPanel.alpha = alpha;
                     }
                     completion:nil];
    
    if (!_panelIsHidden) {
        [_timerPanelHidden release];
        _timerPanelHidden = nil;
        _timerPanelHidden = [[NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(onTimerPanelHiddenFired:) userInfo:nil repeats:NO] retain];
    }
}

- (void)setPanelButtonsEnabled:(BOOL)enabled {
    _buttonPanelPP.enabled = enabled;
    _buttonPanelInfo.enabled = enabled;
}

- (void)startDurationTimer {
    [self stopDurationTimer];
    _timerDuration = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimerDurationFired:) userInfo:nil repeats:YES] retain];
}

- (void)stopDurationTimer {
    if (_timerDuration && [_timerDuration isValid]) {
        [_timerDuration invalidate];
    }
    [_timerDuration release];
    _timerDuration = nil;
}


- (void)showInfoView {
    if (_viewInfo.hidden) {
        _viewInfo.alpha = 0.0;
        _viewInfo.hidden = NO;
        
        NSMutableDictionary *streamInfo = [_decodeManager streamInfo];
        NSNumber *downloadedData = [NSNumber numberWithUnsignedLong:_decodeManager.totalBytesDownloaded];
        [streamInfo setObject:downloadedData forKey:STREAMINFO_KEY_DOWNLOAD];
        [_viewInfo updateSubviewsWithInfo:streamInfo];
        
        [UIView animateWithDuration:0.4 animations:^{
            _viewInfo.alpha = 1.0;
        }];
        
        if (_timerInfoViewUpdate && [_timerInfoViewUpdate isValid]) {
            [_timerInfoViewUpdate invalidate];
        }
        [_timerInfoViewUpdate release];
        _timerInfoViewUpdate = nil;
        
        _timerInfoViewUpdate = [[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateStreamInfoView) userInfo:nil repeats:YES] retain];
    }
}

- (void)hideInfoView {
    if (!_viewInfo.hidden) {
        [UIView animateWithDuration:0.4 animations:^{
            _viewInfo.alpha = 0.0;
        } completion:^(BOOL finished) {
            _viewInfo.hidden = YES;
        }];
        if (_timerInfoViewUpdate && [_timerInfoViewUpdate isValid]) {
            [_timerInfoViewUpdate invalidate];
        }
        [_timerInfoViewUpdate release];
        _timerInfoViewUpdate = nil;
    }
}

- (void)updateStreamInfoView {
    NSMutableDictionary *streamInfo = [_decodeManager streamInfo];
    NSNumber *downloadedData = [NSNumber numberWithUnsignedLong:_decodeManager.totalBytesDownloaded];
    [streamInfo setObject:downloadedData forKey:STREAMINFO_KEY_DOWNLOAD];
    [_viewInfo updateSubviewsWithInfo:streamInfo];
}

#pragma mark Timers callbacks

- (void)onTimerPanelHiddenFired:(NSTimer *)timer {
    [self showControlPanel:NO];
}

- (void)onTimerDurationFired:(NSTimer *)timer {
    _duration = _duration + 1;
    _labelElapsedTime.text = [NSString stringWithFormat:@"%02d:%02d", _duration/60, (_duration % 60)];
}

#pragma mark Player action methods

- (void)togglePlay {
    [_decodeManager performSelector:@selector(streamTogglePause)];
}

- (void)close:(id)sender {
  
    [self stopDurationTimer];
  
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self removeGesturesFromGLView:_renderView];
    [self removeGesturesFromGLView:_viewInfo];
    [self togglePlay];
    _closedByUser = (sender) ? YES : NO;
    [_decodeManager abort:_closedByUser];
    [_renderView shutdown];
    [self.view removeFromSuperview];
  
}

- (void)closeone:(id)sender
{
}


- (void)scale {
    if (_renderView.contentMode == UIViewContentModeScaleAspectFit){
       
        _renderView.contentMode = UIViewContentModeScaleAspectFill;
        
//        if (UIDeviceOrientationIsLandscape([self interfaceOrientation]))
//            _renderView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
//        else
//            _renderView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
//        
        _check_fullscreen = true;
        [_barButtonScale setImage:[UIImage imageNamed:@"VSImages.bundle/vs-bar-button-zoom-in.png"]];
    }
    else {
      
        _renderView.contentMode = UIViewContentModeScaleAspectFit;
//        _renderView.frame = saverect;
        _check_fullscreen = false;
        [_barButtonScale setImage:[UIImage imageNamed:@"VSImages.bundle/vs-bar-button-zoom-out.png"]];
    }
    _toolBar.frame = CGRectMake(0, 0, _renderView.frame.size.width, 44);
}

#pragma mark - gesture recognizer

- (void)handleTap: (UITapGestureRecognizer *) sender {
    //double tap click event
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender == _singleTapGestureRecognizer) {
            [self showControlPanel:_panelIsHidden];
        }
    }
}


#pragma mark - VSDecoder delegate methods

- (void)decoderStateChanged:(VSDecoderState)state errorCode:(VSError)errCode {
    
    if (state == kVSDecoderStateConnecting) {
        VSLog(kVSLogLevelStateChanges, @"Trying to connect to %@", [[_contentURL description]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    } else if (state == kVSDecoderStateConnected) {
        VSLog(kVSLogLevelStateChanges, @"Connected to the stream server");
    } else if (state == kVSDecoderStateInitialLoading) {
        VSLog(kVSLogLevelStateChanges, @"Trying to get packets");
    } else if (state == kVSDecoderStateReadyToPlay) {
        VSLog(kVSLogLevelStateChanges, @"Got enough packets to start playing");
        [_activityIndicator setHidden:YES];
        
        _labelBarTitle.frame = _viewCenteredOnBar.bounds;

        _labelBarTitle.text = @"Playing";

        [self startDurationTimer];
        [self setPanelButtonsEnabled:YES];
    } else if (state == kVSDecoderStateBuffering) {
        VSLog(kVSLogLevelStateChanges, @"Buffering now...");
    } else if (state == kVSDecoderStatePlaying) {
        VSLog(kVSLogLevelStateChanges, @"Playing now...");
        [_buttonPanelPP setImage:[UIImage imageNamed:@"VSImages.bundle/vs-panel-button-pause.png"] forState:UIControlStateNormal];
        [self showControlPanel:NO];
    } else if (state == kVSDecoderStatePaused) {
        VSLog(kVSLogLevelStateChanges, @"Paused now...");
        [_buttonPanelPP setImage:[UIImage imageNamed:@"VSImages.bundle/vs-panel-button-play.png"] forState:UIControlStateNormal];
    } else if (state == kVSDecoderStateStoppedByUser) {
        VSLog(kVSLogLevelStateChanges, @"Stopped now...");
    } else if (state == kVSDecoderStateConnectionFailed) {
        
        VSLog(kVSLogLevelStateChanges, @"Player closed - %@",errorText(errCode));
    } else if (state == kVSDecoderStateGotAudioStreamInfo) {
        if (errCode != kVSErrorNone) {
            VSLog(kVSLogLevelStateChanges, @"Got audio stream error -> %@", errorText(errCode));
        }
    } else if (state == kVSDecoderStateGotVideoStreamInfo) {
        if (errCode != kVSErrorNone) {
            _imgViewAudioOnly.hidden = NO;
            VSLog(kVSLogLevelStateChanges, @"Got video stream error -> %@", errorText(errCode));
        }
    } else if (state == kVSDecoderStateStoppedWithError) {
        [self performSelector:@selector(close:) withObject:NULL];
        if (errCode == kVSErrorStreamReadError) {
            
            VSLog(kVSLogLevelStateChanges, @"Player closed - %@",errorText(errCode));
        } else if (errCode == kVSErrorStreamEOFError) {
            VSLog(kVSLogLevelStateChanges, @"%@, stopped now...", errorText(errCode));
        }
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state],kVSPlayerStateChangedUserInfoStateKey,
                              [NSNumber numberWithInt:errCode],kVSPlayerStateChangedUserInfoErrorCodeKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVSPlayerStateChangedNotification object:nil userInfo:userInfo];
    
}

#pragma mark - Memory events & deallocation

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [_barButtonSpaceLeft release];
    _barButtonSpaceLeft = nil;
    [_barButtonContainer release];
    _barButtonContainer = nil;
    [_barButtonSpaceRight release];
    _barButtonSpaceRight = nil;
    [_viewCenteredOnBar release];
    _viewCenteredOnBar = nil;
    [_volumeSlider release];
    _volumeSlider = nil;
    [_activityIndicator release];
    _activityIndicator = nil;
    [_labelBarTitle release];
    _labelBarTitle = nil;
    [_viewControlPanel release];
    _viewControlPanel = nil;
    [_toolBar release];
    _toolBar = nil;
    [_barButtonScale release];
    _barButtonScale = nil;
   // [_barButtonDone release];
    //_barButtonDone = nil;
    [_labelElapsedTime release];
    _labelElapsedTime = nil;
    [_buttonPanelPP release];
    _buttonPanelPP = nil;
    [_buttonPanelInfo release];
    _buttonPanelInfo = nil;
    [_imgViewControlPanel release];
    _imgViewControlPanel = nil;
    [_imgViewSpeaker release];
    _imgViewSpeaker = nil;
    [_imgViewAudioOnly release];
    _imgViewAudioOnly = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    
    VSLog(kVSLogLevelStateChanges, @"VSPlayerViewController is deallocated - no more state changes captured...");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([_renderView superview])
        [_renderView removeFromSuperview];
    
    _decodeManager.delegate = nil;
    [_decodeManager shutdown];
    [_decodeManager release];
    

    [_timerInfoViewUpdate release];
    [_viewInfo release];
    [_volumeSlider release];
    [_barTitle release];
    [_decodeOptions release];
    
    [_singleTapGestureRecognizer release];
    [_doubleTapGestureRecognizer release];
    [_closeInfoViewGestureRecognizer release];
    [_renderView release];
    [_contentURL release];
    [_activityIndicator release];
    [_labelBarTitle release];
    [_viewControlPanel release];
    [_toolBar release];
    [_barButtonScale release];
   // [_barButtonDone release];
    [_labelElapsedTime release];
    [_buttonPanelPP release];
    [_buttonPanelInfo release];
    [_imgViewControlPanel release];
    [_imgViewSpeaker release];
    [_imgViewAudioOnly release];
    [_barButtonSpaceRight release];
    [_barButtonContainer release];
    [super dealloc];
}

@end

#pragma mark - Error descriptions

static NSString * errorText(VSError errCode)
{
    switch (errCode) {
        case kVSErrorNone:
            return @"";
            
        case kVSErrorUnsupportedProtocol:
            return TR(@"Protocol is not supported");
            
        case kVSErrorOpenStream:
            return TR(@"Failed to connect to the stream server");
            
        case kVSErrorStreamInfoNotFound:
            return TR(@"Can not find any stream info");
            
        case kVSErrorStreamsNotAvailable:
            return TR(@"Can not open any A-V stream");
            
        case kVSErrorAudioCodecNotFound:
            return TR(@"Audio codec is not found");
            
        case kVSErrorAudioStreamNotFound:
            return TR(@"Audio stream is not found");
            
        case kVSErrorVideoCodecNotFound:
            return TR(@"Video codec is not found");
            
        case kVSErrorVideoStreamNotFound:
            return TR(@"Video stream is not found");
            
        case kVSErrorAudioCodecNotOpened:
            return TR(@"Audio codec can not be opened");
            
        case kVSErrorVideoCodecNotOpened:
            return TR(@"Video codec can not be opened");
            
        case kVSErrorAudioAllocateMemory:
            return TR(@"Can not allocate memory for Audio");
            
        case kVSErrorVideoAllocateMemory:
            return TR(@"Can not allocate memory for Video");
            
        case kVSErrorUnsupportedAudioFormat:
            return TR(@"Audio format is not supported");
            
        case kVSErroSetupScaler:
            return TR(@"Unable to setup scaler");
            
        case kVSErrorStreamReadError:
            return TR(@"Can not read from stream server");
            
        case kVSErrorStreamEOFError:
            return TR(@"End of stream");
    }
    return nil;
}

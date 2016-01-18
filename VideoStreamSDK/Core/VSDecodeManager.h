//
//  VSDecodeManager.h
//  VideoStream
//
//  Created by Tarum Nadus on 11/16/12.
//  Copyright (c) 2012 MobileTR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSDecodeManagerConstants.h"

//stream info data keys
extern NSString *STREAMINFO_KEY_CONNECTION;
extern NSString *STREAMINFO_KEY_DOWNLOAD;
extern NSString *STREAMINFO_KEY_BITRATE;
extern NSString *STREAMINFO_KEY_AUDIO;
extern NSString *STREAMINFO_KEY_VIDEO;


//Video Stream Error enumerations
typedef enum {
    kVSErrorNone = 0,
    kVSErrorUnsupportedProtocol,
    kVSErrorOpenStream,
    kVSErrorStreamInfoNotFound,
    kVSErrorStreamsNotAvailable,
    kVSErrorAudioStreamNotFound,
    kVSErrorVideoStreamNotFound,
    kVSErrorAudioCodecNotFound,
    kVSErrorVideoCodecNotFound,
    kVSErrorAudioCodecNotOpened,
    kVSErrorUnsupportedAudioFormat,
    kVSErrorVideoCodecNotOpened,
    kVSErrorAudioAllocateMemory,
    kVSErrorVideoAllocateMemory,
    kVSErrorStreamReadError,
    kVSErrorStreamEOFError,
    kVSErroSetupScaler,
} VSError;

//Decoder state enumerations
typedef enum {
    kVSDecoderStateNone = 0,
    kVSDecoderStateConnecting,
    kVSDecoderStateConnected,
    kVSDecoderStateConnectionFailed,
    kVSDecoderStateGotAudioStreamInfo,
    kVSDecoderStateGotVideoStreamInfo,
    kVSDecoderStateInitialLoading,
    kVSDecoderStateReadyToPlay,
    kVSDecoderStateBuffering,
    kVSDecoderStatePlaying,
    kVSDecoderStatePaused,
    kVSDecoderStateStoppedByUser,
    kVSDecoderStateStoppedWithError,
} VSDecoderState;

@protocol VSDecoderDelegate;

@interface VSDecodeManager : NSObject {
    BOOL _streamIsPaused;
    int _abortIsRequested;
    int _readPauseCode;
    BOOL _decoderReady;

    unsigned long _totalBytesDownloaded;
    NSMutableDictionary *_streamInfo;
    
    NSObject<VSDecoderDelegate> *_delegate;

}

/* Funtion declerations */

/* initialize decoder */
- (id)init;

/* shutdown engine */
- (void)shutdown;

/* conntect to stream URL with decode options */
- (VSError)connectWithStreamURL:(NSURL*)url options:(NSDictionary *)options;

/* Actions to control stream */
- (void)streamTogglePause;
- (void)pause;
- (void)abort:(int)byUser;

/* AV syncing due to master clock */
- (double)masterClock;
/*  AV syncing diff between audio & video clock */
- (double)clockDifference;

/* Variable declerations */
@property (nonatomic, readonly) BOOL streamIsPaused;
@property (nonatomic, readonly) int abortIsRequested;
@property (nonatomic, readonly) int readPauseCode;
@property (nonatomic, readonly) BOOL decoderReady;
@property (nonatomic, readonly) NSUInteger frameWidth;
@property (nonatomic, readonly) NSUInteger frameHeight;
@property (nonatomic, readonly) BOOL appIsInBackgroundNow;
@property (nonatomic, readonly) unsigned long totalBytesDownloaded;
@property (nonatomic, readonly) NSMutableDictionary *streamInfo;
@property (nonatomic, assign) NSObject<VSDecoderDelegate> *delegate;

@end

@protocol VSDecoderDelegate<NSObject>
@required
- (void)decoderStateChanged:(VSDecoderState)state errorCode:(VSError)errCode;
@end


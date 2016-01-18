//
//  VSDecodeManagerConstants.h
//  VideoStream
//
//  Created by Tarum Nadus on 03.01.2013.
//  Copyright (c) 2013 MobileTR. All rights reserved.
//

#ifndef VideoStream_VSDecodeManagerConstants_h
#define VideoStream_VSDecodeManagerConstants_h

#include <libavcodec/avcodec.h>

#pragma mark
//Language properties
#ifndef RTL
#define TR(A) NSLocalizedString((A), @"")
#else
#define TR(A) [NSLocalizedString((A), @"") stringReversed]
#endif

#pragma mark
//Audio & Video queue sizes
#define VIDEO_PICTURE_QUEUE_SIZE            4
#define MAX_QUEUE_SIZE                      15 * 1024 * 1024
#define MIN_FRAMES_TO_START_PLAYING         15 /* get packets till this number, higher value increases buffering time */
#define READ_ERROR_MAX_TRY_COUNT            5 /* must be greater than 1 */
#define CONFIG_RTSP_DEMUXER                 1
#define CONFIG_MMSH_PROTOCOL                1


#pragma mark
//Audio&Video Sync threadholds
#define AV_SYNC_THRESHOLD                   0.01
#define AV_NOSYNC_THRESHOLD                 10.0
#define AV_SYNC_LOG_FREQUENCY               0.01


#pragma mark
//Log definitions & levels
typedef enum {
	kVSLogLevelDisable = 0,
	kVSLogLevelStateChanges = 1,
	kVSLogLevelDecoder = 2,
	kVSLogLevelDecoderExtra = 4,
    kVSLogLevelOpenGL = 8,
	kVSLogLevelAVSync = 16,
	kVSLogLevelAll = 31,
} VSLogLevel;

#ifdef DEBUG
//#define log_lvl   (kVSLogLevelStateChanges | kVSLogLevelDecoder | kVSLogLevelOpenGL)
#define log_lvl     kVSLogLevelAll
#else
#define log_lvl     (kVSLogLevelDisable)

#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif

#endif

#define VSLog(A, ...) ((A & log_lvl) ? NSLog(__VA_ARGS__) : NSLog(@"") )
#define VSLOG_PKT_COUNT_SHOW_FREQUENCY        0.001

#endif

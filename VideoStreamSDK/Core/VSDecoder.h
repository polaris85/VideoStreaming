//
//  VSDecoder.h
//  VideoStream
//
//  Created by Tarum Nadus on 31.12.2012.
//  Copyright (c) 2012 MobileTR. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/opt.h>
#include <pthread.h>


@interface VSDecoder : NSObject {
    AVCodecContext* _codecContext;
    AVCodec* _codec;
    AVStream* _stream;
    NSInteger _streamId;

    NSMutableArray *_pktQueue;/* queue including encoded data packets */
    long _pktQueueSize; /** queue size */

    //mutex
    pthread_mutex_t _mutexPkt;
    pthread_cond_t _condPkt;

    //manager
    id _manager;
}

/* init with codec context */
- (id)initWithCodecContext:(AVCodecContext*)cdcCtx stream:(AVStream *)strm streamId:(NSInteger)sId;

/* end threads */
- (void)unlockQueues;

/* add raw data media packet */
- (void)addPacket:(AVPacket*)packet;

/* clear buffers */
- (void)clearBuffers;

/* mutex & condition for managing packets processing priority */
- (pthread_mutex_t*)mutexPkt;
- (pthread_cond_t*)condPkt;


@property (nonatomic, readonly) NSMutableArray *pktQueue;
@property (nonatomic, readonly) long pktQueueSize;
@property (nonatomic, readonly) NSInteger streamId;
@property (nonatomic, assign)   id manager;

@end

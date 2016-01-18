//
//  MyPacket.h
//  MMSTv
//
//  Created by Tarum Nadus on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libavcodec/avcodec.h>

@interface VSPacket : NSObject {
    int _size;
    int16_t* _samples;
    double _pts;
    double _dts;
}

- (id) initWithPkt:(AVPacket *) pkt;

@property (nonatomic, readonly) int size;
@property (nonatomic, readonly) int16_t* samples;
@property (nonatomic, readonly) double pts;
@property (nonatomic, readonly) double dts;

@end

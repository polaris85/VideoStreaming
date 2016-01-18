//
//  VideoFrame.h
//  MMSTv
//
//  Created by Tarum Nadus on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VSColorPlane : NSObject

@property (nonatomic, assign) int size;
@property (nonatomic, assign) UInt8 *data;

@end

@interface VSVideoFrame : NSObject {
    int width;
    int height;
    double pts;                                  ///< presentation time stamp for thispicture
    double duration;                             ///< expected duration of the frame
    int64_t pos;                                 ///< byte position in file
    int skip;
    float aspectRatio;

    VSColorPlane *_pLuma;
    VSColorPlane *_pChromaB;
    VSColorPlane *_pChromaR;
}

@property(nonatomic, assign) int width;
@property(nonatomic, assign) int height;
@property(nonatomic, assign) float aspectRatio;

@property(nonatomic, assign) double pts;
@property(nonatomic, assign) double duration;
@property(nonatomic, assign) int64_t pos;
@property(nonatomic, assign) int skip;

@property (nonatomic, assign) VSColorPlane *pLuma;
@property (nonatomic, assign) VSColorPlane *pChromaB;
@property (nonatomic, assign) VSColorPlane *pChromaR;

@end

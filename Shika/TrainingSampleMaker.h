//
//  TrainingSampleMaker.h
//  Shika
//
//  Created by Chamin Morikawa on 12/15/14.
//  Copyright (c) 2014 Yubi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainingSampleMaker : NSObject

// we need quite a few setters
// using the options needed for making samples from one
-(void)setSampleSizeX:(NSInteger)size;
-(void)setSampleSizeY:(NSInteger)size;
-(void)setPreprocessedImageList:(NSArray*)array;
-(void)setSamplesPerImage:(NSInteger)count;
-(void)setMaxAngleX:(float)angle;
-(void)setMaxAngleY:(float)angle;
-(void)setMaxAngleZ:(float)angle;
-(void)setIntensityDeviation:(NSInteger)value;
-(void)setNegativeDataFileURL:(NSURL*)url;
-(void)setTempFolderURL:(NSURL*)url;
-(void)setOutputFileURL:(NSURL*)url;

// generate samples for each image
-(void)generateTrainingSamplesForImageAtIndex:(NSInteger)idx;
// merge everything into one sample file
-(void)mergeTrainingSamples;

@end

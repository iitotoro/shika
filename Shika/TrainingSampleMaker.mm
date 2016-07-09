//
//  TrainingSampleMAker.m
//  Shika
//
//  Created by Chamin Morikawa on 12/15/14.
//  Copyright (c) 2014 Yubi. All rights reserved.
//

#import "TrainingSampleMaker.h"

#include "cvsamples.h"
#include "cvhaartraining.h"
/*
// opencv
#include <opencv2/opencv.hpp>
// others needed for sample merging
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
 */

@implementation TrainingSampleMaker {
    NSInteger sampleSizeX;
    NSInteger sampleSizeY;
    NSArray* preprocessedImageList;
    NSInteger samplesPerImage;
    float maxAngleX;
    float maxAngleY;
    float maxAngleZ;
    NSInteger intensityDeviation;
    NSURL* negativeImageDataFileURL;
    NSURL* tempFolderURL;
    NSURL* outputFileURL;
}

-(id)init {
    self = [super init];
    return self;
}

#pragma mark - Setters
-(void)setSampleSizeX:(NSInteger)size {
    sampleSizeX = size;
}

-(void)setSampleSizeY:(NSInteger)size {
    sampleSizeY = size;
}

-(void)setPreprocessedImageList:(NSArray*)array {
    preprocessedImageList = [[NSArray alloc] initWithArray:array copyItems:YES];
}

-(void)setSamplesPerImage:(NSInteger)count {
    samplesPerImage = count;
}

-(void)setMaxAngleX:(float)angle {
    maxAngleX = angle;
}

-(void)setMaxAngleY:(float)angle {
    maxAngleY = angle;
}

-(void)setMaxAngleZ:(float)angle {
    maxAngleZ = angle;
}

-(void)setIntensityDeviation:(NSInteger)value {
    intensityDeviation = value;
}

-(void)setNegativeDataFileURL:(NSURL*)url {
    negativeImageDataFileURL = url;
}

-(void)setTempFolderURL:(NSURL*)url {
    tempFolderURL = url;
}

-(void)setOutputFileURL:(NSURL*)url {
    outputFileURL = url;
}

#pragma mark - SampleGeneration
// generate samples for each image
-(void)generateTrainingSamplesForImageAtIndex:(NSInteger)idx {
    // for now, we will use the command line executable
    NSString* imgFileName = [[preprocessedImageList objectAtIndex:idx] path];
    NSString* sampleCreatorPath = @"/opt/local/bin/";
    NSString* vecFileName = [[tempFolderURL URLByAppendingPathComponent:[NSString stringWithFormat:@"sampleset%ld.vec",(long)idx]] path];
    
    
    // this part gets executed in main
    printf( "Create training samples from single image applying distortions...\n" );
    
    /* original call
    cvCreateTrainingSamples( vecname, imagename, bgcolor, bgthreshold, bgfilename,
                            num, invert, maxintensitydev,
                            maxxangle, maxyangle, maxzangle,
                            showsamples, width, height );
     */
    
    printf( "Done\n" );
    
    // new code
    cvCreateTrainingSamples( (const char*)[vecFileName UTF8String], (const char*)[imgFileName UTF8String], 0, 0, (const char*)[[negativeImageDataFileURL path] UTF8String],
                            samplesPerImage, 0, intensityDeviation,
                            maxAngleX, maxAngleY, maxAngleZ,
                            0, sampleSizeX, sampleSizeY );
    
    // Older version - uses command line
    NSString* cmdString = [NSString stringWithFormat:@"%@opencv_createsamples -img %@ -num %ld -bg %@ -vec %@ -maxxangle %f -maxyangle %f -maxzangle %f -maxidev %ld -bgcolor 0 -bgthresh 0 -w %ld -h %ld",sampleCreatorPath,imgFileName,(long)samplesPerImage,[negativeImageDataFileURL path],vecFileName,maxAngleX,maxAngleY,maxAngleZ,(long)intensityDeviation,(long)sampleSizeX,(long)sampleSizeY];
    
    // disabled
    //NSLog(@"%@",cmdString);
    //system([cmdString UTF8String]);
    sleep(1);
}

// merge everything into one sample file
-(void)mergeTrainingSamples {
    char *infoname   = NULL;
    char *outvecname = NULL;
    int showsamples  = 0;
    int width;
    int height;
    
    /*
     if( argc == 1 )
     {
     printf( "Usage: %s\n  <collection_file_of_vecs>\n"
     "  <output_vec_filename>\n"
     "  [-show] [-w <sample_width = %d>] [-h <sample_height = %d>]\n",
     argv[0], width, height );
     return 0;
     }
     */
    
    // prepare file with sample set names
    NSURL* InfoFileURL = [tempFolderURL URLByAppendingPathComponent:@"sampleIndex.txt"];
    // open image folder
    BOOL dir;
    [[NSFileManager defaultManager] fileExistsAtPath:[tempFolderURL path] isDirectory:&dir];
    if(dir)
    {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:tempFolderURL
                                                          includingPropertiesForKeys:@[]
                                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'vec'"];
        [[NSFileManager defaultManager] createFileAtPath:[InfoFileURL path] contents:nil attributes:nil];
        NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:[InfoFileURL path]];
        for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate])
        {
            NSString *str = [NSString stringWithFormat:@"%@\n", [fileURL path]];
            // write to file
            [fh seekToEndOfFile];
            [fh writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    infoname = (char*)[[InfoFileURL path] UTF8String];
    // prepare other parameters
    outvecname = (char*)[[outputFileURL path] UTF8String];
    showsamples = 0;
    width = (int)sampleSizeX;
    height = (int)sampleSizeY;
    
    // actual merging is done here
    icvMergeVecs( infoname, outvecname, showsamples, width, height );

    // remove, or set to 1s
    sleep(5);
}

@end




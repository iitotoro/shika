//
//  cvsamples.h
//  Shika
//
//  Created by Chamin Morikawa on 12/17/14.
//  Copyright (c) 2014 Yubi. All rights reserved.
//

#ifndef Shika_cvsamples_h
#define Shika_cvsamples_h

#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "_cvhaartraining.h"

// later put in a header file
/*
typedef struct CvVecFile
{
    FILE*  input;
    int    count;
    int    vecsize;
    int    last;
    short* vector;
} CvVecFile;
*/

// Write a vec header into the vec file (located at cvsamples.cpp)
void icvWriteVecHeader( FILE* file, int count, int width, int height );
// Write a sample image into file in the vec format (located at cvsamples.cpp)
void icvWriteVecSample( FILE* file, CvArr* sample );
// Append the body of the input vec to the ouput vec
void icvAppendVec( CvVecFile &in, CvVecFile &out, int *showsamples, int winwidth, int winheight );
// Merge vec files
void icvMergeVecs( char* infoname, const char* outvecname, int showsamples, int width, int height );
// added from cvhaartraining.cpp
int icvGetHaarTraininDataFromVecCallback( CvMat* img, void* userdata );

#endif

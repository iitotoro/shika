//
//  PreprocessedSample.m
//  Shika
//
//  Created by Chamin Morikawa on 10/6/14.
//  Copyright (c) 2014 Motion Portrait Inc. All rights reserved.
//

#import "PreprocessedSample.h"
#import <Cocoa/Cocoa.h>

@implementation PreprocessedSample {
    NSString* samplePath;
    CGRect sampleFrame;
}

-(id)initWithImage:(NSURL *)imgURL andAspectRatio:(float)aspectRatio {
    self = [super init];
    // set attributes
    samplePath = [imgURL path];
    NSImage* temp;
    temp = [[NSImage alloc] initWithContentsOfURL:imgURL];
    float imgAspectRatio = temp.size.width/temp.size.height;
    // start by setting this frame
    sampleFrame.origin.x = 0;
    sampleFrame.origin.y = 0;
    sampleFrame.size = temp.size;
    // record frame, accounting for differences
    if (aspectRatio > imgAspectRatio) {
        // cropped too tall
        sampleFrame.size.height = sampleFrame.size.width/aspectRatio;
        sampleFrame.origin.y += (temp.size.height - sampleFrame.size.height)/2.0;
    }
    else
    {
        // too wide or just right
        sampleFrame.size.width = sampleFrame.size.height*aspectRatio;
        sampleFrame.origin.x += (temp.size.width - sampleFrame.size.width)/2.0;
    }
    return self;
}

-(NSString*)getAttributeString {
    return [NSString stringWithFormat:@"%@ 1 %d %d %d %d\n",samplePath, (int)sampleFrame.origin.x, (int)sampleFrame.origin.y, (int)sampleFrame.size.width, (int)sampleFrame.size.height];
}

-(NSString*)getSamplePath {
    return samplePath;
}

@end

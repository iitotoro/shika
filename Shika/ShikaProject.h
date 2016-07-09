//
//  ShikaProject.h
//  Shika
//
//  Created by Chamin Morikawa on 11/26/14.
//  Copyright (c) 2014 Yubi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShikaProject : NSObject<NSCoding>

// constructors
-(id)init;-(id)initWithFile:(NSURL*)fileName;

// saving to file
-(void)saveToFile:(NSURL*)fileName;

// initializers
-(void)initializePreprocessingProperties;
-(void)initializeSamplingProperties;

// setters
-(void)setProjectFolder:(NSURL*)url;
-(void)setCurState:(NSInteger)value;
-(void)setPositiveClassLabel:(NSString*)label;
-(void)setNegativeClassLabel:(NSString*)label;
-(void)setPositiveFolderString:(NSString*)folderString;
-(void)setNegativeFolderString:(NSString*)folderString;
-(void)setPositiveSampleList:(NSMutableArray*)array;
-(void)setNegativeSampleList:(NSMutableArray*)array;
-(void)setSampleAspectX:(NSInteger)value;
-(void)setSampleAspectY:(NSInteger)value;
-(void)setSavedSampleList:(NSArray*)array;
-(void)setSampleSizeX:(NSInteger)size;
-(void)setSampleSizeY:(NSInteger)size;
-(void)setIsMultipleSamplesPerImage:(BOOL)choice;
-(void)setSampleCountPerImage:(NSInteger)count;
-(void)setRotationX:(float)rotation;
-(void)setRotationY:(float)rotation;
-(void)setRotationZ:(float)rotation;
-(void)setMaxIntensityDev:(float)value;

// getters
-(NSURL*)getProjectFolderURL;
-(NSInteger)getState;
-(NSString*)getPositiveClassLabel;
-(NSString*)getNegativeClassLabel;
-(NSString*)getPositiveFolderString;
-(NSString*)getNegativeFolderString;
-(NSArray*)getPositiveSampleList;
-(NSArray*)getNegativeSampleList;
-(NSInteger)getSampleAspectX;
-(NSInteger)getSampleAspectY;
-(NSArray*) getSavedSampleList;
-(NSURL*)getSampleFolderURL;
-(NSURL*)getTempFolderURL;
-(NSInteger)getSampleSizeX;
-(NSInteger)getSampleSizeY;
-(BOOL)getIsMultipleSamplesPerImage;
-(NSInteger)getSampleCountPerImage;
-(float)getRotationX;
-(float)getRotationY;
-(float)getRotationZ;
-(float)getMaxIntensityDev;
-(NSURL*)getSampleFileURL;



@end

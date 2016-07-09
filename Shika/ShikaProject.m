//
//  ShikaProject.m
//  Shika
//
//  Created by Chamin Morikawa on 11/26/14.
//  Copyright (c) 2014 Yubi. All rights reserved.
//

#import "ShikaProject.h"

@implementation ShikaProject {
    // location - all other paths are relative to this location
    NSURL* projectFolder;
    
    // project state
    NSInteger curState;
    
    // state 0 - classifier definition
    NSString* positiveClassLabel;
    NSString* negativeClassLabel;
    NSString* positiveFolderString;
    NSString* negativeFolderString;
    NSArray* positiveSampleList;
    NSArray*negativeSampleList;

    // state 1 - preprocessing training images
    NSInteger sampleAspectX;
    NSInteger sampleAspectY;
    NSArray* savedSampleList;
    
    // state 2 - extracting training samples
    NSInteger sampleSizeX;
    NSInteger sampleSizeY;
    BOOL isMultipleSamplesPerImage;
    NSInteger sampleCountPerImage;
    float rotationX;
    float rotationY;
    float rotationZ;
    NSInteger maxIntensityDev;
    NSString* sampleFilePath;
    
    // state 3 - training
    NSInteger stageCount;
    NSInteger splitCount;
    NSInteger memInMegaBytes;
    BOOL symmetricSamples;
    float minHitRate;
    float maxFPRate;
    float weightTrimming;
    NSInteger haarFeatureType;
    NSInteger boostedClassifierType;
    NSInteger errorEstimation;
    NSString* trainedClassifierPath;
    
    // state 4 - testing
    // add later
}


-(id)init {
    self = [super init];
    // other allocations and initializations
    curState = 0;
    return self;
}

#pragma mark - File Operations
-(id)initWithFile:(NSURL*)fileURL {
    self = [NSKeyedUnarchiver unarchiveObjectWithFile:[fileURL path]];
    return self;
}

-(void)saveToFile:(NSURL*)fileName {
    NSLog(@"%@",[fileName absoluteString]);
    [NSKeyedArchiver archiveRootObject:self toFile:[fileName path]];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    projectFolder = [decoder decodeObjectForKey:@"projectFolder"];
    curState = [decoder decodeIntegerForKey:@"curState"];
    positiveClassLabel = [decoder decodeObjectForKey:@"positiveClassLabel"];
    negativeClassLabel = [decoder decodeObjectForKey:@"negativeClassLabel"];
    positiveFolderString = [decoder decodeObjectForKey:@"positiveFolderString"];
    negativeFolderString = [decoder decodeObjectForKey:@"negativeFolderString"];
    positiveSampleList = [decoder decodeObjectForKey:@"positiveSampleList"];
    negativeSampleList = [decoder decodeObjectForKey:@"negativeSampleList"];
    
    // state 1 - preprocessing training images
    sampleAspectX = [decoder decodeIntegerForKey:@"sampleAspectX"];
    sampleAspectY = [decoder decodeIntegerForKey:@"sampleAspectY"];
    savedSampleList = [decoder decodeObjectForKey:@"savedSampleList"];
    
    // state 2 - extracting training samples
    sampleSizeX = [decoder decodeIntegerForKey:@"sampleSizeX"];
    sampleSizeY = [decoder decodeIntegerForKey:@"sampleSizeY"];
    isMultipleSamplesPerImage = [decoder decodeBoolForKey:@"multipleSamplesPerImage"];
    sampleCountPerImage = [decoder decodeIntegerForKey:@"samplesPerImage"];
    rotationX = [decoder decodeFloatForKey:@"rotationX"];
    rotationY = [decoder decodeFloatForKey:@"rotationY"];
    rotationZ = [decoder decodeFloatForKey:@"rotationZ"];
    maxIntensityDev = [decoder decodeIntegerForKey:@"maxIntensityDev"];
    sampleFilePath = [decoder decodeObjectForKey:@"sampleFilePath"];
    
    // state 3 - training
    stageCount = [decoder decodeIntegerForKey:@"stageCount"];
    splitCount = [decoder decodeIntegerForKey:@"splitCount"];
    memInMegaBytes = [decoder decodeIntegerForKey:@"memInMegaBytes"];
    symmetricSamples = [decoder decodeBoolForKey:@"symmetricSamples"];
    minHitRate = [decoder decodeFloatForKey:@"minHitRate"];
    maxFPRate = [decoder decodeFloatForKey:@"maxFPRate"];
    weightTrimming = [decoder decodeFloatForKey:@"weightTrimming"];
    haarFeatureType = [decoder decodeIntegerForKey:@"haarFeatureType"];
    boostedClassifierType = [decoder decodeIntegerForKey:@"boostedClassifierType"];
    errorEstimation = [decoder decodeIntegerForKey:@"errorEstimation"];
    trainedClassifierPath = [decoder decodeObjectForKey:@"trainedClassifierPath"];
    
    // state 4 - testing
    // add later when ready
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // basic
    [encoder encodeObject:projectFolder forKey:@"projectFolder"];
    [encoder encodeInteger:curState forKey:@"curState"];
    
    // state 0 - define
    [encoder encodeObject:positiveClassLabel forKey:@"positiveClassLabel"];
    [encoder encodeObject:negativeClassLabel forKey:@"negativeClassLabel"];
    [encoder encodeObject:positiveFolderString forKey:@"positiveFolderString"];
    [encoder encodeObject:negativeFolderString forKey:@"negativeFolderString"];
    [encoder encodeObject:positiveSampleList forKey:@"positiveSampleList"];
    [encoder encodeObject:negativeSampleList forKey:@"negativeSampleList"];
    
     // state 1 - preprocessing training images
    [encoder encodeInteger:sampleAspectX forKey:@"sampleAspectX"];
    [encoder encodeInteger:sampleAspectY forKey:@"sampleAspectY"];
    [encoder encodeObject:savedSampleList forKey:@"savedSampleList"];
     
     // state 2 - extracting training samples
    [encoder encodeInteger:sampleSizeX forKey:@"sampleSizeX"];
    [encoder encodeInteger:sampleSizeY forKey:@"sampleSizeY"];
    [encoder encodeBool:isMultipleSamplesPerImage forKey:@"multipleSamplesPerImage"];
    [encoder encodeInteger:sampleCountPerImage forKey:@"samplesPerImage"];
    [encoder encodeFloat:rotationX forKey:@"rotationX"];
    [encoder encodeFloat:rotationY forKey:@"rotationY"];
    [encoder encodeFloat:rotationZ forKey:@"rotationZ"];
    [encoder encodeInteger:maxIntensityDev forKey:@"maxIntensityDev"];
    [encoder encodeObject:sampleFilePath forKey:@"sampleFilePath"];
     
     // state 3 - training
    [encoder encodeInteger:stageCount forKey:@"stageCount"];
    [encoder encodeInteger:splitCount forKey:@"splitCount"];
    [encoder encodeInteger:memInMegaBytes forKey:@"memInMegaBytes"];
    [encoder encodeBool:symmetricSamples forKey:@"symmetricSamples"];
    [encoder encodeFloat:minHitRate forKey:@"minHitRate"];
    [encoder encodeFloat:maxFPRate forKey:@"maxFPRate"];
    [encoder encodeFloat:weightTrimming forKey:@"weightTrimming"];
    [encoder encodeInteger:haarFeatureType forKey:@"haarFeatureType"];
    [encoder encodeInteger:boostedClassifierType forKey:@"boostedClassifierType"];
    [encoder encodeInteger:errorEstimation forKey:@"errorEstimation"];
    [encoder encodeObject:trainedClassifierPath forKey:@"trainedClassifierPath"];

    // stage 4 - testing
    // add later
}

#pragma mark - General
// setters
-(void)setProjectFolder:(NSURL*)url {
    projectFolder = url;
}

-(void)setCurState:(NSInteger)value {
    curState = value;
}

// getters
-(NSURL*)getProjectFolderURL {
    return projectFolder;
}

-(NSInteger)getState {
    return curState;
}

#pragma mark - Define
-(void)setPositiveClassLabel:(NSString*)label {
    positiveClassLabel = [NSString stringWithString:label];
}

-(void)setNegativeClassLabel:(NSString*)label {
    negativeClassLabel = [NSString stringWithString:label];
}

-(void)setPositiveFolderString:(NSString *)folderString {
    positiveFolderString = folderString;
}

-(void)setNegativeFolderString:(NSString *)folderString {
    negativeFolderString = folderString;
}

-(void)setPositiveSampleList:(NSMutableArray*)array {
    positiveSampleList = [[NSArray alloc] initWithArray:array copyItems:YES];
}

-(void)setNegativeSampleList:(NSMutableArray*)array {
    negativeSampleList = [[NSArray alloc] initWithArray:array copyItems:YES];
}


// getters
-(NSString*)getPositiveClassLabel {
    return positiveClassLabel;
}

-(NSString*)getNegativeClassLabel {
    return negativeClassLabel;
}

-(NSString*)getPositiveFolderString {
    return positiveFolderString;
}

-(NSString*)getNegativeFolderString {
    return negativeFolderString;
}

-(NSArray*)getPositiveSampleList {
    return positiveSampleList;
}

-(NSArray*)getNegativeSampleList {
    return negativeSampleList;
}

#pragma mark - Preprocess
// initialization with default values
-(void)initializePreprocessingProperties {
    // this is a good rtio to start with
    sampleAspectX = 1;
    sampleAspectY = 1;
}
// setters
-(void)setSampleAspectX:(NSInteger)value {
    sampleAspectX = value;
}

-(void)setSampleAspectY:(NSInteger)value {
    sampleAspectY = value;
}

-(void)setSavedSampleList:(NSArray*)array {
    savedSampleList = [[NSArray alloc] initWithArray:array copyItems:YES];
}

// getters
-(NSURL*)getSampleFolderURL {
    return [projectFolder URLByAppendingPathComponent:@"Samples"];
}
-(NSInteger)getSampleAspectX {
    return sampleAspectX;
}

-(NSInteger)getSampleAspectY {
    return sampleAspectY;
}

-(NSArray*) getSavedSampleList {
    return savedSampleList;
}

#pragma mark - Sampling
// initialization with default values
-(void)initializeSamplingProperties {
    // this is a good size to start with
    sampleSizeX = 24;
    sampleSizeY = 24*sampleAspectY/sampleAspectX;
    // let's got for nine samples per image
    isMultipleSamplesPerImage = YES;
    sampleCountPerImage = 9;
    // other parameters are as given by OpenCV documentation
    rotationX = 0.6;
    rotationY = 0.0;
    rotationZ = 0.3;
    maxIntensityDev = 100;
}

// setters
-(void)setSampleSizeX:(NSInteger)size {
    
}

-(void)setSampleSizeY:(NSInteger)size {
    
}

-(void)setIsMultipleSamplesPerImage:(BOOL)choice {
    
}

-(void)setSampleCountPerImage:(NSInteger)count {
    
}

-(void)setRotationX:(float)rotation {
    
}

-(void)setRotationY:(float)rotation {
    
}

-(void)setRotationZ:(float)rotation {
    
}
-(void)setMaxIntensityDev:(float)value {
    
}


// getters
-(NSURL*)getTempFolderURL {
    return [projectFolder URLByAppendingPathComponent:@"temp"];
}

-(NSInteger)getSampleSizeX {
    return sampleSizeX;
}

-(NSInteger)getSampleSizeY {
    return sampleSizeY;
}

-(BOOL)getIsMultipleSamplesPerImage {
    return isMultipleSamplesPerImage;
}

-(NSInteger)getSampleCountPerImage {
    return sampleCountPerImage;
}

-(float)getRotationX {
    return rotationX;
}

-(float)getRotationY {
    return rotationY;
}

-(float)getRotationZ {
    return rotationZ;
}

-(float)getMaxIntensityDev {
    return maxIntensityDev;
}

-(NSURL*)getSampleFileURL {
    return [projectFolder URLByAppendingPathComponent:@"Training.data"];
}

@end

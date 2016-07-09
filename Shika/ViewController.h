//
//  ViewController.h
//  Shika
//
//  Created by Chamin Morikawa on 11/26/14.
//  Copyright (c) 2014 Yubi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface ViewController : NSViewController<NSTabViewDelegate>

// Main view
@property (weak) IBOutlet NSTabView *tabViewMain;
@property (weak) IBOutlet NSButton *btnBack;
@property (weak) IBOutlet NSButton *btnNext;
@property (weak) IBOutlet NSTextField *txtDescription;

// Define
@property (weak) IBOutlet NSTextField *txtPositiveLabel;
@property (weak) IBOutlet NSTextField *txtNegativeLabel;

@property (weak) IBOutlet NSButton *btnPositiveFolder;
@property (weak) IBOutlet NSButton *btnNegativeFolder;

@property (weak) IBOutlet NSTextField *txtPositiveFolder;
@property (weak) IBOutlet NSTextField *txtNegativeFolder;

@property (weak) IBOutlet NSTextField *txtPositiveCount;
@property (weak) IBOutlet NSTextField *txtNegativeCount;

@property (weak) IBOutlet NSTextField *txtPositiveSampleIndex;
@property (weak) IBOutlet NSTextField *txtNegativeSampleIndex;

@property (weak) IBOutlet NSButton *btnPrevPositiveSample;
@property (weak) IBOutlet NSButton *btnNextPositiveSample;
@property (weak) IBOutlet NSButton *btnPrevNegativeSample;
@property (weak) IBOutlet NSButton *btnNextNegativeSample;

@property (weak) IBOutlet NSImageView *imgPositiveSample;
@property (weak) IBOutlet NSImageView *imgNegativeSample;

// Preprocess
@property (weak) IBOutlet IKImageView *imgOriginal;
@property (weak) IBOutlet NSImageView *imgPreprocessed;

@property (weak) IBOutlet NSTextField *txtAspectX;
@property (weak) IBOutlet NSTextField *txtAspectY;
@property (weak) IBOutlet NSButton *btnSetAspectRatio;

@property (weak) IBOutlet NSTextField *txtOriginalImgCount;
@property (weak) IBOutlet NSTextField *txtSavedImgCount;

@property (weak) IBOutlet NSButton *checkBoxAutoSave;
@property (weak) IBOutlet NSButton *btnSave;
@property (weak) IBOutlet NSButton *btnPrevOriginal;
@property (weak) IBOutlet NSButton *btnNextOriginal;

// Train
@property (weak) IBOutlet NSTextField *txtAspectRatio;
@property (weak) IBOutlet NSTextField *txtSampleX;
@property (weak) IBOutlet NSTextField *txtSampleY;
@property (weak) IBOutlet NSButton *btnSetSampleSize;

@property (weak) IBOutlet NSMatrix *matrixSampleMode;
@property (weak) IBOutlet NSBox *boxSamplingSettings;
@property (weak) IBOutlet NSTextField *txtSampleCount;
@property (weak) IBOutlet NSSlider *sliderSampleCount;
@property (weak) IBOutlet NSTextField *txtMaxRotX;
@property (weak) IBOutlet NSTextField *txtMaxRotY;
@property (weak) IBOutlet NSTextField *txtMaxRotZ;
@property (weak) IBOutlet NSTextField *txtMaxDev;

@property (weak) IBOutlet NSButton *btnGenerateSamples;

@property (weak) IBOutlet NSTextField *txtStageCount;
@property (weak) IBOutlet NSTextField *txtSplitCount;
@property (weak) IBOutlet NSTextField *txtMemAllocated;
@property (weak) IBOutlet NSMatrix *rbIsSymmetric;
@property (weak) IBOutlet NSTextField *txtMinHitRate;
@property (weak) IBOutlet NSTextField *txtMaxFPRate;
@property (weak) IBOutlet NSTextField *txtWeightTrimming;
@property (weak) IBOutlet NSPopUpButton *popupTrainingMode;
@property (weak) IBOutlet NSPopUpButton *popupBT;
@property (weak) IBOutlet NSPopUpButton *popupErrorEstimation;

@property (weak) IBOutlet NSButton *btnRestoreTrainingDefaults;

@property (weak) IBOutlet NSButton *btnTrainClassifier;

@property (weak) IBOutlet NSTextField *txtProgressTitle;
@property (weak) IBOutlet NSProgressIndicator *progressTraining;

@end


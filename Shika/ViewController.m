//
//  ViewController.m
//  Shika
//
//  Created by Chamin Morikawa on 11/26/14.
//  Copyright (c) 2014 Yubi. All rights reserved.
//

#import "ViewController.h"

#import "ShikaProject.h"
#import "PreprocessedSample.h"
#import "TrainingSampleMaker.h"

#define ZOOM_IN_FACTOR  1.414214
#define ZOOM_OUT_FACTOR 0.7071068

@implementation ViewController {
    // project settings
    BOOL newProject;
    
    ShikaProject* currentProject;
    NSURL* projectFileURL;
    
    // Main
    NSInteger currentTab;
    int maxTab; // use later
    
    // Define
    NSString* imageFolderString;
    NSMutableArray* positiveImages;
    NSMutableArray* negativeImages;
    NSMutableArray* imageList;
    
    NSInteger positiveImageCount;
    int positiveImageIndex;
    NSInteger negativeImageCount;
    int negativeImageIndex;
    
    // Preprocess
    CGRect initPreviewFrame;
    float sampleAspectRatio;
    BOOL autoSave;
    int originalImageIndex;
    int preprocessedSampleCount;
    NSURL* preprocessedImgFolderURL;
    NSMutableArray *preprocessedImageList; // might remove later
    
    // Train
    NSString* tempTrainingDataPath; // for temporary files - remove later if possible
    NSMutableArray *originalSampleList; // redundant?
    int sampleSizeX;
    int sampleSizeY;
    BOOL multipleSamples;
    int samplesPerImg;
    float maxRotX;
    float maxRotY;
    float maxRotZ;
    float maxDev;
    
    int trgNumPosSamples; // number of positive samples for training, depends on sampling method
    int trgNumStages;//[-nstages <number_of_stages = 14>]
    int trgNumSplits;//[-nsplits <number_of_splits = 1>]
    int trgMemUsed;//[-mem <memory_in_MB = 200>]
    NSString* trgSymFlag; //[-sym (default)] [-nonsym]
    float trgMinHitRate;//[-minhitrate <min_hit_rate = 0.995000>]
    float trgMaxFPRate;//[-maxfalsealarm <max_false_alarm_rate = 0.500000>]
    float trgWeightTrimming;//[-weighttrimming <weight_trimming = 0.950000>]
    //[-eqw]
    NSString* trgMode;//[-mode <BASIC (default) | CORE | ALL>]
    NSString* trgBT;//[-bt <DAB | RAB | LB | GAB (default)>]
    NSString* trgErrEstimation;//[-err <misclass (default) | gini | entropy>]
    int trgMaxSplits;//[-maxtreesplits <max_number_of_splits_in_tree_cascade = 0>]
    int trgMinPos;//[-minpos <min_number_of_positive_samples_per_cluster = 500>]
    NSString* sampleFilePath;
    BOOL trgComplete;
}

// Main
@synthesize tabViewMain;
@synthesize txtDescription;
@synthesize btnBack,btnNext;

// Define
@synthesize txtPositiveLabel,txtNegativeLabel,txtPositiveFolder,txtNegativeFolder;
@synthesize txtPositiveCount,txtNegativeCount,txtPositiveSampleIndex,txtNegativeSampleIndex;
@synthesize imgPositiveSample,imgNegativeSample;
@synthesize btnPrevPositiveSample,btnNextPositiveSample,btnPrevNegativeSample,btnNextNegativeSample;

// Preprocess
@synthesize imgOriginal,imgPreprocessed;
@synthesize txtAspectX,txtAspectY,txtOriginalImgCount,txtSavedImgCount;
@synthesize checkBoxAutoSave,btnSetAspectRatio,btnPrevOriginal,btnNextOriginal;

// Train
@synthesize txtAspectRatio,txtSampleX,txtSampleY;
@synthesize btnSetSampleSize,btnGenerateSamples,btnTrainClassifier;
@synthesize matrixSampleMode,boxSamplingSettings;
@synthesize txtSampleCount,sliderSampleCount,txtMaxRotX,txtMaxRotY,txtMaxRotZ,txtMaxDev;
@synthesize txtStageCount,txtSplitCount,txtMemAllocated,rbIsSymmetric,txtMinHitRate,txtMaxFPRate,txtWeightTrimming,popupTrainingMode,popupBT,popupErrorEstimation;
@synthesize progressTraining,txtProgressTitle;

#pragma mark - Application Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // a bit of UI manipulation
    [btnBack setEnabled:NO];
    [btnNext setEnabled:NO];
}

-(void)viewDidAppear {
    // prompt the user first
    [self showProjectSelectionAlert];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


#pragma mark - Project Operations
-(void)showProjectSelectionAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Build New Classifer"];
    [alert addButtonWithTitle:@"Open Existing Classifier"];
    [alert setMessageText:@"Launching Shika"];
    [alert setInformativeText:@"What do you want to do?"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        newProject = YES;
        [self initAndSaveNewProject];
    }
    else
    {
        newProject = NO;
        [self openExistingProject];
    }

}

-(IBAction)initAndSaveNewProject {
    // open save dialog
    [currentProject setPositiveClassLabel:[txtPositiveLabel stringValue]];
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setTitle:@"Select project location and enter project name"];
    [panel setCanCreateDirectories:YES];
    [panel setNameFieldLabel:@"Project Name:"];
    [panel setCanHide:YES];
    NSInteger clicked = [panel runModal];
        
    // user enters folder name
    if (clicked == NSFileHandlingPanelOKButton)
    {
        NSLog(@"OK!");
        NSString* folderName = [[panel URL] lastPathComponent];
        NSURL *outFolderURL = [panel URL];
        NSError* error;
        if ([[NSFileManager defaultManager] createDirectoryAtURL:outFolderURL withIntermediateDirectories:NO attributes:nil error:&error])
        {
            NSURL *projFileName = [outFolderURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.senbei",folderName]];
            projectFileURL = projFileName;
            // initialize project
            currentProject = [[ShikaProject alloc] init];
            [currentProject setProjectFolder:outFolderURL];
            [currentProject setPositiveClassLabel:folderName];
            [currentProject setNegativeClassLabel:@"Other"];
            // save it
            NSLog(@"saving in this folder");
            // save the senbei inside the folder :o)
            [currentProject saveToFile:projectFileURL];
            // Initialize arrays etc.
            positiveImages = [[NSMutableArray alloc] init];
            negativeImages = [[NSMutableArray alloc] init];
            imageList = [[NSMutableArray alloc] init];
            
            // we only have the define view
            [self initDefineView];
            
            // set UI controls
            currentTab = 0;
            maxTab = 0;
            [tabViewMain selectTabViewItemAtIndex:currentTab];
            [tabViewMain setDelegate:self];
            
            [panel setHidesOnDeactivate:YES];
            [panel close];
        }
        else
        {
            NSLog(@"Error");
            [panel close];
            [self showProjectSelectionAlert];
        }
    }
    else
    {
        // prompt the user again
        //[self showProjectSelectionAlert];
        NSLog(@"Cancel");
    }
    // we are done
}

-(void)openExistingProject {
    // open existing project
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle: @"Choose a classifier project (.senbei) file"];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes: @[@"senbei"]];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton)
    {
        // read project info
        projectFileURL = [[panel URLs] objectAtIndex:0];
        currentProject = [[ShikaProject alloc] initWithFile:projectFileURL];
        // set the maximum tab here
        maxTab = (int)[currentProject getState];
        // set the UI according to project
        [self initializeUIForLoadedProject];
    }
    else
    {
        NSLog(@"Aborted, starting new project.");
        [self initAndSaveNewProject];
    }
}

-(void)updateProjectAtState:(NSInteger)state {
    NSLog(@"Saving...");
    // update state for consistency
    [currentProject setCurState:state];
    switch (state) {
        case 0:
            // define
            [currentProject setPositiveClassLabel:[txtPositiveLabel stringValue]];
            [currentProject setNegativeClassLabel:[txtNegativeLabel stringValue]];
            [currentProject setPositiveFolderString:[txtPositiveFolder stringValue]];
            [currentProject setNegativeFolderString:[txtNegativeFolder stringValue]];
            if (positiveImageCount > 0) {
                 [currentProject setPositiveSampleList:positiveImages];
            }
            if (negativeImageCount > 0) {
                [currentProject setNegativeSampleList:negativeImages];
            }
            break;
        case 1:
            // preprocess
            [currentProject setSampleAspectX:[txtAspectX integerValue]];
            [currentProject setSampleAspectY:[txtAspectY integerValue]];
            [currentProject setSavedSampleList:preprocessedImageList];
            break;
        case 2:
            // sample
            
            break;
        case 3:
            // train
            break;
        case 4:
            // test
            break;
        default:
            break;
    }
    // will be saving anyway
    [currentProject saveToFile:projectFileURL];
}

#pragma mark - User Interface
-(void)initializeUIForLoadedProject {
    // divide the work by project state
    currentTab = [currentProject getState];
    switch ([currentProject getState]) {
        case 0:
            // define
            [self initializeDefineScreen];
            break;
        case 1:
            // preprocess
            [self initializeDefineScreen];
            [self initializePreprocessScreen];
            break;
        case 2:
            // sampling
            [self initializeDefineScreen];
            [self initializePreprocessScreen];
            [self initializeSamplingScreen];
            break;
        case 3:
            // training
            [self initializeDefineScreen];
            [self initializePreprocessScreen];
            [self initializeSamplingScreen];
            [self initializeTrainingScreen];
            break;
        case 4:
            // define
            [self initializeDefineScreen];
            [self initializePreprocessScreen];
            [self initializeSamplingScreen];
            [self initializeTrainingScreen];
            [self initializeTestingScreen];
            break;
        default:
            break;
    }
    // common UI commands
    [tabViewMain selectTabViewItemAtIndex:[currentProject getState]];
    [tabViewMain setDelegate:self];
}

-(void)initializeDefineScreen {
    [txtPositiveLabel setStringValue:[currentProject getPositiveClassLabel]];
    [txtNegativeLabel setStringValue:[currentProject getNegativeClassLabel]];
    [txtPositiveFolder setStringValue:[currentProject getPositiveFolderString]];
    [txtNegativeFolder setStringValue:[currentProject getNegativeFolderString]];
    // load the sample lists
    positiveImages = [[NSMutableArray alloc] initWithArray:[currentProject getPositiveSampleList] copyItems:YES];
    negativeImages = [[NSMutableArray alloc] initWithArray:[currentProject getNegativeSampleList] copyItems:YES];
    // fill the rest of the UI
    positiveImageCount = [positiveImages count];
    if (positiveImageCount > 0) {
        [self preparePositiveSamplePreview];
    }
    negativeImageCount = [negativeImages count];
    if (negativeImageCount > 0) {
        [self prepareNegativeSamplePreview];
    }
    // prev button is disabled
    [btnBack setEnabled:NO];
    // validate next button
    if ([self nextButtonReady])
    {
        [btnNext setEnabled:YES];
    }
    else
    {
        [btnNext setEnabled:NO];
    }
    // we are done
}

-(void)initializePreprocessScreen {
    [self initPreprocessView];
    [txtAspectX setIntegerValue:[currentProject getSampleAspectX]];
    [txtAspectY setIntegerValue:[currentProject getSampleAspectY]];
    preprocessedImageList = [[NSMutableArray alloc] initWithArray:[currentProject getSavedSampleList]];
    if ([preprocessedImageList count] > 0)
    {
        preprocessedSampleCount = (int)[preprocessedImageList count];
        [btnNext setEnabled:YES];
        [txtSavedImgCount setStringValue:[NSString stringWithFormat:@"%lu images saved",(unsigned long)[preprocessedImageList count]]];
        // if there is a sample for the first image, load it
        NSError* err;
        NSURL *outURL = [self getPreprocessedImageURLForFile:[positiveImages objectAtIndex:0] atIndex:0];
        if ([outURL checkResourceIsReachableAndReturnError:&err] == YES)
        {
            [imgPreprocessed setImage:[[NSImage alloc] initWithContentsOfURL:outURL]];
        }
        else
        {
            [imgPreprocessed setImage:NULL];
        }

    }
}

-(void)initializeSamplingScreen {
    [self initTrainView];
    // TODO: add code
}

-(void)initializeTrainingScreen {
    // TODO: add code
}

-(void)initializeTestingScreen {
    // TODO: add code
}

#pragma mark - Common UI Preparations
-(void)preparePositiveSamplePreview {
    // must clear the temporary list
    [imageList removeAllObjects];
    // UI
    // show the total no. of images
    [txtPositiveCount setStringValue:[NSString stringWithFormat:@"Total: %ld images",(long)positiveImageCount]];
    // now set the first image
    [imgPositiveSample setImage:[[NSImage alloc] initWithContentsOfURL:[positiveImages objectAtIndex:0]]];
    positiveImageIndex = 0;
    [txtPositiveSampleIndex setStringValue:[NSString stringWithFormat:@"%d",positiveImageIndex+1]];
    [txtPositiveCount setHidden:NO];
    [txtPositiveSampleIndex setHidden:NO];
    [btnPrevPositiveSample setHidden:NO];
    [btnNextPositiveSample setHidden:NO];
}

-(void)prepareNegativeSamplePreview {
    // must clear the temporary list
    [imageList removeAllObjects];
    // UI
    // show the total no. of images
    [txtNegativeCount setStringValue:[NSString stringWithFormat:@"Total: %ld images",(long)negativeImageCount]];
    // now set the first image
    [imgNegativeSample setImage:[[NSImage alloc] initWithContentsOfURL:[negativeImages objectAtIndex:0]]];
    negativeImageIndex = 0;
    [txtNegativeSampleIndex setStringValue:[NSString stringWithFormat:@"%d",negativeImageIndex+1]];
    [txtNegativeCount setHidden:NO];
    [txtNegativeSampleIndex setHidden:NO];
    [btnPrevNegativeSample setHidden:NO];
    [btnNextNegativeSample setHidden:NO];
}

#pragma mark - Define
-(void)initDefineView {
    // update class labels
    [txtPositiveLabel setStringValue:[currentProject getPositiveClassLabel]];
    [txtNegativeLabel setStringValue:[currentProject getNegativeClassLabel]];
    [txtPositiveSampleIndex setHidden:YES];
    [txtNegativeSampleIndex setHidden:YES];
    [txtPositiveCount setHidden:YES];
    [txtNegativeCount setHidden:YES];
    [btnPrevPositiveSample setHidden:YES];
    [btnNextPositiveSample setHidden:YES];
    [btnPrevNegativeSample setHidden:YES];
    [btnNextNegativeSample setHidden:YES];
    [btnBack setEnabled:NO];
    [btnNext setEnabled:NO];
    [txtDescription setStringValue:@"Define your pattern recognition task by entering class labels and selecting folders with sample images. Multiple folders can be selected for both classes."];
}

- (IBAction)showPositiveFolderDialog:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton)
    {
        // remove old stuff
        [positiveImages removeAllObjects];
        positiveImageCount = 0;
        // set text view
        [txtPositiveFolder setStringValue:[[[panel URLs] objectAtIndex:0] path]];
        // load image list
        imageFolderString = @"";
        [self addImagesWithPaths:[panel URLs]];
        [txtPositiveFolder setStringValue:imageFolderString];
        [positiveImages addObjectsFromArray:imageList];
        positiveImageCount = (int)[positiveImages count];
        if (positiveImageCount > 0) {
            [self preparePositiveSamplePreview];
            [self updateProjectAtState:0];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"No images in this folder!"];
            [alert setAlertStyle:NSWarningAlertStyle];
            //[alert beginSheetModalForWindow:[self window] completionHandler:NULL];
            [txtPositiveCount setHidden:YES];
            [txtPositiveSampleIndex setHidden:YES];
            [btnPrevPositiveSample setHidden:YES];
            [btnNextPositiveSample setHidden:YES];
        }
    }
    // validate next button
    if ([self nextButtonReady]) {
        [btnNext setEnabled:YES];
    }
    else
    {
        [btnNext setEnabled:NO];
    }
}

- (IBAction)showNegativeFolderDialog:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        // remove old stuff
        [negativeImages removeAllObjects];
        negativeImageCount = 0;
        // set text view
        // load image list
        imageFolderString = @"";
        [self addImagesWithPaths:[panel URLs]];
        [txtNegativeFolder setStringValue:imageFolderString];
        [negativeImages addObjectsFromArray:imageList];
        negativeImageCount = (int)[negativeImages count];
        if (negativeImageCount > 0) {
            [self prepareNegativeSamplePreview];
            [self updateProjectAtState:0];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"No images in this folder!"];
            [alert setAlertStyle:NSWarningAlertStyle];
            //[alert beginSheetModalForWindow:[self window] completionHandler:NULL];
            [txtNegativeCount setHidden:YES];
            [txtNegativeSampleIndex setHidden:YES];
            [btnPrevNegativeSample setHidden:YES];
            [btnNextNegativeSample setHidden:YES];
        }
    }
    // validate next button
    if ([self nextButtonReady]) {
        [btnNext setEnabled:YES];
    }
    else
    {
        [btnNext setEnabled:NO];
    }
}

- (void) addImagesWithPaths:(NSArray *) paths {
    int i, n;
    n = (int)[paths count];
    NSLog(@"%d folders",n);
    for(i=0; i<n; i++){
        NSURL *baseURL = [paths objectAtIndex:i];
        imageFolderString = [imageFolderString stringByAppendingString:[baseURL path]];
        imageFolderString = [imageFolderString stringByAppendingString:@"\n"];
        [self addImagesWithPath:baseURL recursive:NO];
    }
}

- (void) addImagesWithPath:(NSURL *) baseURL recursive:(BOOL) recursive
{
    BOOL dir;
    
    [[NSFileManager defaultManager] fileExistsAtPath:[baseURL path] isDirectory:&dir];
    if(dir){
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:baseURL
                                                          includingPropertiesForKeys:@[]
                                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'png' OR pathExtension == 'jpg' OR pathExtension == 'jpeg' OR pathExtension == 'JPG' OR pathExtension == 'bmp'"];
        for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate])
        {
            // Enumerate each .png file in directory
            [imageList addObject:fileURL];
        }
    }
    else
    {
        [imageList addObject:baseURL];
    }
}

- (IBAction)updatePositiveLabel:(id)sender {
    // later check for valid string
    if ([sender stringValue]) {
        [currentProject setPositiveClassLabel:[sender stringValue]];
    }
}

- (IBAction)updateNegativeLabel:(id)sender {
    // later check for valid string
    if ([sender stringValue]) {
        [currentProject setNegativeClassLabel:[sender stringValue]];
    }
}

#pragma mark - Preprocess
-(void)initPreprocessView {
    [txtSavedImgCount setStringValue:@"0 images saved"];
    [txtOriginalImgCount setStringValue:[NSString stringWithFormat:@"Image 1 of %ld", (long)positiveImageCount]];
    sampleAspectRatio = 1.0;
    // load image
    [imgOriginal setAutoresizes:YES];
    [imgOriginal setImageWithURL:[positiveImages objectAtIndex:0]];
    // back button must be enabled
    [btnBack setEnabled:YES];
    // next button is disabled unti you save an image
    [btnNext setEnabled:NO];
    // record preview frame
    initPreviewFrame = [imgPreprocessed frame];
    // auto save is on
    autoSave = YES;
    // results will be saved here
    preprocessedImageList = [[NSMutableArray alloc] init];
    // create folder
    NSError *err;
    preprocessedImgFolderURL = [currentProject getSampleFolderURL];
    if ([preprocessedImgFolderURL checkResourceIsReachableAndReturnError:&err] == NO)
    {
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:[preprocessedImgFolderURL path]withIntermediateDirectories:NO attributes:nil error:&error];
    }
    // update description
    [txtDescription setStringValue:@"Set sample aspect ratio, and crop your positive training images as appropriate."];
    // update the project
    // save to file
}

- (IBAction)setAspectRatio:(id)sender {
    sampleAspectRatio = [txtAspectX floatValue]/[txtAspectY floatValue];
    // modify the preview accordingly
    CGRect frame = initPreviewFrame;
    if (sampleAspectRatio > 1.0) {
        // landscape
        frame.size.height /= sampleAspectRatio;
        frame.origin.y += (frame.size.width - frame.size.height)/2.0;
    }
    if (sampleAspectRatio < 1.0) {
        // portrait
        frame.size.width *= sampleAspectRatio;
        frame.origin.x += (frame.size.height - frame.size.width)/2.0;
    }
    [imgPreprocessed setFrame:frame];
    
    // update the project and save to file
    [self updateProjectAtState:1];
}

- (IBAction)doZoom: (id)sender
{
    // handle zoom tool...
    
    NSInteger zoom;
    CGFloat   zoomFactor;
    
    if ([sender isKindOfClass: [NSSegmentedControl class]])
        zoom = [sender selectedSegment];
    else
        zoom = [sender tag];
    
    switch (zoom)
    {
        case 0:
            zoomFactor = [imgOriginal zoomFactor];
            [imgOriginal setZoomFactor: zoomFactor * ZOOM_OUT_FACTOR];
            break;
        case 1:
            zoomFactor = [imgOriginal zoomFactor];
            [imgOriginal setZoomFactor: zoomFactor * ZOOM_IN_FACTOR];
            break;
        case 2:
            [imgOriginal zoomImageToActualSize: self];
            break;
        case 3:
            [imgOriginal zoomImageToFit: self];
            break;
    }
}

- (IBAction)switchToolMode: (id)sender
{
    // switch the tool mode...
    
    NSInteger newTool;
    
    if ([sender isKindOfClass: [NSSegmentedControl class]])
        newTool = [sender selectedSegment];
    else
        newTool = [sender tag];
    
    switch (newTool)
    {
        case 0:
            [imgOriginal setCurrentToolMode: IKToolModeMove];
            break;
        case 1:
            [imgOriginal setCurrentToolMode: IKToolModeSelect];
            break;
        case 2:
            [imgOriginal setCurrentToolMode: IKToolModeCrop];
            break;
        case 3:
            [imgOriginal setCurrentToolMode: IKToolModeRotate];
            break;
    }
}

- (IBAction)copyImage:(id)sender {
    [imgPreprocessed setImage:[[NSImage alloc] initWithCGImage:[imgOriginal image] size:NSZeroSize]];
}

- (IBAction)cropImage:(id)sender {
    [imgOriginal crop:sender];
    // estimate the frame with the right aspect ratio
    NSImage* temp = [[NSImage alloc] initWithCGImage:[imgOriginal image] size:NSZeroSize];
    //[imgPreprocessed setImage:[[NSImage alloc] initWithCGImage:[imgOriginal image] size:NSZeroSize]];
    // start by setting this frame
    CGRect sampleFrame;
    sampleFrame.origin.x = 0;
    sampleFrame.origin.y = 0;
    sampleFrame.size = temp.size;
    float imgAspectRatio = sampleFrame.size.width/sampleFrame.size.height;
    // record frame, accounting for differences
    if (sampleAspectRatio > imgAspectRatio) {
        // cropped too tall
        sampleFrame.size.height = sampleFrame.size.width/sampleAspectRatio;
        sampleFrame.origin.y += (temp.size.height - sampleFrame.size.height)/2.0;
    }
    else
    {
        // too wide or just right
        sampleFrame.size.width = sampleFrame.size.height*sampleAspectRatio;
        sampleFrame.origin.x += (temp.size.width - sampleFrame.size.width)/2.0;
    }
    
    // now set the image
    CGImageRef imageRef = CGImageCreateWithImageInRect([imgOriginal image], sampleFrame);
    [imgPreprocessed setImage:[self imageFromCGImageRef:imageRef]];
    
    // set the original again
    [imgOriginal setImageWithURL:[positiveImages objectAtIndex:originalImageIndex]];
    // save if "auto save" is set
    if (autoSave) {
        [self saveCroppedImage];
    }
}

- (IBAction)setAutoSaveMode:(id)sender {
    if ([sender state]==1) {
        autoSave = YES;
    }
    else
    {
        autoSave = NO;
    }
}

- (IBAction)saveCroppedImageTapped:(id)sender {
    [self saveCroppedImage];
}

-(void)saveCroppedImage {
    // create folder if it is not there - just in case
    NSError *err;
    NSURL *outFolder = [currentProject getSampleFolderURL];
    if ([outFolder checkResourceIsReachableAndReturnError:&err] == NO)
    {
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:[outFolder path]withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    //now save the file
    //NSURL *outFileName = [self getOutPutFileURL:[positiveImages objectAtIndex:originalImageIndex]];
    NSURL *outFileName = [self getPreprocessedImageURLForFile:[positiveImages objectAtIndex:originalImageIndex] atIndex:originalImageIndex];
    
    // Cache the reduced image
    NSData *imageData = [[imgPreprocessed image] TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:[outFileName path] atomically:NO];
    // set the file list and the count
    [preprocessedImageList addObject:outFileName];
    // save the list inside the project, too
    [currentProject setSavedSampleList:preprocessedImageList];
    // update project file
    [self updateProjectAtState:1];
    preprocessedSampleCount = (int)[preprocessedImageList count];
    // update the count on the interface
    [txtSavedImgCount setStringValue:[NSString stringWithFormat:@"Total saved: %d",preprocessedSampleCount]];
    // enable "Next" button
    [btnNext setEnabled:YES];
    // we are done
}

// NSURL operations
-(NSURL*)getOutPutFolderURL:(NSURL*)inputFileURL {
    NSURL *inFolderName = [inputFileURL URLByDeletingLastPathComponent];
    NSURL *outFolderName = [inFolderName URLByAppendingPathComponent:@"preprocessed"];
    return outFolderName;
}

-(NSURL*)getPreprocessedImageURLForFile:(NSURL*)inputFileURL atIndex:(int)imageIdx {
    NSString *inFileName = [NSString stringWithFormat:@"%d_%@",imageIdx,[inputFileURL lastPathComponent]];
    NSURL * outFileURL = [[currentProject getSampleFolderURL] URLByAppendingPathComponent:inFileName];
    return outFileURL;
}

#pragma mark - Sample
-(void)initTrainView {
    // set temporary folder
    tempTrainingDataPath = @"/Users/chamin/Documents/Images/HaarML/";
    NSURL *sampleFileURL = [[currentProject getProjectFolderURL] URLByAppendingPathComponent:@"TrainingSamples.data"];
    sampleFilePath = [sampleFileURL path];
    
    originalSampleList = [[NSMutableArray alloc] init];
    // prepare the set of samples
    [self saveSamplingInfo];
    // also save negative sample data
    [self saveNegativesInfo];
    // update description
    [txtDescription setStringValue:@"Set sampling and training parameters, and proceed to training."];
    // show aspect ratio
    [txtAspectRatio setStringValue:[NSString stringWithFormat:@"Sample aspect ratio = %@:%@ ",txtAspectX.stringValue,txtAspectY.stringValue]];
    // set initial sample size
    sampleSizeX = [currentProject getSampleSizeX];
    sampleSizeY = [currentProject getSampleSizeX];
    [txtSampleX setStringValue:[NSString stringWithFormat:@"%d",sampleSizeX]];
    [txtSampleY setStringValue:[NSString stringWithFormat:@"%d",sampleSizeY]];
    // other values
    multipleSamples = YES;
    samplesPerImg = [currentProject getSampleCountPerImage];
    maxRotX = [currentProject getRotationX];
    maxRotY = [currentProject getRotationY];
    maxRotZ = [currentProject getRotationZ];
    maxDev = [currentProject getMaxIntensityDev];
    // put them on the UI, too
    [matrixSampleMode selectCellWithTag:1];
    [boxSamplingSettings setHidden:NO];
    [sliderSampleCount setIntValue:samplesPerImg];
    [txtSampleCount setStringValue:[NSString stringWithFormat:@"%d",samplesPerImg]];
    [txtMaxRotX setStringValue:[NSString stringWithFormat:@"%.2f",maxRotX]];
    [txtMaxRotY setStringValue:[NSString stringWithFormat:@"%.2f",maxRotY]];
    [txtMaxRotZ setStringValue:[NSString stringWithFormat:@"%.2f",maxRotZ]];
    [txtMaxDev setStringValue:[NSString stringWithFormat:@"%.2f",maxDev]];
    
    // we can't train yet
    [btnTrainClassifier setEnabled:NO];
    // we can't test, either
    [btnNext setEnabled:NO];
}

-(void)saveSamplingInfo {
    // open output file
    NSString* posSampleDataFile = [NSString stringWithFormat:@"%@psampleinfo.dat",tempTrainingDataPath];
    [[NSFileManager defaultManager] createFileAtPath:posSampleDataFile contents:nil attributes:nil];
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:posSampleDataFile];
    // open image folder
    BOOL dir;
    [[NSFileManager defaultManager] fileExistsAtPath:[preprocessedImgFolderURL path] isDirectory:&dir];
    if(dir){
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:preprocessedImgFolderURL
                                                          includingPropertiesForKeys:@[]
                                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'png' OR pathExtension == 'jpg' OR pathExtension == 'JPG' OR pathExtension == 'jpeg' OR pathExtension == 'bmp'"];
        for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate])
        {
            // Enumerate each .png file in directory
            PreprocessedSample *temp = [[PreprocessedSample alloc] initWithImage:fileURL andAspectRatio:sampleAspectRatio];
            NSLog(@"%@",[temp getAttributeString]);
            [originalSampleList addObject:[temp getAttributeString]];
            [imageList addObject:temp];
            NSString *str = [NSString stringWithFormat:@"../../../../..%@",[temp getAttributeString]];//Your text or XML
            // write to file
            [fh seekToEndOfFile];
            [fh writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
}

// save negative samples
-(void)saveNegativesInfo {
    // open output file
    NSURL* negativeSampleIndexURL = [[currentProject getProjectFolderURL] URLByAppendingPathComponent:@"NegativeSampleInfo.data"];
    //NSString* negSampleDataFile = [NSString stringWithFormat:@"%@nsampleinfo.dat",tempTrainingDataPath];
    [[NSFileManager defaultManager] createFileAtPath:[negativeSampleIndexURL path] contents:nil attributes:nil];
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:[negativeSampleIndexURL path]];
    for (int i=0; i<[negativeImages count]; i++) {
        [fh seekToEndOfFile];
        // TODO: write a function to get the number of slashes right :-(
        NSString* flieString = [NSString stringWithFormat:@"../../../../..%@\n",[[negativeImages objectAtIndex:i] path]];
        [fh writeData:[flieString dataUsingEncoding:NSASCIIStringEncoding]];
    }
}

// the default values for multiple sampling
- (IBAction)restoreSamplingDefaults:(id)sender {
    [currentProject initializeSamplingProperties];
    [self initializeSamplingScreen];
}

- (IBAction)updateSampleSize:(id)sender {
    // recalculate sampleY
    sampleSizeX = [[txtSampleX stringValue] intValue];
    sampleSizeY = (int)(sampleSizeX/sampleAspectRatio);
    [txtSampleY setStringValue:[NSString stringWithFormat:@"%d",sampleSizeY]];
    sampleSizeY = [[txtSampleY stringValue] intValue];
    
}

- (IBAction)updateRotX:(id)sender {
    maxRotX = [[sender stringValue] floatValue];
}

- (IBAction)updateRotY:(id)sender {
    maxRotY = [[sender stringValue] floatValue];
}

- (IBAction)updateRotZ:(id)sender {
    maxRotZ = [[sender stringValue] floatValue];
}

- (IBAction)updateMaxDev:(id)sender {
    maxDev = [[sender stringValue] floatValue];
}

- (IBAction)setSampleSize:(id)sender {
    // calculate sampleY again, just in case
    sampleSizeX = [[txtSampleX stringValue] intValue];
    sampleSizeY = (int)(sampleSizeX/sampleAspectRatio);
    [txtSampleY setStringValue:[NSString stringWithFormat:@"%d",sampleSizeY]];
    sampleSizeY = [[txtSampleY stringValue] intValue];
}

- (IBAction)setPosSampleCount:(id)sender {
    samplesPerImg = (int)[sender integerValue];
    [txtSampleCount setStringValue:[NSString stringWithFormat:@"%d",samplesPerImg]];
}

- (IBAction)setSamplingMode:(id)sender {
    if ([[sender selectedCell] tag] == 0)
    {
        multipleSamples = NO;
        [boxSamplingSettings setHidden:YES];
    }
    else
    {
        multipleSamples = YES;
        [boxSamplingSettings setHidden:NO];
    }
}

- (IBAction)createPosSamples:(id)sender {
    // initialize sample maker
    TrainingSampleMaker* sampleMaker = [[TrainingSampleMaker alloc] init];
    
    // set the values
    [sampleMaker setSampleSizeX:[currentProject getSampleSizeX]];
    [sampleMaker setSampleSizeY:[currentProject getSampleSizeY]];
    [sampleMaker setPreprocessedImageList:[currentProject getSavedSampleList]];
    [sampleMaker setNegativeDataFileURL:[[currentProject getProjectFolderURL] URLByAppendingPathComponent:@"NegativeSampleInfo.data"]];
    [sampleMaker setSamplesPerImage:[currentProject getSampleCountPerImage]];
    [sampleMaker setMaxAngleX:[currentProject getRotationX]];
    [sampleMaker setMaxAngleY:[currentProject getRotationY]];
    [sampleMaker setMaxAngleZ:[currentProject getRotationZ]];
    [sampleMaker setIntensityDeviation:[currentProject getMaxIntensityDev]];
    // got to create the temp folder if it doesn't exist
    NSError* error;
    if ([[NSFileManager defaultManager] createDirectoryAtURL:[currentProject getTempFolderURL] withIntermediateDirectories:NO attributes:nil error:&error])
    {
        // created folder
    }
    else
    {
        NSLog(@"error");
    }
    [sampleMaker setTempFolderURL:[currentProject getTempFolderURL]];
    
    [sampleMaker setOutputFileURL:[[currentProject getProjectFolderURL] URLByAppendingPathComponent:@"TrainingSamples.data"]];
    
    // make samples now
    trgNumPosSamples = [[currentProject getSavedSampleList] count]*[currentProject getSampleCountPerImage];
    [progressTraining setHidden:NO];
    [progressTraining startAnimation:self];
    [txtProgressTitle setStringValue:@"Generating sample data..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<[[currentProject getSavedSampleList] count]; i++)
        {
        
            // use thread and update progress bar
            [sampleMaker generateTrainingSamplesForImageAtIndex:i];
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressTraining setDoubleValue:(i+1)/(double)([[currentProject getSavedSampleList] count]+1)];
                //[progressTraining setDoubleValue: (i + 1.0) / [imageList count]];
                // do additional UI/model updates here
                [txtProgressTitle setStringValue:[NSString stringWithFormat:@"file %ld of %lu",(long)i+1,(unsigned long)[[currentProject getSavedSampleList] count]]];
            });
        }
        // // merge samples
        dispatch_async(dispatch_get_main_queue(), ^{
            [txtProgressTitle setStringValue:@"Merging sample data..."];
        });
        [sampleMaker mergeTrainingSamples];
        
        // finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressTraining stopAnimation:self];
            [progressTraining setHidden:YES];
            [txtProgressTitle setStringValue:@"Completed generating sample data."];
            //prepare training screen
            [self restoreTrainingDefaults:self];
            // allow "Train" button
            [btnTrainClassifier setEnabled:YES];
            // set sample count for training - use fewer than available, to prevent crashes
            trgNumPosSamples = (int)([[currentProject getSavedSampleList] count] -3)*samplesPerImg;
        });
    });
    
    // we are done
}

#pragma mark - Train

- (IBAction)restoreTrainingDefaults:(id)sender {
    // default values
    trgNumStages = 14;
    trgNumSplits = 1;
    trgMemUsed = 512; // used to be 200
    trgSymFlag = @"-nonsym";
    trgMinHitRate = 0.995000;
    trgMaxFPRate = 0.500000;
    trgWeightTrimming = 0.950000;
    trgMode = @"BASIC";
    trgBT = @"GAB";
    trgErrEstimation = @"misclass";
    trgMaxSplits = 0;
    trgMinPos = 500;
    // now put them on the UI
    [txtStageCount setStringValue:[NSString stringWithFormat:@"%d",trgNumStages]];
    [txtSplitCount setStringValue:[NSString stringWithFormat:@"%d",trgNumSplits]];
    [txtMemAllocated setStringValue:[NSString stringWithFormat:@"%d",trgMemUsed]];
    [rbIsSymmetric selectCellWithTag:0];
    [txtMinHitRate setStringValue:[NSString stringWithFormat:@"%.4f",trgMinHitRate]];
    [txtMaxFPRate setStringValue:[NSString stringWithFormat:@"%.4f",trgMaxFPRate]];
    [txtWeightTrimming setStringValue:[NSString stringWithFormat:@"%.4f",trgWeightTrimming]];
    // popups - again, no checking of the values
    [popupTrainingMode selectItemAtIndex:0];
    [popupBT selectItemAtIndex:0];
    [popupErrorEstimation selectItemAtIndex:0];
    // we are done.
}

// set values for training parameters
- (IBAction)updateStageCount:(id)sender {
    trgNumStages = [[sender stringValue] intValue];
}

- (IBAction)updateSplitCount:(id)sender {
    trgNumSplits = [[sender stringValue] intValue];
}

- (IBAction)updateMemSize:(id)sender {
    trgMemUsed = [[sender stringValue] intValue];
}

- (IBAction)updateMinHitRate:(id)sender {
    trgMinHitRate = [[sender stringValue] floatValue];
}

- (IBAction)updateMaxFPRate:(id)sender {
    trgMaxFPRate = [[sender stringValue] floatValue];
}

- (IBAction)updateWeightTrimming:(id)sender {
    trgWeightTrimming = [[sender stringValue] floatValue];
}


- (IBAction)trainClassifier:(id)sender {
    // prepare UI
    [txtProgressTitle setStringValue:@"Training in progress..."];
    [progressTraining setStyle:NSProgressIndicatorSpinningStyle];
    [progressTraining setHidden:NO];
    [progressTraining startAnimation:self];
    // start the trainer
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performTraining];
    });
    NSLog(@"Done.");
}

-(void)performTraining {
    // setup command
    NSString* sampleCreatorPath = @"/opt/local/bin/";
    NSString* negSampleDataFile = [NSString stringWithFormat:@"%@nsampleinfo.dat",tempTrainingDataPath];
    //NSString* negSampleDataFile = [NSString stringWithFormat:@"%@data/negatives/negatives.dat",tempTrainingDataPath];
    // nPos has to be smaller than the total positive sample count
    int nPosPerStage = trgNumPosSamples/2; //(trgNumPosSamples - 400)/(1+(trgNumStages-1)*(1-trgMinHitRate));
    NSString* vecFileName = [NSString stringWithFormat:@"%@",sampleFilePath];
    NSString* cmdString = [NSString stringWithFormat:@"%@opencv_haartraining -data %@/HaarTraining -vec %@ -bg %@ -nstages %d -nsplits %d -minhitrate %f -maxfalsealarm %f -npos %d -nneg %ld -w %d -h %d %@ -mem %d -mode %@",sampleCreatorPath,[[currentProject  getProjectFolderURL] path],vecFileName,negSampleDataFile, trgNumStages,trgNumSplits,trgMinHitRate,trgMaxFPRate,nPosPerStage,(long)negativeImageCount,sampleSizeX,sampleSizeY,trgSymFlag,trgMemUsed,trgMode];
    // execute it
    NSLog(@"%@",cmdString);
    system([cmdString UTF8String]);
    /*
     $ haartraining -data haarcascade -vec samples.vec -bg negatives.dat -nstages 20 -nsplits 2 -minhitrate 0.999 -maxfalsealarm 0.5 -npos 7000 -nneg 3019 -w 20 -h 20 -nonsym -mem 512 -mode ALL
     */
    // finished
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressTraining stopAnimation:self];
        [progressTraining setHidden:YES];
        [progressTraining setStyle:NSProgressIndicatorBarStyle];
        [txtProgressTitle setStringValue:@"Finished training."];
        // now we can do testing
        [btnNext setEnabled:YES];
    });
}

- (IBAction)setSymmetricMode:(id)sender {
    if ([[sender selectedCell] tag] == 0)
    {
        trgSymFlag = @"-nonsym";
    }
    else
    {
        trgSymFlag = @"-sym";
    }
}


#pragma mark - Test

#pragma mark - Image Browsing
- (IBAction)showPrevImage:(id)sender {
    switch ([sender tag]) {
        case 100:
            if (positiveImageIndex > 0)
            {
                positiveImageIndex--;
                [imgPositiveSample setImage:[[NSImage alloc] initWithContentsOfURL:[positiveImages objectAtIndex:positiveImageIndex]]];
                [txtPositiveSampleIndex setStringValue:[NSString stringWithFormat:@"%d",positiveImageIndex+1] ];
                
            }
            break;
        case 200:
            if (negativeImageIndex > 0)
            {
                negativeImageIndex--;
                //[imgNegativeSample setImageWithURL:[negativeImages objectAtIndex:negativeImageIndex]];
                [imgNegativeSample setImage:[[NSImage alloc] initWithContentsOfURL:[negativeImages objectAtIndex:negativeImageIndex]]];
                [txtNegativeSampleIndex setStringValue:[NSString stringWithFormat:@"%d",negativeImageIndex+1] ];
                
            }
            break;
        case 300:
            if (originalImageIndex > 0)
            {
                originalImageIndex--;
                [txtOriginalImgCount setStringValue:[NSString stringWithFormat:@"Image %d of %ld", originalImageIndex+1,(long)positiveImageCount]];
                sampleAspectRatio = 1.0;
                // load image
                [imgOriginal setImageWithURL:[positiveImages objectAtIndex:originalImageIndex]];
                // load preprocessed image if available
                NSError *err;
                //NSURL *outURL = [self getOutPutFileURL:[positiveImages objectAtIndex:originalImageIndex]];
                NSURL *outURL = [self getPreprocessedImageURLForFile:[positiveImages objectAtIndex:originalImageIndex] atIndex:originalImageIndex];
                if ([outURL checkResourceIsReachableAndReturnError:&err] == YES)
                    [imgPreprocessed setImage:[[NSImage alloc] initWithContentsOfURL:outURL]];
                else
                    [imgPreprocessed setImage:NULL];
            }
            break;
        default:
            break;
    }
    
}

- (IBAction)showNextImage:(id)sender {
    switch ([sender tag]) {
        case 101:
            if (positiveImageIndex < positiveImageCount-1)
            {
                positiveImageIndex++;
                [imgPositiveSample setImage:[[NSImage alloc] initWithContentsOfURL:[positiveImages objectAtIndex:positiveImageIndex]]];
                [txtPositiveSampleIndex setStringValue:[NSString stringWithFormat:@"%d",positiveImageIndex+1] ];
            }
            break;
        case 201:
            if (negativeImageIndex < negativeImageCount-1)
            {
                negativeImageIndex++;
                [imgNegativeSample setImage:[[NSImage alloc] initWithContentsOfURL:[negativeImages objectAtIndex:negativeImageIndex]]];
                [txtNegativeSampleIndex setStringValue:[NSString stringWithFormat:@"%d",negativeImageIndex+1] ];
            }
            break;
        case 301:
            if (originalImageIndex < positiveImageCount-1)
            {
                originalImageIndex++;
                [txtOriginalImgCount setStringValue:[NSString stringWithFormat:@"Image %d of %ld", originalImageIndex+1,(long)positiveImageCount]];
                sampleAspectRatio = 1.0;
                // load image
                [imgOriginal setImageWithURL:[positiveImages objectAtIndex:originalImageIndex]];
                // load preprocessed image if available
                NSError *err;
                //NSURL *outURL = [self getOutPutFileURL:[positiveImages objectAtIndex:originalImageIndex]];
                NSURL *outURL = [self getPreprocessedImageURLForFile:[positiveImages objectAtIndex:originalImageIndex] atIndex:originalImageIndex];
                if ([outURL checkResourceIsReachableAndReturnError:&err] == YES)
                {
                    [imgPreprocessed setImage:[[NSImage alloc] initWithContentsOfURL:outURL]];
                }
                else
                {
                    [imgPreprocessed setImage:NULL];
                }
            }
            
        default:
            break;
    }
    
}

#pragma mark - Tab Views
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    BOOL result = NO;
    // going back is always possible
    if ([self getTabIndex:tabViewItem.label] <= currentTab) {
        return YES;
    }
    switch (currentTab) {
        case 0:
            if ([self nextButtonReady] && [self getTabIndex:tabViewItem.label]==1) {
                result = YES;
            }
            break;
        case 1:
            if (preprocessedSampleCount > 0) {
                result = YES;
            }
            break;
        case 2:
            if (preprocessedSampleCount > 0) {
                result = YES;
            }
            break;
        default:
            break;
    }
    return result;
}

- (void)tabView:(NSTabView *)tabView
didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    // get the previous tab
    int prevTab = currentTab;
    currentTab = [self getTabIndex:tabViewItem.label];
    if (currentTab > maxTab) {
        maxTab = currentTab;
        //[self updateProjectAtState:currentTab];
        switch (currentTab) {
            case 1:
                // not sure if I had anything to initialize, so will use update
                [currentProject initializePreprocessingProperties];
                [self initializePreprocessScreen];
                break;
            case 2:
                // initialize the project first
                [currentProject initializeSamplingProperties];
                [self initializeSamplingScreen];
                break;
            case 3:
                // training
                break;
            case 4:
                // testing
                break;
            default:
                break;
        }
    }
    if (currentTab > prevTab) {
        // need initialization
        switch (currentTab) {
            case 0:
                // doesn't apply
                break;
            case 1:
                // initialize screen
                [btnBack setEnabled:YES];
                [self initPreprocessView];
                break;
            case 2:
                // initialize screen
                NSLog(@"Preparing for sampling");
                [self initTrainView];
                break;
            case 3:
                // initialize screen
                break;
            default:
                break;
        }
    }
    
    //we should be able to go forward after coming back
    if (currentTab < prevTab)
    {
        [btnNext setEnabled:YES];
    }
}

- (IBAction)goToPrevTab:(id)sender {
    //currentTab--;
    if (currentTab > 0)
    {
        [tabViewMain selectTabViewItemAtIndex:currentTab-1];
    }
    [btnNext setEnabled:YES];
    if (currentTab == 0)
    {
        [btnBack setEnabled:NO];
    }
    // no need to update when going backwards
}

- (IBAction)goToNextTab:(id)sender {
    [tabViewMain selectTabViewItemAtIndex:currentTab+1];
    // the rest of the permissions are handled in tabview delegates
}


#pragma mark - Navigation
-(IBAction)updateNextButton:(id)sender {
    if ([self nextButtonReady]) {
        [btnNext setEnabled:YES];
    }
    else
    {
        [btnNext setEnabled:NO];
    }
}

-(int)getTabIndex:(NSString *)tabLabel {
    if ([tabLabel isEqualToString:@"Define"]) {
        return 0;
    }
    if ([tabLabel isEqualToString:@"Preprocess"]) {
        return 1;
    }
    if ([tabLabel isEqualToString:@"Train"]) {
        return 2;
    }
    // must be "Test" if we are here
    return 3;
}

-(BOOL)nextButtonReady {
    BOOL result = NO;
    switch (currentTab) {
        case 0:
            if (![txtPositiveLabel.stringValue isEqual: @""] && ![txtNegativeLabel.stringValue isEqual:@""] && positiveImageCount > 0 && negativeImageCount > 0) {
                result = YES;
            }
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        default:
            break;
    }
    return result;
}


#pragma mark - Utilities
- (NSImage*) imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil; // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image); [newImage unlockFocus];
    return newImage;
}

@end

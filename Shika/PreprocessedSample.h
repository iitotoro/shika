//
//  PreprocessedSample.h
//  Shika
//
//  Created by Chamin Morikawa on 10/6/14.
//  Copyright (c) 2014 Motion Portrait Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreprocessedSample : NSObject

-(id)initWithImage:(NSURL*)imgURL andAspectRatio:(float)aspectRatio;
-(NSString*)getAttributeString;
-(NSString*)getSamplePath;

@end

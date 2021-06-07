//
//  GCLabel.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/31/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface GCLabel : UILabel {
    VerticalAlignment verticalAlignment;
}

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end
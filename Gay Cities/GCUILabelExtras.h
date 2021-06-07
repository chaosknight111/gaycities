//
//  GCUILabelExtras.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/29/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UILabel (GCUILabelExtras)


+ (UILabel *)gcLabelForTableHeaderView;
+ (UILabel *)gcLabelWhiteForTableHeaderView;
+ (UILabel *)gcLabelBlueForTableHeaderView:(float)height;
+ (UILabel *)gcLabelBlueForTableHeaderViewLarger:(float)height;
+ (UILabel *)gcLabelClearForTableHeaderView;

@end

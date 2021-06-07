//
//  OCSearchBar.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/6/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OCSearchBar : UITextField {
	UIButton *ocCancelButton;
	BOOL showCancel;
}

@property (nonatomic, retain) UIButton *ocCancelButton;
@property (readwrite) BOOL showCancel;


@end

//
//  GCBrowseViewCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/8/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCBrowseViewCell : UITableViewCell {
	UIImageView *typeImage;
	UILabel *typeName;
	NSString *someIdentifierWord;
}
@property (nonatomic, retain) IBOutlet UIImageView *typeImage;
@property (nonatomic, retain) IBOutlet UILabel *typeName;
@property (nonatomic, copy) NSString *someIdentifierWord;

@end

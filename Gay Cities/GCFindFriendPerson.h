//
//  FindFriendPerson.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/1/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCFindFriendPersonDelegate.h"
#import "ASIHTTPRequest.h"

@interface GCFindFriendPerson : NSObject {

	
	NSString *username, *email, *first_name, *last_name, *twitter_name, *profile_image_url, *passed_full_name, *facebook_uid;
	UIImage *profileImage;
	NSObject<GCFindFriendPersonDelegate> *delegate;
	ASIHTTPRequest *request;
	BOOL profileImageAlreadyRequested, already_friend, invite_sent;
	
}
	
@property (nonatomic, copy) NSString *username, *email, *first_name, *last_name, *twitter_name, *profile_image_url, *passed_full_name, *facebook_uid;
@property (nonatomic, retain) UIImage *profileImage;
@property (nonatomic, assign) NSObject<GCFindFriendPersonDelegate> *delegate;
@property (nonatomic, readwrite) BOOL already_friend, invite_sent;

- (id)initWithImage:(UIImage *)image;
- (void)loadURL:(NSURL *)url;
	

	

@end

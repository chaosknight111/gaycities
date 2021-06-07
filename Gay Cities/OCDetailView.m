//
//  OCDetailView.m
//  DetailView
//
//  Created by Brian Harmann on 7/31/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "OCDetailView.h"


@implementation OCDetailView

@synthesize textLabel, anchorPoint, captionLabel;
@synthesize detailColor, textColor;
@synthesize detailButton;
//@synthesize listing;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.exclusiveTouch = YES;
		
		
    }
    return self;
}

//designated initializer
- (id)initWithText:(NSString *)newText andAnchorPoint:(CGPoint)point andCaption:(NSString *)captionText
{
    if (self = [super init]) {
		float maxWidth = 250;
		CGSize textSize = [newText sizeWithFont:[UIFont boldSystemFontOfSize:15]];
		CGSize captionSize = [captionText sizeWithFont: [UIFont systemFontOfSize: 13]];
		anchorPoint = point;
		float nameWidth = textSize.width + 45;
		float captionWidth = captionSize.width + 45;
		int rectWidth = 0;
		
		if (nameWidth > maxWidth) {
			nameWidth = maxWidth;
		}
		
		if (captionWidth > maxWidth) {
			captionWidth = maxWidth;
		}
		
		if (nameWidth < 70 && captionWidth < 70) {
			rectWidth = 70;
		} else if (nameWidth > captionWidth) {
			rectWidth = nameWidth;
		} else {
			rectWidth = captionWidth;
		}
		
		if (rectWidth % 2 == 1) {
			rectWidth = rectWidth + 1;
		}
		
		int height = textSize.height;
		if (height % 2 == 1) {
			textSize.height = height + 1;
		}
		
		ex = rectWidth/2;
		
		detailColor = [[UIColor blackColor] retain];
		textColor = [[UIColor whiteColor] retain];
		
		if ([captionText length] > 0) {
			self.frame = CGRectMake(anchorPoint.x - (rectWidth/2), anchorPoint.y - (textSize.height + captionSize.height + 36), rectWidth, textSize.height + 50);
			captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, captionWidth - 35, captionSize.height)];
			[captionLabel setNumberOfLines:1];
			[captionLabel setBackgroundColor:[UIColor clearColor]];
			[captionLabel setTextColor:textColor];
			[captionLabel setFont:[UIFont systemFontOfSize: 13]];
			[captionLabel setTextAlignment:UITextAlignmentLeft];
			[captionLabel setText:captionText];
			[self addSubview:captionLabel];
			[captionLabel release];
			
		} else {
			self.frame = CGRectMake(anchorPoint.x - (rectWidth/2), anchorPoint.y - (textSize.height + 30), rectWidth, textSize.height + 30);
			captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			[self addSubview:captionLabel];
			[captionLabel release];
		}
		
		
		buttonShown = YES;

		detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		detailButton.frame = CGRectMake(self.frame.size.width - 35, (self.frame.size.height - 15)/2 - 15, 30, 30);
		[self addSubview:detailButton];
		
		
		
		textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, nameWidth - 35, textSize.height)];
		[textLabel setNumberOfLines:1];
		[textLabel setBackgroundColor:[UIColor clearColor]];
		[textLabel setTextColor:textColor];
		[textLabel setFont:[UIFont boldSystemFontOfSize:15]];
		[textLabel setTextAlignment:UITextAlignmentLeft];
		[textLabel setText:newText];
		[self addSubview:textLabel];
		[textLabel release];
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		
		
		//[self setNeedsDisplay];*/
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, true);
	CGContextSaveGState(context);

	CGLayerRef layer = CGLayerCreateWithContext(context, rect.size, NULL);
	CGContextRef layerContext = CGLayerGetContext(layer);
	CGContextSetLineWidth(context, 0);
	CGContextSetFillColorWithColor(context, [[detailColor colorWithAlphaComponent:.77] CGColor]);
/*
	CGContextMoveToPoint(context, 2, 5);
	CGContextAddArcToPoint(context, 2, 2, 5, 2, 3);
	CGContextAddLineToPoint(context, rect.size.width-5, 2);
	CGContextAddArcToPoint(context, rect.size.width-2, 2, rect.size.width - 2, 5, 3);
	CGContextAddLineToPoint(context, rect.size.width - 2, (rect.size.height - 15)/2 - 3);
	CGContextAddArcToPoint(context, rect.size.width-2, (rect.size.height - 15)/2, rect.size.width - 5, (rect.size.height - 15)/2, 3);
	CGContextAddLineToPoint(context, 5, (rect.size.height - 15)/2);
	CGContextAddArcToPoint(context, 2, (rect.size.height - 15)/2, 2, (rect.size.height - 15)/2 - 3, 3);
	CGContextAddLineToPoint(context, 2, 5);
	CGContextFillPath(context);*/
	
	
	CGContextBeginPath(layerContext);
	CGContextMoveToPoint(layerContext, 2, 5);
	CGContextAddArcToPoint(layerContext, 2, 2, 5, 2, 3);
	CGContextAddLineToPoint(layerContext, rect.size.width-5, 2);
	CGContextAddArcToPoint(layerContext, rect.size.width-2, 2, rect.size.width - 2, 5, 3);
	CGContextAddLineToPoint(layerContext, rect.size.width - 2, rect.size.height - 19);
	CGContextAddArcToPoint(layerContext, rect.size.width-2, rect.size.height - 16, rect.size.width - 5, rect.size.height - 16, 3);
	CGContextAddLineToPoint(layerContext, ex + 10, rect.size.height - 16);
	CGContextAddLineToPoint(layerContext, ex, rect.size.height - 1);
	CGContextAddLineToPoint(layerContext, ex - 10, rect.size.height - 16);
	CGContextAddLineToPoint(layerContext, 5, rect.size.height - 16);
	CGContextAddArcToPoint(layerContext, 2, rect.size.height - 16, 2, rect.size.height - 19, 3);
	CGContextAddLineToPoint(layerContext, 2, 5);
	CGContextClosePath(layerContext);
	CGContextSetLineWidth(layerContext, 1);
	CGContextSetFillColorWithColor(layerContext, [[detailColor colorWithAlphaComponent:.77] CGColor]);
	CGContextFillPath(layerContext);

	
	CGContextSetFillColorWithColor(layerContext, [[detailColor colorWithAlphaComponent:.25] CGColor]);
	CGContextSetLineWidth(layerContext, 0);
	CGContextBeginPath(layerContext);
	CGContextMoveToPoint(layerContext, rect.size.width - 2, (rect.size.height - 16)/2 - 3);
	CGContextAddArcToPoint(layerContext, rect.size.width-2, (rect.size.height - 16)/2, rect.size.width - 5, (rect.size.height - 16)/2, 3);
	CGContextAddLineToPoint(layerContext, 5, (rect.size.height - 16)/2);
	CGContextAddArcToPoint(layerContext, 2, (rect.size.height - 16)/2, 2, (rect.size.height - 16)/2 - 3, 3);
	CGContextAddLineToPoint(layerContext, 2, rect.size.height - 19);
	CGContextAddArcToPoint(layerContext, 2, rect.size.height - 16, 5, rect.size.height - 16, 3);
	CGContextAddLineToPoint(layerContext, ex - 10, rect.size.height - 16);
	CGContextAddLineToPoint(layerContext, ex, rect.size.height - 1);
	CGContextAddLineToPoint(layerContext, ex + 10, rect.size.height - 16);
	CGContextAddLineToPoint(layerContext, rect.size.width - 5, rect.size.height - 16);
	CGContextAddArcToPoint(layerContext, rect.size.width-2, rect.size.height - 16, rect.size.width - 2, rect.size.height - 19, 3);
	CGContextAddLineToPoint(layerContext, rect.size.width - 2, (rect.size.height - 16)/2 - 3);
	CGContextFillPath(layerContext);
	
	

	CGContextSetStrokeColorWithColor(layerContext, [[detailColor colorWithAlphaComponent:.4] CGColor]);
	CGContextSetLineWidth(layerContext, 2);
	CGContextBeginPath(layerContext);
	CGContextMoveToPoint(layerContext, 2, 5);
	CGContextAddArcToPoint(layerContext, 2, 2, 5, 2, 3);
	CGContextAddLineToPoint(layerContext, rect.size.width-5, 2);
	CGContextAddArcToPoint(layerContext, rect.size.width-2, 2, rect.size.width - 2, 5, 3);
	CGContextAddLineToPoint(layerContext, rect.size.width - 2, rect.size.height - 19);
	CGContextAddArcToPoint(layerContext, rect.size.width-2, rect.size.height - 16, rect.size.width - 5, rect.size.height - 16, 3);
	CGContextAddLineToPoint(layerContext, ex + 10, rect.size.height - 16);
	CGContextAddLineToPoint(layerContext, ex, rect.size.height - 1);
	CGContextAddLineToPoint(layerContext, ex - 10, rect.size.height - 16);
	CGContextAddLineToPoint(layerContext, 5, rect.size.height - 16);
	CGContextAddArcToPoint(layerContext, 2, rect.size.height - 16, 2, rect.size.height - 19, 3);
	CGContextAddLineToPoint(layerContext, 2, 5);
	CGContextStrokePath(layerContext);
	 
	 
	CGContextDrawLayerInRect(context, rect, layer);  //draw the layer to the actual drawing context

	
	CGLayerRelease(layer);  //release the layer
	CGContextRestoreGState(context);
	


}


- (void)dealloc {
	if (!self.isHidden) {
		[self setHidden:YES];
	}
	[detailColor release];
	[textColor release];
	//self.textLabel = nil;
	//self.captionLabel = nil;
	//self.detailButton = nil;
    [super dealloc];
}

- (void)setAnchorX:(float)x
{
	float width = self.frame.size.width/2;
	if (x < width) {
		ex = x;
		if (ex < 30) {
			ex = 30;
		}
		self.frame = CGRectMake(anchorPoint.x - ex, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
		
	} else if (320 - x < width) {
		ex = x - (320 - self.frame.size.width);
		if (ex > self.frame.size.width - 40) {
			ex = self.frame.size.width - 40;
		}
		
		self.frame = CGRectMake(anchorPoint.x - ex, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
	} else {
		ex = width;
		self.frame = CGRectMake(anchorPoint.x - ex, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
	}

	[self setNeedsDisplay];
}



- (void)setButtonAction:(SEL)action toObject:(id)target forEvent:(UIControlEvents)event
{
	[detailButton addTarget:target action:action forControlEvents:event];
}





@end

//
//  DoubleShadowLabel.m
//  BeierholmContacts
//
//  Created by Aleks Nesterow on 11/29/10.
//	aleks@screencustoms.com
//	
//  Copyright © 2010 Screencustoms, LLC.
//	All rights reserved.
//

#import "TKLabel.h"

@implementation TKLabel

- (void)__initializeComponent
{
	self.font = [UIFont boldSystemFontOfSize:15];
	self.textColor = [UIColor colorWithRed:178 / 255. green:82 / 255. blue:10 / 255. alpha:1];
	self.highlightedTextColor = [UIColor colorWithRed:136 / 255. green:136 / 255. blue:136 / 255. alpha:1];
}

- (id)init
{
    self = [super init];
	
    if (self)
	{
		[self __initializeComponent];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
	if (self)
	{
		[self __initializeComponent];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self)
	{
		[self __initializeComponent];
	}
	
	return self;
}

- (UIImage*)blackSquareOfSize:(CGSize)size
{
	/* Way to be compatible with iOS < 4.0. */
	if (UIGraphicsBeginImageContextWithOptions != NULL)
	{
		UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	}
	else
	{
		UIGraphicsBeginImageContext(size);
	}
	
	[[UIColor blackColor] setFill];
	CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
	UIImage *blackSquare = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return blackSquare;
}

- (CGImageRef)createMaskWithSize:(CGSize)size shape:(void (^)(void))block
{
	if (UIGraphicsBeginImageContextWithOptions != NULL)
	{
		UIGraphicsBeginImageContextWithOptions(size, NO, 0);  
	}
	else
	{
		UIGraphicsBeginImageContext(size);
	}
	
	block();
	
	CGImageRef shape = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
	UIGraphicsEndImageContext();  
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(shape),
										CGImageGetHeight(shape),
										CGImageGetBitsPerComponent(shape),
										CGImageGetBitsPerPixel(shape),
										CGImageGetBytesPerRow(shape),
										CGImageGetDataProvider(shape), NULL, false);
	return mask;
}

- (void)drawRect:(CGRect)rect
{
	CGSize fontSize = [self.text sizeWithFont:self.font];
	
	CGFloat width = CGRectGetWidth(self.bounds);
	CGFloat height = CGRectGetHeight(self.bounds);
	
	CGFloat textX;
	
	switch (self.textAlignment)
	{
		case UITextAlignmentLeft:
			textX = 0;
			break;
		case UITextAlignmentCenter:
			textX = (width - fontSize.width) / 2.;
			break;
		case UITextAlignmentRight:
			textX = width - fontSize.width;
			break;
	}
	
	CGFloat textY = (height - fontSize.height) / 2.;
	
	CGImageRef mask = [self createMaskWithSize:rect.size shape:^{
		[[UIColor blackColor] setFill];
		CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
		[[UIColor whiteColor] setFill];
		
		/* Custom shape goes here. */
		
		[self.text drawAtPoint:CGPointMake(textX, textY) withFont:self.font];
		[self.text drawAtPoint:CGPointMake(textX, textY - 1) withFont:self.font];
	}];
	
	CGImageRef cutoutRef = CGImageCreateWithMask([self blackSquareOfSize:rect.size].CGImage, mask);
	CGImageRelease(mask);
	
	UIImage *cutout;
	
	if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
	{
		cutout = [UIImage imageWithCGImage:cutoutRef scale:[[UIScreen mainScreen] scale]
							   orientation:UIImageOrientationUp];
	}
	else
	{
		cutout = [UIImage imageWithCGImage:cutoutRef];
	}
	
	CGImageRelease(cutoutRef);  
	
	CGImageRef shadedMask = [self createMaskWithSize:rect.size shape:^{
		[[UIColor whiteColor] setFill];
		CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
		CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 1), 1.0f
									, [[UIColor colorWithWhite:0.0 alpha:0.5] CGColor]);
		[cutout drawAtPoint:CGPointZero];
	}];
	
	/* Create negative image. */
	if (UIGraphicsBeginImageContextWithOptions != NULL)
	{
		UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
	}
	else
	{
		UIGraphicsBeginImageContext(rect.size);
	}
	
	[[UIColor blackColor] setFill];
	/* Custom shape goes here. */
	[self.text drawAtPoint:CGPointMake(textX, textY - 1) withFont:self.font];
	UIImage *negative = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext(); 
	
	CGImageRef innerShadowRef = CGImageCreateWithMask(negative.CGImage, shadedMask);
	CGImageRelease(shadedMask);
	
	UIImage *innerShadow;
	
	if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
	{
		innerShadow = [UIImage imageWithCGImage:innerShadowRef scale:[[UIScreen mainScreen] scale]
										 orientation:UIImageOrientationUp];
	}
	else
	{
		innerShadow = [UIImage imageWithCGImage:innerShadowRef];
	}
	
	CGImageRelease(innerShadowRef);
	
	/* Draw actual image. */
	[self.shadowColor setFill];
	
	CGFloat xOffset = self.shadowOffset.width;
	CGFloat yOffset = self.shadowOffset.height - 1;
	
	[self.text drawAtPoint:CGPointMake(textX + xOffset, textY + yOffset) withFont:self.font];
	
	if (self.highlighted)
	{
		[self.highlightedTextColor setFill];
	}
	else
	{
		[self.textColor setFill];
	}
	
	[self.text drawAtPoint:CGPointMake(textX, textY - 1) withFont:self.font];  
	
	/* Finally apply shadow. */
	[innerShadow drawAtPoint:CGPointZero];
}

@end

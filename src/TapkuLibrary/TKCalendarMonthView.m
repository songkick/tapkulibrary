//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/10/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKCalendarMonthView.h"

#import "NSDate+TKCategory.h"

#import "TKGlobal.h"
#import "TKLabel.h"

#import "UIImage+TKCategory.h"

@interface NSDate (CalendarCategory)

- (NSDate *)firstOfMonth;
- (NSDate *)nextMonth;
- (NSDate *)previousMonth;

@end

@implementation NSDate (CalendarCategory)

- (NSDate *)firstOfMonth
{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	info.day = 1;
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

- (NSDate *)nextMonth
{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	info.month++;
	
	if (info.month>12)
	{
		info.month = 1;
		info.year++;
	}
	
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

- (NSDate *)previousMonth
{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	info.month--;
	
	if (info.month < 1)
	{
		info.month = 12;
		info.year--;
	}
	
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

@end

@interface TKCalendarColorScheme : NSObject

+ (UIColor *)dayShadowColor;
+ (UIColor *)todayShadowColor;
+ (UIColor *)previousMonthTextColor;
+ (UIColor *)currentMonthTextColor;
+ (UIColor *)todayTextColor;
+ (UIColor *)nextMonthTextColor;
+ (UIColor *)currentDayShadowColor;

@end

@implementation TKCalendarColorScheme

static UIColor *_dayShadowColor;

+ (UIColor *)dayShadowColor
{
	if (!_dayShadowColor)
	{
		_dayShadowColor = [[UIColor colorWithRed:238 / 255. green:237 / 255. blue:239 / 255. alpha:1] retain];
	}
	
	return _dayShadowColor;
}

static UIColor *_todayShadowColor;

+ (UIColor *)todayShadowColor
{
	if (!_todayShadowColor)
	{
		_todayShadowColor = [[UIColor colorWithRed:132 / 255. green:1 / 255. blue:37 / 255. alpha:1] retain];
	}
	
	return _todayShadowColor;
}

static UIColor *_previousMonthTextColor;

+ (UIColor *)previousMonthTextColor
{
	if (!_previousMonthTextColor)
	{
		_previousMonthTextColor = [[UIColor colorWithRed:169 / 255. green:169 / 255. blue:169 / 255. alpha:1] retain];
	}
	
	return _previousMonthTextColor;
}

static UIColor *_currentMonthTextColor;

+ (UIColor *)currentMonthTextColor
{
	if (!_currentMonthTextColor)
	{
		_currentMonthTextColor = [[UIColor colorWithRed:99 / 255. green:99 / 255. blue:99 / 255. alpha:1] retain];
	}
	
	return _currentMonthTextColor;
}

static UIColor *_todayTextColor;

+ (UIColor *)todayTextColor
{
	if (!_todayTextColor)
	{
		_todayTextColor = [UIColor whiteColor];
	}
	
	return _todayTextColor;
}

static UIColor *_nextMonthTextColor;

+ (UIColor *)nextMonthTextColor
{
	if (!_nextMonthTextColor)
	{
		_nextMonthTextColor = [[UIColor colorWithRed:169 / 255. green:169 / 255. blue:169 / 255. alpha:1] retain];
	}
	
	return _nextMonthTextColor;
}

static UIColor *_currentDayShadowColor;

+ (UIColor *)currentDayShadowColor
{
	if (!_currentDayShadowColor)
	{
		_currentDayShadowColor = [[UIColor colorWithRed:73 / 255. green:72 / 255. blue:73 / 255. alpha:1] retain];
	}
	
	return _currentDayShadowColor;
}

@end

@interface TKCalendarMonthTiles : UIView
{	
	id target;
	SEL action;
	
	int firstOfPrev,lastOfPrev;
	NSArray *marks;
	int today;
	BOOL markWasOnToday;
	
	int selectedDay,selectedPortion;
	
	int firstWeekday, daysInMonth;
	UILabel *dot;
	UILabel *currentDay;
	UIImageView *selectedImageView;
	BOOL startOnSunday;
	NSDate *monthDate;
}

@property (readonly) NSDate *monthDate;

- (id)initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday;
- (void)setTarget:(id)target action:(SEL)action;

- (void)selectDay:(int)day;
- (NSDate *)dateSelected;

+ (NSArray *)rangeOfDatesInMonthGrid:(NSDate *)date startOnSunday:(BOOL)sunday;

@end

#define kDotFontSize	18.0
#define kDateFontSize	22.0

@interface TKCalendarMonthTiles (/* Private */)

@property (readonly) UIImageView *selectedImageView;
@property (readonly) UILabel *currentDay;
@property (readonly) UILabel *dot;

@end

@implementation TKCalendarMonthTiles
@synthesize monthDate;

+ (NSArray *)rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday
{	
	NSDate *firstDate, *lastDate;
	
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	info.day = 1;
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	
	NSDate *currentMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info = [currentMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDate *previousMonth = [currentMonth previousMonth];
	NSDate *nextMonth = [currentMonth nextMonth];
	
	if (info.weekday > 1 && sunday)
	{
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];		
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	else if (!sunday && info.weekday != 2)
	{
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		
		if(info.weekday==1)
		{
			info2.day = preDayCnt - 5;
		}
		else
		{
			info2.day = preDayCnt - info.weekday + 3;
		}
		
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	else
	{
		firstDate = currentMonth;
	}
	
	int daysInMonth = [currentMonth daysBetweenDate:nextMonth];		
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	TKDateInformation lastDateInfo = [lastInMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	if (lastDateInfo.weekday < 7 && sunday)
	{
		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		
		if (lastDateInfo.month>12)
		{
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	else if (!sunday && lastDateInfo.weekday != 1)
	{
		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		
		if (lastDateInfo.month>12)
		{
			lastDateInfo.month = 1; lastDateInfo.year++;
		}
		
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	else
	{
		lastDate = lastInMonth;
	}
	
	return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday
{
	if (![super initWithFrame:CGRectZero])
	{
		return nil;
	}
	
	firstOfPrev = -1;
	marks = [markArray retain];
	monthDate = [date retain];
	startOnSunday = sunday;
	
	TKDateInformation dateInfo = [monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	firstWeekday = dateInfo.weekday;
	
	NSDate *prev = [monthDate previousMonth];
	
	daysInMonth = [[monthDate nextMonth] daysBetweenDate:monthDate];
	
	int row = (daysInMonth + dateInfo.weekday - 1);
	
	if (dateInfo.weekday==1&&!sunday)
	{
		row = daysInMonth + 6;
	}
	
	if (!sunday) 
	{
		row--;
	}
	
	row = (row / 7) + ((row % 7 == 0) ? 0:1);
	float h = 44 * row;
	
	TKDateInformation todayInfo = [[NSDate date] dateInformation];
	today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
	
	int preDayCnt = [prev daysBetweenDate:monthDate];		
	if (firstWeekday>1 && sunday)
	{
		firstOfPrev = preDayCnt - firstWeekday+2;
		lastOfPrev = preDayCnt;
	}
	else if (!sunday && firstWeekday != 2)
	{
		if (firstWeekday ==1)
		{
			firstOfPrev = preDayCnt - 5;
		}
		else
		{
			firstOfPrev = preDayCnt - firstWeekday + 3;
		}
		
		lastOfPrev = preDayCnt;
		
	}
	
	self.frame = CGRectMake(0, 1, 320, h + 1);
	
	[self.selectedImageView addSubview:self.currentDay];
	[self.selectedImageView addSubview:self.dot];
	self.multipleTouchEnabled = NO;
	
	return self;
}

- (void)setTarget:(id)t action:(SEL)a
{
	target = t;
	action = a;
}

- (CGRect)rectForCellAtIndex:(int)index
{	
	int row = index / 7;
	int col = index % 7;
	
	return CGRectMake(col*46, row*44, 47, 45);
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

- (void)drawString:(NSString *)string inRect:(CGRect)rect withFont:(UIFont *)font lineBreak:(UILineBreakMode)mode
		 alignment:(UITextAlignment)alignment textColor:(UIColor *)textColor today:(BOOL)yesOrNo
{
	CGSize fontSize = [string sizeWithFont:font];
	
	CGFloat width = CGRectGetWidth(rect);
	CGFloat height = CGRectGetHeight(rect);
	
	CGFloat textX;
	
	switch (alignment)
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
		CGContextFillRect(UIGraphicsGetCurrentContext(), /* rect */ CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
		[[UIColor whiteColor] setFill];
		
		/* Custom shape goes here. */
		
		[string drawAtPoint:CGPointMake(textX, textY) withFont:font];
		[string drawAtPoint:CGPointMake(textX, textY - 1) withFont:font];
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
		CGContextFillRect(UIGraphicsGetCurrentContext(), /* rect */ CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
		CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 1), 1.0f
									, [[UIColor colorWithWhite:0.0 alpha:0.5] CGColor]);
		[cutout drawAtPoint:CGPointMake(0, 0)];
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
	[string drawAtPoint:CGPointMake(textX, textY - 1) withFont:font];
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
	
	textX += CGRectGetMinX(rect);
	textY += CGRectGetMinY(rect);
	
	if (yesOrNo)
	{
		[[TKCalendarColorScheme todayShadowColor] setFill];
		[string drawAtPoint:CGPointMake(textX, textY - 2) withFont:font];
	}
	else
	{
		[[TKCalendarColorScheme dayShadowColor] setFill];
		[string drawAtPoint:CGPointMake(textX, textY) withFont:font];
	}
	
	[textColor setFill];
	[string drawAtPoint:CGPointMake(textX, textY - 1) withFont:font]; 
	
	/* Finally apply shadow. */
	[innerShadow drawAtPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
}

- (void)drawTileInRect:(CGRect)r day:(int)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2
			 textColor:(UIColor *)textColor today:(BOOL)yesOrNo
{	
	NSString *str = [NSString stringWithFormat:@"%d",day];
	
	[self drawString:str inRect:r withFont:f1 lineBreak:UILineBreakModeWordWrap alignment:UITextAlignmentCenter
		   textColor:textColor today:yesOrNo];
	
	if (mark)
	{
		r.size.height = 10;
		r.origin.y += 18;
		
		[@"•" drawInRect:r withFont:f2 lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	}
}

- (void)drawRect:(CGRect)rect
{	
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIImage *tile = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")];
	CGRect r = CGRectMake(0, 0, 46, 44);
	CGContextDrawTiledImage(context, r, tile.CGImage);
	
	if (today > 0)
	{
		int pre = firstOfPrev > 0 ? lastOfPrev - firstOfPrev + 1 : 0;
		int index = today + pre-1;
		CGRect r =[self rectForCellAtIndex:index];
		r.origin.y -= 1;
		[[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Tile.png")] drawInRect:r];
	}
	
	int index = 0;
	
	UIFont *font = [UIFont boldSystemFontOfSize:kDateFontSize];
	UIFont *font2 =[UIFont boldSystemFontOfSize:kDotFontSize];
	
	/* Drawing previous month days. */
	
	UIColor *color = [TKCalendarColorScheme previousMonthTextColor];
	
	if (firstOfPrev > 0)
	{
		for (int i = firstOfPrev; i<= lastOfPrev;i++)
		{
			r = [self rectForCellAtIndex:index];
			
			if ([marks count] > 0)
			{
				[self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:font font2:font2
						   textColor:color today:NO];
			}
			else
			{
				[self drawTileInRect:r day:i mark:NO font:font font2:font2 textColor:color today:NO];
			}
			
			index++;
		}
	}
	
	/* Drawing current month unselected days. */
	
	color = [TKCalendarColorScheme currentMonthTextColor];
	
	for (int i = 1; i <= daysInMonth; i++)
	{
		r = [self rectForCellAtIndex:index];
		
		UIColor *textColor = color;
		
		if (today == i)
		{
			textColor = [UIColor whiteColor];
		}
		
		if ([marks count] > 0)
		{
			[self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:font font2:font2
					   textColor:textColor today:today == i];
		}
		else
		{
			[self drawTileInRect:r day:i mark:NO font:font font2:font2 textColor:textColor today:today == i];
		}
		
		index++;
	}
	
	/* Drawing next number days. */
	
	color = [TKCalendarColorScheme nextMonthTextColor];
	
	int i = 1;
	
	while (index % 7 != 0)
	{
		r = [self rectForCellAtIndex:index];
		
		if ([marks count] > 0) 
		{
			[self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:font font2:font2
					   textColor:color today:NO];
		}
		else
		{
			[self drawTileInRect:r day:i mark:NO font:font font2:font2 textColor:color today:NO];
		}
		
		i++;
		index++;
	}
}

- (void)selectDay:(int)day
{	
	int pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
	
	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;
	
	selectedDay = day;
	selectedPortion = 1;
	
	if (day == today)
	{
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
		markWasOnToday = YES;
	}
	else if (markWasOnToday)
	{
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d", day];
	
	if ([marks count] > 0)
	{
		if ([[marks objectAtIndex: row * 7 + column ] boolValue])
		{
			[self.selectedImageView addSubview:self.dot];
		}
		else
		{
			[self.dot removeFromSuperview];
		}
	}
	else
	{
		[self.dot removeFromSuperview];
	}
	
	if (column < 0)
	{
		column = 6;
		row--;
	}
	
	CGRect r = self.selectedImageView.frame;
	
	r.origin.x = (column * 46);
	r.origin.y = (row * 44) - 1;
	
	self.selectedImageView.frame = r;
}

- (NSDate *)dateSelected
{
	if (selectedDay < 1 || selectedPortion != 1) 
	{
		return nil;
	}
	
	TKDateInformation info = [monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	info.day = selectedDay;
	
	NSDate *d = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	return d;
}

- (void)reactToTouch:(UITouch *)touch down:(BOOL)down
{	
	CGPoint p = [touch locationInView:self];
	
	if (p.y > self.bounds.size.height || p.y < 0)
	{
		return;
	}
	
	int column = p.x / 46, row = p.y / 44;
	int day = 1, portion = 0;
	
	if (row == (int) (self.bounds.size.height / 44)) 
	{
		row --;
	}
	
	int fir = firstWeekday - 1;
	
	if (!startOnSunday && fir == 0)
	{
		fir = 7;
	}
	
	if (!startOnSunday) 
	{
		fir--;
	}
	
	if (row==0 && column < fir)
	{
		day = firstOfPrev + column;
	}
	else
	{
		portion = 1;
		day = row * 7 + column  - firstWeekday+2;
		if (!startOnSunday) day++;
		if (!startOnSunday && fir==6) day -= 7;
	}
	
	if (portion > 0 && day > daysInMonth)
	{
		portion = 2;
		day = day - daysInMonth;
	}
	
	if (portion != 1)
	{
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
		markWasOnToday = YES;
	}
	else if (portion==1 && day == today)
	{
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
		markWasOnToday = YES;
	}
	else if (markWasOnToday)
	{
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
	
	if ([marks count] > 0)
	{
		if ([[marks objectAtIndex: row * 7 + column] boolValue])
		{
			[self.selectedImageView addSubview:self.dot];
		}
		else
		{
			[self.dot removeFromSuperview];
		}
	}
	else
	{
		[self.dot removeFromSuperview];
	}
	
	CGRect r = self.selectedImageView.frame;
	r.origin.x = (column * 46);
	r.origin.y = (row * 44) - 1;
	self.selectedImageView.frame = r;
	
	if(day == selectedDay && selectedPortion == portion) 
	{
		return;
	}
	
	if (portion == 1)
	{
		selectedDay = day;
		selectedPortion = portion;
		[target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]];
	}
	else if (down)
	{
		[target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil]];
		selectedDay = day;
		selectedPortion = portion;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self reactToTouch:[touches anyObject] down:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self reactToTouch:[touches anyObject] down:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self reactToTouch:[touches anyObject] down:YES];
}

- (UILabel *)currentDay
{
	if (!currentDay)
	{
		CGRect r = self.selectedImageView.bounds;
		r.origin.y += 1;
		currentDay = [[TKLabel alloc] initWithFrame:r];
		currentDay.text = @"1";
		currentDay.textColor = [UIColor whiteColor];
		currentDay.backgroundColor = [UIColor clearColor];
		currentDay.font = [UIFont boldSystemFontOfSize:kDateFontSize];
		currentDay.textAlignment = UITextAlignmentCenter;
		currentDay.shadowColor = [TKCalendarColorScheme currentDayShadowColor];
		currentDay.shadowOffset = CGSizeMake(0, -1);
	}
	
	return currentDay;
}

- (UILabel *)dot
{
	if (!dot)
	{
		CGRect r = self.selectedImageView.bounds;
		r.origin.y += 29;
		r.size.height -= 31;
		dot = [[UILabel alloc] initWithFrame:r];
		
		dot.text = @"•";
		dot.textColor = [UIColor whiteColor];
		dot.backgroundColor = [UIColor clearColor];
		dot.font = [UIFont boldSystemFontOfSize:kDotFontSize];
		dot.textAlignment = UITextAlignmentCenter;
		dot.shadowColor = [UIColor darkGrayColor];
		dot.shadowOffset = CGSizeMake(0, -1);
	}
	
	return dot;
}

- (UIImageView *)selectedImageView
{
	if (!selectedImageView)
	{
		selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected"]];
	}
	
	return selectedImageView;
}

- (void)dealloc
{
	[currentDay release];
	[dot release];
	[selectedImageView release];
	[marks release];
	[monthDate release];
	
    [super dealloc];
}

@end

@interface TKCalendarMonthView (/* Private */)

@property (readonly) UIScrollView *tileBox;
@property (readonly) UIImageView *topBackground;
@property (readonly) UILabel *monthYear;
@property (readonly) UIButton *leftArrow;
@property (readonly) UIButton *rightArrow;
@property (readonly) UIImageView *shadow;

@end

@implementation TKCalendarMonthView

@synthesize delegate, dataSource;

- (void)__initializeComponentWithSundayAsFirst:(BOOL)s
{
	sunday = s;
	
	NSDate *firstOfMonth = [[NSDate date] firstOfMonth];
	
	currentTile = [[TKCalendarMonthTiles alloc] initWithMonth:firstOfMonth marks:nil startDayOnSunday:sunday];
	[currentTile setTarget:self action:@selector(tile:)];
	
	[self addSubview:self.topBackground];
	[self.tileBox addSubview:currentTile];
	[self addSubview:self.tileBox];
	
	NSDate *date = [NSDate date];
	self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[date month],[date year]];
	[self addSubview:self.monthYear];
	
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	
	[self addSubview:self.shadow];
	self.shadow.frame = CGRectMake(0, self.frame.size.height - self.shadow.frame.size.height + 21
								   , self.shadow.frame.size.width, self.shadow.frame.size.height);
	
	self.backgroundColor = [UIColor grayColor];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"eee"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	TKDateInformation sund;
	sund.day = 5;
	sund.month = 12;
	sund.year = 2010;
	sund.hour = 0;
	sund.minute = 0;
	sund.second = 0;
	sund.weekday = 0;
	
	NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSString * sun = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 6;
	NSString *mon = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 7;
	NSString *tue = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 8;
	NSString *wed = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 9;
	NSString *thu = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 10;
	NSString *fri = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 11;
	NSString *sat = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	[dateFormat release];
	
	NSArray *ar;
	if(sunday) ar = [NSArray arrayWithObjects:sun, mon, tue, wed, thu, fri, sat, nil];
	else ar = [NSArray arrayWithObjects:mon, tue, wed, thu, fri, sat, sun, nil];
	
	int i = 0;
	
	for (NSString *s in ar)
	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46 * i, 29, 46, 15)];
		[self addSubview:label];
		label.text = s;
		label.textAlignment = UITextAlignmentCenter;
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.font = [UIFont systemFontOfSize:11];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor colorWithRed:84/255. green:84/255. blue:84/255. alpha:1];
		
		i++;
		[label release];
	}
}

- (id)init
{
	return [self initWithSundayAsFirst:NO];
}

- (id)initWithSundayAsFirst:(BOOL)yesOrNo
{	
	if (self = [super init])
	{
		[self __initializeComponentWithSundayAsFirst:yesOrNo];
	}
	
	return self;
}

/* AN [27 Jan 2011]: Added */
- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame sundayAsFirst:NO];
}

/* AN [27 Jan 2011]: Added */
- (id)initWithFrame:(CGRect)frame sundayAsFirst:(BOOL)yesOrNo
{
	if (self = [super initWithFrame:frame])
	{
		[self __initializeComponentWithSundayAsFirst:yesOrNo];
	}
	
	return self;
}

/* AN [26 Jan 2011]: Added */
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self __initializeComponentWithSundayAsFirst:NO];
	}
	
	return self;
}

- (void) dealloc
{
	[shadow release];
	[topBackground release];
	[leftArrow release];
	[monthYear release];
	[rightArrow release];
	[tileBox release];
	[currentTile release];
	
    [super dealloc];
}

- (void)changeMonthAnimation:(UIView*)sender
{	
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:nextMonth marks:ar startDayOnSunday:sunday];
	[newTile setTarget:self action:@selector(tile:)];
	
	int overlap =  0;
	
	if (isNext)
	{
		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
	}
	else
	{
		overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
	}
	
	float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap;
	
	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
	[self.tileBox addSubview:newTile];
	[self.tileBox bringSubviewToFront:currentTile];
	
	self.userInteractionEnabled = NO;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationEnded)];
	[UIView setAnimationDuration:0.4];
	
	currentTile.alpha = 0.0;
	
	if (isNext)
	{
		currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap, currentTile.frame.size.width, currentTile.frame.size.height);
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
	}
	else
	{
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
	}
	
	[UIView commitAnimations];
	
	oldTile = currentTile;
	currentTile = newTile;
	
	monthYear.text = [NSString stringWithFormat:@"%@ %@", [localNextMonth month], [localNextMonth year]];
}

- (void)changeMonth:(UIButton *)sender
{	
	[self changeMonthAnimation:sender];
	
	if ([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:)])
	{
		[delegate calendarMonthView:self monthDidChange:currentTile.monthDate];
	}
}

- (void)animationEnded
{
	self.userInteractionEnabled = YES;
	[oldTile release];
	oldTile = nil;
}

- (NSDate *)dateSelected
{
	return [currentTile dateSelected];
}

- (NSDate *)monthDate
{
	return [currentTile monthDate];
}

/*!
 @updated 4 Feb 2011 by Aleks Nesterow-Rutkowski
 Fixed: When initialized from IB, "short months" had odd gray stripe at the bottom.
 */
- (void)selectDate:(NSDate*)date
{
	TKDateInformation info = [date dateInformation];
	
	NSDate *month = [date firstOfMonth];
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday];
	NSArray *data = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month 
																		  marks:data 
															   startDayOnSunday:sunday];
	[newTile setTarget:self action:@selector(tile:)];
	[currentTile removeFromSuperview];
	[currentTile release];
	currentTile = newTile;
	[self.tileBox addSubview:currentTile];
	self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
	
	self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
	self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[month month],[month year]];
	[currentTile selectDay:info.day];
}

- (void)reload
{
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	
	TKCalendarMonthTiles *refresh = [[[TKCalendarMonthTiles alloc] initWithMonth:[currentTile monthDate] marks:ar startDayOnSunday:sunday] autorelease];
	[refresh setTarget:self action:@selector(tile:)];
	
	[self.tileBox addSubview:refresh];
	[currentTile removeFromSuperview];
	[currentTile release];
	currentTile = [refresh retain];
}

- (void)tile:(NSArray *)ar
{	
	if ([ar count] < 2)
	{
		if([delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
		{
			[delegate calendarMonthView:self didSelectDate:[self dateSelected]];
		}
	}
	else
	{
		int direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.rightArrow : self.leftArrow;
		
		[self changeMonthAnimation:b];
		
		int day = [[ar objectAtIndex:0] intValue];
		//[currentTile selectDay:day];
		
		// thanks rafael
		TKDateInformation info = [[currentTile monthDate] dateInformation];
		info.day = day;
		NSDate *dateForMonth = [NSDate  dateFromDateInformation:info]; 
		[currentTile selectDay:day];
		
		if([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:)])
		{
			[delegate calendarMonthView:self monthDidChange:dateForMonth];
		}
	}
}

- (UIImageView *) topBackground
{
	if(topBackground==nil)
	{
		topBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")]];
	}
	
	return topBackground;
}

- (UILabel *)monthYear
{
	if(monthYear==nil)
	{
		monthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tileBox.frame.size.width, 34)];
		
		monthYear.textAlignment = UITextAlignmentCenter;
		monthYear.backgroundColor = [UIColor clearColor];
		monthYear.font = [UIFont boldSystemFontOfSize:22];
		monthYear.textColor = [UIColor colorWithRed:56/255. green:56/255. blue:56/255. alpha:1];
	}
	
	return monthYear;
}

- (UIButton *)leftArrow
{
	if (!leftArrow)
	{
		leftArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		leftArrow.tag = 0;
		[leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		
		[leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:0];
		
		leftArrow.frame = CGRectMake(0, 0, 48, 34);
	}
	
	return leftArrow;
}

- (UIButton *)rightArrow
{
	if (!rightArrow)
	{
		rightArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		rightArrow.tag = 1;
		[rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		rightArrow.frame = CGRectMake(320 - 45, 0, 48, 34);
		[rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:0];
	}
	
	return rightArrow;
}

- (UIScrollView *) tileBox
{
	if (!tileBox)
	{
		tileBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, currentTile.frame.size.height)];
	}
	
	return tileBox;
}

- (UIImageView *) shadow
{
	if (!shadow)
	{
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
	}
	
	return shadow;
}

@end

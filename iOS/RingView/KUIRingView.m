#import "KUIRingView.h"

#include <math.h>

#pragma mark Geometric functions

typedef double KCGFloat;

static const KCGFloat KCGAcos(KCGFloat x) {
	if (x <= -1.0) {
		return M_PI;
	} else if (x >= 1.0) {
		return 0.0;
	} else {
		return acos(x);
	}
}

#pragma mark KCGPoint

typedef struct {
	KCGFloat x;
	KCGFloat y;
} KCGPoint;

static const KCGPoint KCGPointZero = {0, 0};

static KCGPoint KCGPointMake(KCGFloat x, KCGFloat y) {
	KCGPoint point = {x, y};
	
	return point;
}

static KCGPoint KCGPointFromCGPoint(CGPoint point) {
	return KCGPointMake(point.x, point.y);
}

__attribute__((unused)) static CGPoint CGPointFromKCGPoint(KCGPoint point) {
	return CGPointMake(point.x, point.y);
}

static KCGPoint KCGPointAdd(KCGPoint point1, KCGPoint point2) {
	return KCGPointMake(point1.x + point2.x, point1.y + point2.y);
}

static KCGPoint KCGPointSubtract(KCGPoint point1, KCGPoint point2) {
	return KCGPointMake(point1.x - point2.x, point1.y - point2.y);
}

static KCGPoint KCGPointMultiply(KCGPoint point, KCGFloat k) {
	return KCGPointMake(point.x * k, point.y * k);
}

static KCGFloat KCGPointGetSquareLength(KCGPoint point) {
	return point.x * point.x + point.y * point.y;
}

static KCGFloat KCGPointGetLength(KCGPoint point) {
	return sqrt(KCGPointGetSquareLength(point));
}

static KCGPoint KCGPointNormalize(KCGPoint point) {
	return KCGPointMultiply(point, 1.0 / KCGPointGetLength(point));
}

static KCGFloat KCGPointGetDotProduct(KCGPoint point1, KCGPoint point2) {
	return point1.x * point2.x + point1.y * point2.y;
}

static KCGFloat KCGPointGetAngleBetween(KCGPoint point1, KCGPoint point2) {
	return KCGAcos(KCGPointGetDotProduct(point1, point2) / sqrt(KCGPointGetSquareLength(point1) * KCGPointGetSquareLength(point2)));
}

static BOOL KCGPointIsFinite(KCGPoint point) {
	return isfinite(point.x) && isfinite(point.y);
}

__attribute__((unused)) static NSString* NSStringFromKCGPoint(KCGPoint point) {
	return [NSString stringWithFormat:@"(%f, %f)", point.x, point.y];
}

#pragma mark KCGAffineTransform

typedef struct {
	KCGFloat a, b, c, d;
	KCGFloat tx, ty;
} KCGAffineTransform;

static const KCGAffineTransform KCGAffineTransformIdentity = {1, 0, 0, 1, 0, 0};

static KCGAffineTransform KCGAffineTransformMake(KCGFloat a, KCGFloat b, KCGFloat c, KCGFloat d, KCGFloat tx, KCGFloat ty) {
	KCGAffineTransform transform = {a, b, c, d, tx, ty};
	
	return transform;
}

static KCGAffineTransform KCGAffineTransformMakeTranslation(KCGFloat tx, KCGFloat ty) {
	return KCGAffineTransformMake(1, 0, 0, 1, tx, ty);
}

static KCGAffineTransform KCGAffineTransformMakeRotation(KCGFloat angle) {
	return KCGAffineTransformMake(cos(angle), sin(angle), -sin(angle), cos(angle), 0, 0);
}

static KCGAffineTransform KCGAffineTransformMakeScale(KCGFloat sx, KCGFloat sy) {
	return KCGAffineTransformMake(sx, 0, 0, sy, 0, 0);
}

__attribute__((unused)) static CGAffineTransform CGAffineTransformFromKCGAffineTransform(KCGAffineTransform transform) {
	return CGAffineTransformMake(transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
}

static KCGAffineTransform KCGAffineTransformConcat(KCGAffineTransform transform1, KCGAffineTransform transform2) {
	KCGAffineTransform transform = KCGAffineTransformMake(transform1.a * transform2.a + transform1.b * transform2.c, transform1.a * transform2.b + transform1.b * transform2.d, transform1.c * transform2.a + transform1.d * transform2.c, transform1.c * transform2.b + transform1.d * transform2.d, transform1.tx * transform2.a + transform1.ty * transform2.c + transform2.tx, transform1.tx * transform2.b + transform1.ty * transform2.d + transform2.ty);
	
	return transform;
}

static KCGPoint KCGPointApplyAffineTransform(KCGPoint point, KCGAffineTransform transform) {
	KCGPoint result = KCGPointMake(transform.a * point.x + transform.c * point.y + transform.tx, transform.b * point.x + transform.d * point.y + transform.ty);
	
	return result;
}

static KCGFloat KCGAffineTransformGetDeterminant(KCGAffineTransform transform) {
	return transform.a * transform.d - transform.b * transform.c;
}

static KCGAffineTransform KCGAffineTransformInvert(KCGAffineTransform transform) {
	KCGFloat determinant = KCGAffineTransformGetDeterminant(transform);
	
	if (determinant == 0.0) {
		return KCGAffineTransformMake(NAN, NAN, NAN, NAN, NAN, NAN);
	}
	
	return KCGAffineTransformMake(transform.d / determinant, -transform.b / determinant, -transform.c / determinant, transform.a / determinant, (transform.b * transform.ty - transform.tx * transform.d) / determinant, -(transform.a * transform.ty - transform.tx * transform.c) / determinant);
}

#pragma mark KCGLine

typedef struct {
	KCGPoint point;
	KCGPoint direction;
} KCGLine;

static KCGLine KCGLineMake(KCGPoint point, KCGPoint direction) {
	KCGLine line = {point, KCGPointNormalize(direction)};
	
	return line;
}

static KCGPoint KCGLineGetInterSection(KCGLine line1, KCGLine line2) {
	KCGFloat k = ((line2.point.x - line1.point.x) * line2.direction.y - (line2.point.y - line1.point.y) * line2.direction.x) / (line1.direction.x * line2.direction.y - line1.direction.y * line2.direction.x);
	if (!isfinite(k)) {
		return KCGPointMake(NAN, NAN);
	}
	
	return KCGPointAdd(line1.point, KCGPointMultiply(line1.direction, k));
}

#pragma mark KCGCircle

typedef struct {
	KCGPoint center;
	KCGFloat radius;
} KCGCircle;

static KCGCircle KCGCircleMake(KCGPoint center, KCGFloat radius) {
	KCGCircle circle = {center, radius};
	
	return circle;
}

static NSUInteger KCGCircleGetIntersections(KCGCircle circle1, KCGCircle circle2, KCGPoint *intersections) {
	KCGPoint center1ToCenter2 = KCGPointSubtract(circle2.center, circle1.center);
	KCGFloat distance = KCGPointGetLength(center1ToCenter2);
	KCGPoint direction = KCGPointNormalize(center1ToCenter2);
	
	KCGFloat radiusSum = circle1.radius + circle2.radius;
	KCGFloat radiusDifference = fabs(circle1.radius - circle2.radius);

	if (distance < radiusDifference || radiusSum < distance) {
		return 0;
	} else if (distance == radiusDifference || radiusSum == distance) {
		if (distance == 0.0) {
			return -1; // Infinity
		}
		
		*intersections = KCGPointAdd(circle1.center, KCGPointMultiply(direction, circle1.radius));
		
		return 1;
	} else {
		KCGFloat angleDifference = KCGAcos((distance * distance + circle1.radius * circle1.radius -circle2.radius * circle2.radius) / (2 * distance *circle1.radius));
		
		*intersections++ = KCGPointAdd(circle1.center, KCGPointMultiply(KCGPointApplyAffineTransform(direction, KCGAffineTransformMakeRotation(-angleDifference)), circle1.radius));
		*intersections++ = KCGPointAdd(circle1.center, KCGPointMultiply(KCGPointApplyAffineTransform(direction, KCGAffineTransformMakeRotation(angleDifference)), circle1.radius));
		
		return 2;
	}
}

static NSUInteger KCGCircleGetIntersectionWithLine(KCGCircle circle, KCGLine line, KCGPoint *intersections) {
	// Solves a * x^2 + b * x + c = 0
	KCGPoint centerToPoint = KCGPointSubtract(line.point, circle.center);
	
	KCGFloat a = KCGPointGetSquareLength(line.direction);
	KCGFloat b = 2 * KCGPointGetDotProduct(line.direction, centerToPoint);
	KCGFloat c = KCGPointGetSquareLength(centerToPoint) - circle.radius * circle.radius;
	
	KCGFloat inRoot = b * b - 4 * a * c;
	if (inRoot < 0.0) {
		return 0;
	} else if (inRoot == 0.0) {
		KCGFloat k = -b / (2 * a);
		*intersections = KCGPointAdd(line.point, KCGPointMultiply(line.direction, k));
		
		return 1;
	} else {
		KCGFloat k;

		k = (-b + sqrt(inRoot)) / (2 * a);
		*intersections++ = KCGPointAdd(line.point, KCGPointMultiply(line.direction, k));
		
		k = (-b - sqrt(inRoot)) / (2 * a);
		*intersections++ = KCGPointAdd(line.point, KCGPointMultiply(line.direction, k));
		
		return 2;
	}
}

#pragma mark -
#pragma mark KUIRingView

static const KCGFloat KUIRingViewInitialDiameterRate = 0.8;
static const KCGFloat KUIRingViewSelectionThreshold = 0.9;
static const CGFloat KUIRingViewItemDiameter = 40.0;
static const CGFloat KUIRingViewMinItemInterval = 50.0;
static const CGFloat KUIRingViewTitleXOffset = 15.0;

@interface KUIRingView () {
	KCGFloat _scale;
	KCGPoint _translation;
	
	KCGCircle _ring;
	
	NSUInteger _numberOfTouches;
	CGPoint _beginPoint;
	CGPoint _movePoint;
	BOOL _touchingUp;
	
	NSTimeInterval _previousTime;
	
	NSMutableDictionary *_stateToItemColor;
	NSMutableDictionary *_stateToTitleColor;
	
	NSMutableDictionary *_indexToItem;

	BOOL _osVersion7OrLater;
}

@property (nonatomic, readonly) KCGFloat initialDiameter;
@property (nonatomic, readonly) KCGAffineTransform viewCoordsToNormalizedCoords;

+ (UIColor *)defaultItemColor;
+ (UIColor *)defaultTitleColor;

- (void)setUp;

@end

@implementation KUIRingView

+ (UIColor *)defaultItemColor {
	return [[UIColor alloc] initWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
}

+ (UIColor *)defaultTitleColor {
	return [UIColor blackColor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setUp];
	}
	
	return self;
}

- (void)setUp {
	_osVersion7OrLater = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7;
	
	_font = [UIFont systemFontOfSize:12];

	_stateToItemColor = [[NSMutableDictionary alloc] initWithCapacity:5];
	_stateToItemColor[@(UIControlStateNormal)] = [KUIRingView defaultItemColor];
	
	_stateToTitleColor = [[NSMutableDictionary alloc] initWithCapacity:5];
	_stateToTitleColor[@(UIControlStateNormal)] = [KUIRingView defaultTitleColor];
	
	_indexToItem = [[NSMutableDictionary alloc] initWithCapacity:10];
	
	_numberOfTouches = 0;
	
	_scale = 1;
	_translation = KCGPointZero;
	
	_ring = KCGCircleMake(KCGPointZero, 0.5);
}

- (KCGFloat)initialDiameter {
	CGSize size = self.bounds.size;
	
	return fmin(size.width, size.height) * KUIRingViewInitialDiameterRate;
}

- (KCGAffineTransform)viewCoordsToNormalizedCoords {
	CGSize size = self.bounds.size;
	
	KCGAffineTransform transform = KCGAffineTransformIdentity;
	
	transform = KCGAffineTransformConcat(transform, KCGAffineTransformMakeTranslation(-size.width / 2, -size.height / 2));
	KCGFloat scaleFactor = 1.0 / (_scale * self.initialDiameter);
	transform = KCGAffineTransformConcat(transform, KCGAffineTransformMakeScale(scaleFactor, scaleFactor));
	transform = KCGAffineTransformConcat(transform, KCGAffineTransformMakeTranslation(_translation.x, _translation.y));
	
	return transform;
}

- (UIColor *)itemColorForState:(UIControlState)state {
	return _stateToItemColor[@(state)];
}

- (void)setItemColor:(UIColor *)color forState:(UIControlState)state {
	_stateToItemColor[@(state)] = color;
}

- (UIColor *)titleColorForState:(UIControlState)state {
	return _stateToTitleColor[@(state)];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
	_stateToTitleColor[@(state)] = color;
}

- (void)reloadData {
	[_indexToItem removeAllObjects];
	[self setNeedsDisplay];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGSize size = self.bounds.size;

	KCGCircle circumcircle = KCGCircleMake(_translation, (sqrt(size.width * size.width + size.height * size.height) / 2) / (_scale * self.initialDiameter));
	KCGPoint intersections[2];
	NSUInteger numberOfIntersections = KCGCircleGetIntersections(_ring, circumcircle, intersections);
	
	KCGAffineTransform normalizedCoordsToViewCoords = KCGAffineTransformInvert(self.viewCoordsToNormalizedCoords);

	NSUInteger numberOfItems = [self.dataSource ringViewNumberOfItems:self];
	NSUInteger maxNumberOfShownItems = self.initialDiameter * M_PI / KUIRingViewMinItemInterval;
	NSUInteger maxStep;
	for (maxStep = 1; (numberOfItems - 1) / maxStep + 1 > maxNumberOfShownItems; maxStep *= 2);
	NSUInteger virtualNumberOfItems = ((numberOfItems - 1) / maxStep + 1) * maxStep;
	NSUInteger beginIndex, endIndex;
	KCGFloat centralAngle;
	
	if (numberOfIntersections == 2 && (centralAngle = KCGPointGetAngleBetween(intersections[0], intersections[1])) < M_PI / 4) { // arc
		KCGFloat angles[2] = {atan2(intersections[0].x, -intersections[0].y), atan2(intersections[1].x, -intersections[1].y)};
		for (NSUInteger angleIndex = 0; angleIndex < 2; angleIndex++) {
			if (angles[angleIndex] < 0.0) {
				angles[angleIndex] += 2 * M_PI;
			}
		}
		beginIndex = (NSUInteger)(angles[0] / (2 * M_PI) * virtualNumberOfItems);
		endIndex = (NSUInteger)(angles[1] / (2 * M_PI) * virtualNumberOfItems);
	} else { // whole circle
		beginIndex = 0;
		endIndex = [self.dataSource ringViewNumberOfItems:self];
		centralAngle = 2 * M_PI;
	}
	
	// Draws items
	NSMutableSet *cachedIndices = [[NSMutableSet alloc] initWithArray:[_indexToItem allKeys]];
	
	NSUInteger step;
	for (step = 1; step < virtualNumberOfItems / (maxNumberOfShownItems * pow(2, (NSUInteger)(log(_scale) / log(2)))); step *= 2);
	
	void (^__weak __block drawItem)(NSUInteger, BOOL);
	void (^_drawItem)(NSUInteger, BOOL);
	drawItem = _drawItem = ^(NSUInteger index, BOOL appearing) {
		if (index >= numberOfItems) {
			return;
		}
		
		NSNumber *indexObject = @(index);
		KUIRingViewItem *item = _indexToItem[indexObject];
		if (!item) {
			item = [self.dataSource ringView:self itemAtIndex:index];
			_indexToItem[indexObject] = item;
		}
		[cachedIndices removeObject:indexObject];
		
		KCGFloat directionAngle = index / (KCGFloat)virtualNumberOfItems * (2 * M_PI) - M_PI / 2;
		KCGPoint centerOfItem = KCGPointMultiply(KCGPointMake(cos(directionAngle), sin(directionAngle)), 0.5);
		KCGPoint centerOfItemInViewCoords = KCGPointApplyAffineTransform(centerOfItem, normalizedCoordsToViewCoords);
		
		KCGFloat rate;
		if (appearing) {
			rate = log(_scale) / log(2) - (NSUInteger)(log(_scale) / log(2));
		} else {
			rate = 1.0;
		}

		// Draws the circle or the thumbnail
		UIColor *itemColor = nil;
		UIColor *titleColor;
		UIImage *image;
		KCGFloat radius = KUIRingViewItemDiameter * rate;
		CGRect itemRect = CGRectMake(centerOfItemInViewCoords.x - radius / 2, centerOfItemInViewCoords.y - radius / 2, radius, radius);
		if (_numberOfTouches == 1 && CGRectContainsPoint(itemRect, _beginPoint) && CGRectContainsPoint(itemRect, _movePoint) && rate >= KUIRingViewSelectionThreshold) { // Highlighted
			image = [item imageForState:UIControlStateHighlighted];
			if (!image) {
				image = [item imageForState:UIControlStateNormal];
				if (image) {
					UIGraphicsBeginImageContext(image.size);
					
					CGContextRef imageContext = UIGraphicsGetCurrentContext();
					CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
					
					CGContextScaleCTM(imageContext, 1.0, -1.0);
					CGContextTranslateCTM(imageContext, 0.0, -rect.size.height);
					
					CGContextDrawImage(imageContext, rect, image.CGImage);

					CGContextSetFillColorWithColor(imageContext, [[UIColor whiteColor] CGColor]);
					CGContextSetAlpha(imageContext, 0.5);
					CGContextFillRect(imageContext, rect);
					
					image = UIGraphicsGetImageFromCurrentImageContext();
					
					UIGraphicsEndImageContext();
				} else {
					itemColor = [item itemColorForState:UIControlStateHighlighted];
					if (!itemColor) {
						itemColor = [self itemColorForState:UIControlStateHighlighted];
						if (!itemColor) {
							itemColor = [item itemColorForState:UIControlStateNormal];
							if (!itemColor) {
								itemColor = [self itemColorForState:UIControlStateNormal];
								if (!itemColor) {
									itemColor = [KUIRingView defaultItemColor];
								}
							}
							CGFloat red, green, blue, alpha;
							[itemColor getRed:&red green:&green blue:&blue alpha:&alpha];
							itemColor = [[UIColor alloc] initWithRed:1.0 - (1.0 - red) / 2 green:1.0 - (1.0 - green) / 2 blue:1.0 - (1.0 - blue) / 2 alpha:alpha];
						}
					}
				}
			}
			
			titleColor = [item titleColorForState:UIControlStateHighlighted];
			if (!titleColor) {
				titleColor = [self titleColorForState:UIControlStateHighlighted];
				if (!titleColor) {
					titleColor = [item titleColorForState:UIControlStateNormal];
					if (!titleColor) {
						titleColor = [self titleColorForState:UIControlStateNormal];
						if (!titleColor) {
							titleColor = [KUIRingView defaultTitleColor];
						}
					}
					CGFloat red, green, blue, alpha;
					[titleColor getRed:&red green:&green blue:&blue alpha:&alpha];
					titleColor = [[UIColor alloc] initWithRed:1.0 - (1.0 - red) / 2 green:1.0 - (1.0 - green) / 2 blue:1.0 - (1.0 - blue) / 2 alpha:alpha];
				}
			}
		} else { // Normal (not highlighted)
			image = [item imageForState:UIControlStateNormal];
			if (!image) {
				itemColor = [item itemColorForState:UIControlStateNormal];
				if (!itemColor) {
					itemColor = [self itemColorForState:UIControlStateNormal];
					if (!itemColor) {
						itemColor = [KUIRingView defaultItemColor];
					}
				}
			}
			
			titleColor = [item titleColorForState:UIControlStateNormal];
			if (!titleColor) {
				titleColor = [self titleColorForState:UIControlStateNormal];
				if (!titleColor) {
					titleColor = [KUIRingView defaultTitleColor];
				}
			}
			
			if (_touchingUp && CGRectContainsPoint(itemRect, _beginPoint) && CGRectContainsPoint(itemRect, _movePoint) && rate > KUIRingViewSelectionThreshold) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.delegate ringView:self didSelectItemAtIndex:index];
				});
			}
		}
		titleColor = [titleColor colorWithAlphaComponent:rate * rate];

		if (image) { // Draws the thumbnal
			CGImageRef cgImage = image.CGImage;
			
			CGFloat x = itemRect.origin.x;
			CGFloat y = itemRect.origin.y;
			CGFloat width = CGImageGetWidth(cgImage);
			CGFloat height = CGImageGetHeight(cgImage);

			BOOL clipsImage = item.clipsImage;
			if (clipsImage ? width < height : height < width) {
				height = radius * height / width;
				width = radius;
				y += (width - height) / 2;
			} else {
				width = radius * width / height;
				height = radius;
				x += (height - width) / 2;
			}
			
			CGContextSaveGState(context);
			CGContextTranslateCTM(context, x, y + radius);
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextSetAlpha(context, rate * rate);
			if (clipsImage) {
				CGContextAddEllipseInRect(context, CGRectMake(0, 0, radius, radius));
				CGContextClip(context);
			}
			CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
			CGContextRestoreGState(context);
		} else { // Draws the circle
			CGFloat red, green, blue, alpha;
			[itemColor getRed:&red green:&green blue:&blue alpha:&alpha];
			
			CGContextSetFillColorWithColor(context, [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha * rate * rate].CGColor);
			CGContextFillEllipseInRect(context, itemRect);
		}
		
		// Draws the title
		CGContextSaveGState(context);
		CGRect textRect;
		CGContextTranslateCTM(context, centerOfItemInViewCoords.x, centerOfItemInViewCoords.y);
		CGFloat x = KUIRingViewItemDiameter / 2 + KUIRingViewTitleXOffset;
		CGFloat width = fmin(self.initialDiameter / 2 * _scale - x - 14.0, fmax(size.width, size.height));
		CGFloat height;
		if (_osVersion7OrLater) {
			height = [item.title sizeWithAttributes:@{NSFontAttributeName : _font}].height;
		} else {
			height = [item.title sizeWithFont:_font].height;
		}
		BOOL textUpsideDown = directionAngle < M_PI / 2;
		if (textUpsideDown) {
			// Rotates texts upside down
			CGContextRotateCTM(context, directionAngle);
			textRect = CGRectMake(-x - width, -_font.pointSize / 2, width, height);
		} else {
			CGContextRotateCTM(context, directionAngle + M_PI);
			textRect = CGRectMake(x, -_font.pointSize / 2, width, height);
		}
		if (_osVersion7OrLater) {
			// iOS 7.0 or later
			NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
			[style setLineBreakMode:NSLineBreakByTruncatingTail];
			[style setAlignment:textUpsideDown ? NSTextAlignmentRight : NSTextAlignmentLeft];
			[item.title drawInRect:textRect withAttributes:@{NSFontAttributeName : _font, NSForegroundColorAttributeName : titleColor, NSParagraphStyleAttributeName : style}];
		} else {
			// iOS 6.X or earlier
			CGContextSetFillColorWithColor(context, titleColor.CGColor);
			[item.title drawInRect:textRect withFont:_font lineBreakMode:NSLineBreakByTruncatingTail alignment:textUpsideDown ? NSTextAlignmentRight : NSTextAlignmentLeft];
		}
		CGContextRestoreGState(context);
		
		if (!appearing && step > 1) {
			drawItem(index + step / 2, YES);
		}
	};
	
	if (beginIndex <= endIndex) {
		for (NSUInteger itemIndex = (beginIndex / step) * step; itemIndex <= endIndex; itemIndex += step) {
			drawItem(itemIndex, NO);
		}
	} else {
		for (NSUInteger itemIndex = (beginIndex / step) * step; itemIndex < numberOfItems; itemIndex += step) {
			drawItem(itemIndex, NO);
		}
		for (NSUInteger itemIndex = 0; itemIndex <= endIndex; itemIndex += step) {
			drawItem(itemIndex, NO);
		}
	}
	
	[_indexToItem removeObjectsForKeys:[cachedIndices allObjects]];
	
	// Bounces
	KCGFloat maxScale = maxStep;
	if (_scale > maxScale && _numberOfTouches == 0) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_scale <= maxScale || _numberOfTouches > 0) {
				return;
			}
			
			NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
			{
				if (!isnan(_previousTime)) {
					KCGFloat previousScale = _scale;
					_scale = (_scale - maxScale) * pow(0.00005, currentTime - _previousTime) + maxScale;
					KCGPoint intersections[2];
					NSUInteger numberOfIntersections = KCGCircleGetIntersectionWithLine(_ring, KCGLineMake(KCGPointZero, KCGPointApplyAffineTransform(KCGPointFromCGPoint(_movePoint), self.viewCoordsToNormalizedCoords)), intersections);
					if (numberOfIntersections > 0) {
						_translation = KCGPointSubtract(*intersections, KCGPointMultiply(KCGPointSubtract(*intersections, _translation), previousScale / _scale));
					}
					_translation = KCGPointMultiply(_translation, log(_scale) / log(previousScale));
					KCGFloat translationLength = KCGPointGetLength(_translation);
					KCGFloat minTranslationLength = 0.5 - 0.5 / _scale;
					if (translationLength < minTranslationLength) {
						_translation = KCGPointMultiply(_translation, minTranslationLength / translationLength);
					}
				}
				
				[self setNeedsDisplay];
			}
			_previousTime = currentTime;
		});
	}
	
	_touchingUp = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	_numberOfTouches += touches.count;
	
	if (_numberOfTouches == 1) {
		UITouch *touch = [touches anyObject];
		_beginPoint = _movePoint = [touch locationInView:self];
	}
	
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	if (_numberOfTouches == 1) {
		UITouch *touch = [touches anyObject];
		_movePoint = [touch locationInView:self];
		
		KCGAffineTransform viewCoordsToNormalizedCoords = self.viewCoordsToNormalizedCoords;
		
		KCGPoint currentInViewCoords = KCGPointFromCGPoint(_movePoint);
		KCGPoint previousInViewCoords = KCGPointFromCGPoint([touch previousLocationInView:self]);
		KCGPoint velocityInViewCoords = KCGPointSubtract(currentInViewCoords, previousInViewCoords);
		KCGPoint previous = KCGPointApplyAffineTransform(previousInViewCoords, viewCoordsToNormalizedCoords);
		KCGFloat scaleExponent;
		if (KCGPointIsFinite(previous)) {
			scaleExponent = KCGPointGetDotProduct(velocityInViewCoords, KCGPointNormalize(previous));
		} else {
			scaleExponent = KCGPointGetLength(velocityInViewCoords);
		}
		KCGLine moveLine = KCGLineMake(previous, velocityInViewCoords);
		KCGPoint intersection;
		{
			KCGPoint intersections[2];
			NSUInteger numberOfIntersections = KCGCircleGetIntersectionWithLine(_ring, moveLine, intersections);
			if (numberOfIntersections > 0) {
				if (scaleExponent >= 0.0) {
					intersection = intersections[0];
				} else {
					intersection = intersections[1];
				}
			} else {
				intersection = KCGLineGetInterSection(moveLine, KCGLineMake(KCGPointZero, KCGPointApplyAffineTransform(velocityInViewCoords, KCGAffineTransformMakeRotation(M_PI / 2))));
			}
		}
		
		CGFloat previousScale = _scale;
		_scale *= powf(1.0115794542599, scaleExponent); // 1.0115794542599 == 10.0 ** (1.0 / 200.0)
		if (_scale < 1.0) {
			_scale = 1.0;
		}
		_translation = KCGPointSubtract(intersection, KCGPointMultiply(KCGPointSubtract(intersection, _translation), previousScale / _scale));
		if (scaleExponent < 0.0 && _scale > 1.0) {
			_translation = KCGPointMultiply(_translation, log(_scale) / log(previousScale));
		}
		KCGFloat translationLength = KCGPointGetLength(_translation);
		KCGFloat minTranslationLength = 0.5 - 0.5 / _scale;
		if (translationLength < minTranslationLength) {
			_translation = KCGPointMultiply(_translation, minTranslationLength / translationLength);
		}
	}
	
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	if (_numberOfTouches == 1) {
		UITouch *touch = [touches anyObject];
		_movePoint = [touch locationInView:self];
		_touchingUp = YES;
		_previousTime = NAN;
	}
	
	_numberOfTouches -= touches.count;
	
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	
	_numberOfTouches -= touches.count;
	
	[self setNeedsDisplay];
}

@end

#pragma mark -
#pragma mark KUIRingViewItem

@interface KUIRingViewItem () {
	NSMutableDictionary *_stateToItemColor;
	NSMutableDictionary *_stateToTitleColor;
	NSMutableDictionary *_stateToImage;
}

@end

@implementation KUIRingViewItem

- (id)initWithTitle:(NSString *)title {
	self = [super init];
	if (self) {
		_title = title;
		_clipsImage = YES;
		_stateToItemColor = [[NSMutableDictionary alloc] initWithCapacity:5];
		_stateToTitleColor = [[NSMutableDictionary alloc] initWithCapacity:5];
		_stateToImage = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	
	return self;
}

- (UIColor *)itemColorForState:(UIControlState)state {
	return _stateToItemColor[@(state)];
}

- (void)setItemColor:(UIColor *)color forState:(UIControlState)state {
	_stateToItemColor[@(state)] = color;
}

- (UIColor *)titleColorForState:(UIControlState)state {
	return _stateToTitleColor[@(state)];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
	_stateToTitleColor[@(state)] = color;
}

- (UIImage *)imageForState:(UIControlState)state {
	return _stateToImage[@(state)];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
	_stateToImage[@(state)] = image;
}

@end


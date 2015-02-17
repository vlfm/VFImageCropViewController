#import "VFPanTouchArea.h"

#import "VFAspectRatio.h"
#import "VFRectConstraint.h"

@interface VFPanTouchAreaTopLeft : VFPanTouchArea
@end



@interface VFPanTouchAreaTopRight : VFPanTouchArea
@end



@interface VFPanTouchAreaBottomLeft : VFPanTouchArea
@end



@interface VFPanTouchAreaBottomRight : VFPanTouchArea
@end



@implementation VFPanTouchArea

+ (instancetype)topLeft {
    return [[VFPanTouchAreaTopLeft alloc] initWithSize:[self standardSize]];
}

+ (instancetype)topRight {
    return [[VFPanTouchAreaTopRight alloc] initWithSize:[self standardSize]];
}

+ (instancetype)bottomLeft {
    return [[VFPanTouchAreaBottomLeft alloc] initWithSize:[self standardSize]];
}

+ (instancetype)bottomRight {
    return [[VFPanTouchAreaBottomRight alloc] initWithSize:[self standardSize]];
}

+ (CGSize)standardSize {
    return CGSizeMake(44, 44);
}

- (instancetype)initWithSize:(CGSize)size {
    self = [super init];
    _size = size;
    return self;
}

- (CGRect)translateParentFrame:(CGRect)frame
       withPanTranslationPoint:(CGPoint)point
                   aspectRatio:(VFAspectRatio *)aspectRatio
                rectConstraint:(VFRectConstraint *)rectConstraint {
    
    CGSize translatedSize = [self translateParentSize:frame.size withPanTranslationPoint:point];
    
    if (aspectRatio != nil) {
        translatedSize = [aspectRatio aspectSizeThatFits:translatedSize translationPoint:point];
    }
    
    CGPoint translationPointConsideringAspectSize = CGPointMake(translatedSize.width - frame.size.width,
                                                                translatedSize.height - frame.size.height);
    CGPoint translatedOrigin = [self translateParentOrigin:frame.origin
                                   withPanTranslationPoint:translationPointConsideringAspectSize];
    
    CGRect translatedFrame;
    translatedFrame.origin = translatedOrigin;
    translatedFrame.size = translatedSize;
    
    if ([rectConstraint acceptRect:translatedFrame]) {
        return translatedFrame;
    }
    
    return frame;
}

- (BOOL)containsPoint:(CGPoint)point inParentBounds:(CGRect)bounds {
    CGRect rect = [self areaRectInParentBounds:bounds];
    return CGRectContainsPoint(rect, point);
}

#pragma mark overridable

- (CGRect)areaRectInParentBounds:(CGRect)bounds {
    return bounds;
}

- (CGPoint)translateParentOrigin:(CGPoint)origin
        withPanTranslationPoint:(CGPoint)point {
    return origin;
}

- (CGSize)translateParentSize:(CGSize)size
      withPanTranslationPoint:(CGPoint)point {
    return size;
}

@end




@implementation VFPanTouchAreaTopLeft

#pragma mark overridable

- (CGRect)areaRectInParentBounds:(CGRect)bounds {
    return CGRectMake(-self.size.width / 2,
                      -self.size.height / 2,
                      self.size.width,
                      self.size.height);
}

- (CGPoint)translateParentOrigin:(CGPoint)origin
         withPanTranslationPoint:(CGPoint)point {
    
    CGPoint translatedOrigin = origin;
    translatedOrigin.x -= point.x;
    translatedOrigin.y -= point.y;
    return translatedOrigin;
}

- (CGSize)translateParentSize:(CGSize)size
      withPanTranslationPoint:(CGPoint)point {
    
    CGSize translatedSize = size;
    translatedSize.width -= point.x;
    translatedSize.height -= point.y;
    return translatedSize;
}

@end




@implementation VFPanTouchAreaTopRight

#pragma mark overridable

- (CGRect)areaRectInParentBounds:(CGRect)bounds {
    return CGRectMake(CGRectGetWidth(bounds) - self.size.width / 2,
                      -self.size.height / 2,
                      self.size.width,
                      self.size.height);
}

- (CGPoint)translateParentOrigin:(CGPoint)origin
         withPanTranslationPoint:(CGPoint)point {
    
    CGPoint translatedOrigin = origin;
    translatedOrigin.y -= point.y;
    return translatedOrigin;
}

- (CGSize)translateParentSize:(CGSize)size
      withPanTranslationPoint:(CGPoint)point {
    
    CGSize translatedSize = size;
    translatedSize.width += point.x;
    translatedSize.height -= point.y;
    return translatedSize;
}

@end




@implementation VFPanTouchAreaBottomLeft

#pragma mark overridable

- (CGRect)areaRectInParentBounds:(CGRect)bounds {
    return CGRectMake(-self.size.width / 2,
                      CGRectGetHeight(bounds) - self.size.height / 2,
                      self.size.width,
                      self.size.height);
}

- (CGPoint)translateParentOrigin:(CGPoint)origin
         withPanTranslationPoint:(CGPoint)point {
    
    CGPoint translatedOrigin = origin;
    translatedOrigin.x -= point.x;
    return translatedOrigin;
}

- (CGSize)translateParentSize:(CGSize)size
      withPanTranslationPoint:(CGPoint)point {
    
    CGSize translatedSize = size;
    translatedSize.width -= point.x;
    translatedSize.height += point.y;
    return translatedSize;
}

@end




@implementation VFPanTouchAreaBottomRight

#pragma mark overridable

- (CGRect)areaRectInParentBounds:(CGRect)bounds {
    return CGRectMake(CGRectGetWidth(bounds) - self.size.width / 2,
                      CGRectGetHeight(bounds) - self.size.height / 2,
                      self.size.width,
                      self.size.height);
}

- (CGSize)translateParentSize:(CGSize)size
      withPanTranslationPoint:(CGPoint)point {
    
    CGSize translatedSize = size;
    translatedSize.width += point.x;
    translatedSize.height += point.y;
    return translatedSize;
}

@end
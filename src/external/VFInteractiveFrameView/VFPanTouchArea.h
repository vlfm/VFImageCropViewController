#import <UIKit/UIKit.h>

@class VFAspectRatio;
@class VFRectConstraint;

@interface VFPanTouchArea : NSObject

@property (nonatomic, readonly) CGSize size;

+ (instancetype)top;
+ (instancetype)left;
+ (instancetype)bottom;
+ (instancetype)right;

+ (instancetype)topLeft;
+ (instancetype)topRight;
+ (instancetype)bottomLeft;
+ (instancetype)bottomRight;

+ (CGSize)standardSize;

- (instancetype)initWithSize:(CGSize)size;

- (CGRect)translateParentFrame:(CGRect)frame
       withPanTranslationPoint:(CGPoint)point
                   aspectRatio:(VFAspectRatio *)aspectRatio
                rectConstraint:(VFRectConstraint *)rectConstraint;

- (BOOL)containsPoint:(CGPoint)point inParentBounds:(CGRect)bounds;

#pragma mark overridable

- (CGRect)areaRectInParentBounds:(CGRect)bounds;

- (CGPoint)translateParentOrigin:(CGPoint)origin
      withPanTranslationPoint:(CGPoint)point;

- (CGSize)translateParentSize:(CGSize)size
       withPanTranslationPoint:(CGPoint)point;

@end

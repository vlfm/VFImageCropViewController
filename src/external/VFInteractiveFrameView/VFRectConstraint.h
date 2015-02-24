#import <UIKit/UIKit.h>

@interface VFRectConstraint : NSObject

- (BOOL)acceptRect:(CGRect)rect;

@end



@interface VFBlockRectContraint : VFRectConstraint

- (instancetype)initWithBlock:(BOOL(^)(CGRect))block;

@end



@interface VFRectConstraintGroup : VFRectConstraint

@property (nonatomic, readonly) NSArray *rectConstraints;

- (void)addRectConstraint:(VFRectConstraint *)rectConstraint;

@end

VFRectConstraint * VFRectConstraintMinimumSize(CGSize size);
VFRectConstraint * VFRectConstraintMaximumRect(CGRect rect);
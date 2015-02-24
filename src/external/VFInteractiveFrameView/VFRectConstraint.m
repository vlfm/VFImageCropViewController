#import "VFRectConstraint.h"

@implementation VFRectConstraint

+ (instancetype)constraintWithMaximumSize:(CGSize)size {
    return [[VFBlockRectContraint alloc] initWithBlock:^BOOL(CGRect rect) {
        return rect.size.width <= size.width && rect.size.height <= size.height;
    }];
}

- (BOOL)acceptRect:(CGRect)rect {
    return YES;
}

@end



@implementation VFBlockRectContraint {
    BOOL(^_block)(CGRect);
}

- (instancetype)initWithBlock:(BOOL(^)(CGRect))block {
    self = [super init];
    _block = [block copy];
    return self;
}

- (BOOL)acceptRect:(CGRect)rect {
    return _block(rect);
}

@end



@implementation VFRectConstraintGroup

- (instancetype)init {
    self = [super init];
    _rectConstraints = @[];
    return self;
}

- (void)addRectConstraint:(VFRectConstraint *)rectConstraint {
    _rectConstraints = [_rectConstraints arrayByAddingObject:rectConstraint];
}

- (BOOL)acceptRect:(CGRect)rect {
    for (VFRectConstraint *rectConstraint in _rectConstraints) {
        if (![rectConstraint acceptRect:rect]) {
            return NO;
        }
    }
    return YES;
}

@end



VFRectConstraint * VFRectConstraintMinimumSize(CGSize size) {
    return [[VFBlockRectContraint alloc] initWithBlock:^BOOL(CGRect rect) {
        return rect.size.width >= size.width && rect.size.height >= size.height;
    }];
}

VFRectConstraint * VFRectConstraintMaximumRect(CGRect constraintRect) {
    return [[VFBlockRectContraint alloc] initWithBlock:^BOOL(CGRect rect) {
        return CGRectContainsRect(constraintRect, rect);
    }];
}
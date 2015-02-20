#import "VFImageCropOverlayController.h"

@implementation VFImageCropOverlayController {
    UIView *_topView;
    UIView *_leftView;
    UIView *_bottomView;
    UIView *_rightView;
}

- (instancetype)initWithTargetView:(UIView *)targetView {
    self = [super init];
    _targetView = targetView;
    
    _topView = [UIView new];
    _leftView = [UIView new];
    _bottomView = [UIView new];
    _rightView = [UIView new];
    
    [_targetView addSubview:_topView];
    [_targetView addSubview:_leftView];
    [_targetView addSubview:_bottomView];
    [_targetView addSubview:_rightView];
    
    UIColor *backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    _topView.backgroundColor = backgroundColor;
    _leftView.backgroundColor = backgroundColor;
    _bottomView.backgroundColor = backgroundColor;
    _rightView.backgroundColor = backgroundColor;
    
    return self;
}

- (void)setCropAreaRect:(CGRect)cropAreaRect {
    _cropAreaRect = cropAreaRect;
    [self layout];
}

- (void)layout {
    CGRect bounds = _targetView.bounds;
    CGRect cropAreaFrame = self.cropAreaRect;
    
    _topView.frame = CGRectMake(0, 0,
                                CGRectGetWidth(bounds),
                                CGRectGetMinY(cropAreaFrame));
    
    _leftView.frame = CGRectMake(0,
                                 CGRectGetMinY(cropAreaFrame),
                                 CGRectGetMinX(cropAreaFrame),
                                 CGRectGetHeight(cropAreaFrame));
    
    _bottomView.frame = CGRectMake(0, CGRectGetMaxY(cropAreaFrame),
                                   CGRectGetWidth(bounds),
                                   CGRectGetHeight(bounds) - CGRectGetMaxY(cropAreaFrame));
    
    _rightView.frame = CGRectMake(CGRectGetMaxX(cropAreaFrame),
                                  CGRectGetMinY(cropAreaFrame),
                                  CGRectGetWidth(bounds) - CGRectGetMaxX(cropAreaFrame),
                                  CGRectGetHeight(cropAreaFrame));
}

@end

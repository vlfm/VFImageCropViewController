/*
 
 Copyright 2015 Valery Fomenko
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "VFImageCropOverlayController.h"

@implementation VFImageCropOverlayController {
    UIView *_topColorOverlayView;
    UIView *_leftColorOverlayView;
    UIView *_bottomColorOverlayView;
    UIView *_rightColorOverlayView;
    
    UIView *_topBlurOverlayView;
    UIView *_leftBlurOverlayView;
    UIView *_bottomBlurOverlayView;
    UIView *_rightBlurOverlayView;
}

- (instancetype)initWithTargetView:(UIView *)targetView {
    self = [super init];
    _targetView = targetView;
    
    _topColorOverlayView = [UIView new];
    _leftColorOverlayView = [UIView new];
    _bottomColorOverlayView = [UIView new];
    _rightColorOverlayView = [UIView new];
    
    [_targetView addSubview:_topColorOverlayView];
    [_targetView addSubview:_leftColorOverlayView];
    [_targetView addSubview:_bottomColorOverlayView];
    [_targetView addSubview:_rightColorOverlayView];
    
    UIColor *backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    _topColorOverlayView.backgroundColor = backgroundColor;
    _leftColorOverlayView.backgroundColor = backgroundColor;
    _bottomColorOverlayView.backgroundColor = backgroundColor;
    _rightColorOverlayView.backgroundColor = backgroundColor;
    
    if ([self blurEffectAvailable]) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _topBlurOverlayView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _leftBlurOverlayView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _bottomBlurOverlayView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _rightBlurOverlayView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        [_targetView addSubview:_topBlurOverlayView];
        [_targetView addSubview:_leftBlurOverlayView];
        [_targetView addSubview:_bottomBlurOverlayView];
        [_targetView addSubview:_rightBlurOverlayView];
        
        self.blurEnabled = NO;
    }
    
    return self;
}

- (void)setCropAreaRect:(CGRect)cropAreaRect {
    _cropAreaRect = cropAreaRect;
    [self layout];
}

- (void)setBlurEnabled:(BOOL)blurEnabled {
    _blurEnabled = blurEnabled;
    
    if ([self blurEffectAvailable] == NO) {
        return;
    }
    
    _topColorOverlayView.hidden = _blurEnabled;
    _leftColorOverlayView.hidden = _blurEnabled;
    _bottomColorOverlayView.hidden = _blurEnabled;
    _rightColorOverlayView.hidden = _blurEnabled;
    
    _topBlurOverlayView.hidden = !_blurEnabled;
    _leftBlurOverlayView.hidden = !_blurEnabled;
    _bottomBlurOverlayView.hidden = !_blurEnabled;
    _rightBlurOverlayView.hidden = !_blurEnabled;
}

- (void)layout {
    CGRect bounds = _targetView.bounds;
    CGRect cropAreaFrame = self.cropAreaRect;
    
    [self layoutTopOverlayWithBounds:bounds cropAreaFrame:cropAreaFrame];
    [self layoutLeftOverlayWithBounds:bounds cropAreaFrame:cropAreaFrame];
    [self layoutBottomOverlayWithBounds:bounds cropAreaFrame:cropAreaFrame];
    [self layoutRightOverlayWithBounds:bounds cropAreaFrame:cropAreaFrame];
}

- (void)layoutTopOverlayWithBounds:(CGRect)bounds cropAreaFrame:(CGRect)cropAreaFrame {
    CGRect frame = CGRectMake(0, 0,
                              CGRectGetWidth(bounds),
                              CGRectGetMinY(cropAreaFrame));
    _topColorOverlayView.frame = frame;
    _topBlurOverlayView.frame = frame;
}

- (void)layoutLeftOverlayWithBounds:(CGRect)bounds cropAreaFrame:(CGRect)cropAreaFrame {
    CGRect frame = CGRectMake(0,
                              CGRectGetMinY(cropAreaFrame),
                              CGRectGetMinX(cropAreaFrame),
                              CGRectGetHeight(cropAreaFrame));
    _leftColorOverlayView.frame = frame;
    _leftBlurOverlayView.frame = frame;
}

- (void)layoutBottomOverlayWithBounds:(CGRect)bounds cropAreaFrame:(CGRect)cropAreaFrame {
    CGRect frame = CGRectMake(0, CGRectGetMaxY(cropAreaFrame),
                              CGRectGetWidth(bounds),
                              CGRectGetHeight(bounds) - CGRectGetMaxY(cropAreaFrame));
    _bottomColorOverlayView.frame = frame;
    _bottomBlurOverlayView.frame = frame;
}

- (void)layoutRightOverlayWithBounds:(CGRect)bounds cropAreaFrame:(CGRect)cropAreaFrame {
    CGRect frame = CGRectMake(CGRectGetMaxX(cropAreaFrame),
                              CGRectGetMinY(cropAreaFrame),
                              CGRectGetWidth(bounds) - CGRectGetMaxX(cropAreaFrame),
                              CGRectGetHeight(cropAreaFrame));
    _rightColorOverlayView.frame = frame;
    _rightBlurOverlayView.frame = frame;
}

- (BOOL)blurEffectAvailable {
    return [UIVisualEffect class] != nil;
}

@end

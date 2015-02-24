#import "VFInteractiveFrameView.h"

#import "VFAspectRatio.h"
#import "VFPanTouchArea.h"
#import "VFRectConstraint.h"

@interface VFInteractiveFrameView() <UIGestureRecognizerDelegate>
@end

@implementation VFInteractiveFrameView {
    NSArray *_panTouchAreas;
    
    VFPanTouchArea *_currentPanTouchArea;
    CGPoint _lastTranslationPoint;
}

- (CGRect)maximumAvailableFrame {
    CGFloat dx = self.insetsInSuperView.left;
    CGFloat dy = self.insetsInSuperView.top;
    CGFloat dw = -dx - self.insetsInSuperView.right;
    CGFloat dh = -dy - self.insetsInSuperView.bottom;
    
    return CGRectMake(dx, dy, CGRectGetWidth(self.superview.bounds) + dw, CGRectGetHeight(self.superview.bounds) + dh);
}

- (CGRect)maximumAllowedFrame {
    CGRect rect = self.maximumAvailableFrame;
    
    CGPoint origin = rect.origin;
    CGSize size = rect.size;
    
    if (self.aspectRatio) {
        size = [self.aspectRatio aspectSizeThatFitsInside:size];
    }
    
    return CGRectMake(CGRectGetMinX(self.superview.bounds) + origin.x,
                      CGRectGetMinY(self.superview.bounds) + origin.y,
                      size.width,
                      size.height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInitSetup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInitSetup];
    return self;
}

- (void)commonInitSetup {
    self.exclusiveTouch = YES;
    self.userInteractionEnabled = YES;
    
    UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanEvent:)];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
    
    _panTouchAreas = @[
                       [VFPanTouchArea top],
                       [VFPanTouchArea left],
                       [VFPanTouchArea bottom],
                       [VFPanTouchArea right],
                       [VFPanTouchArea topLeft],
                       [VFPanTouchArea topRight],
                       [VFPanTouchArea bottomLeft],
                       [VFPanTouchArea bottomRight]
                       ];
}

- (void)handlePanEvent:(UIPanGestureRecognizer *)recognizer {
    CGPoint translationPoint = [recognizer translationInView:recognizer.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self notifyDidBeginInteraction];
        
        CGPoint locationPoint = [recognizer locationInView:recognizer.view];
        
        for (VFPanTouchArea *panTouchArea in _panTouchAreas) {
            if ([panTouchArea containsPoint:locationPoint inParentBounds:self.bounds]) {
                _currentPanTouchArea = panTouchArea;
                break;
            }
        }
        
        _lastTranslationPoint = translationPoint;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat dx = translationPoint.x - _lastTranslationPoint.x;
        CGFloat dy = translationPoint.y - _lastTranslationPoint.y;
        
        CGRect frame = self.frame;
        
        VFAspectRatio *translationAspectRatio = self.aspectRatioFixed ? self.aspectRatio : nil;
        
        if (_currentPanTouchArea) {
            frame = [_currentPanTouchArea translateParentFrame:frame
                                       withPanTranslationPoint:CGPointMake(dx, dy)
                                                   aspectRatio:translationAspectRatio
                                                rectConstraint:[self frameConstraint]];
        }
        
        self.frame = frame;
        
        _lastTranslationPoint = translationPoint;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _currentPanTouchArea = nil;
        _lastTranslationPoint = CGPointZero;
        
        if (self.aspectRatioFixed == NO) {
            NSInteger w = round(CGRectGetWidth(self.frame));
            NSInteger h = round(CGRectGetHeight(self.frame));
            self.aspectRatio = VFAspectRatioMake(w, h);
            
            CGRect frame = self.frame;
            CGSize size = [self.aspectRatio aspectSizeThatFitsInside:frame.size];
            frame.size = size;
            self.frame = frame;
        }
        
        [self notifyDidEndInteraction];
    }
}

- (VFRectConstraint *)frameConstraint {
    VFRectConstraintGroup *group = [VFRectConstraintGroup new];
    [group addRectConstraint:VFRectConstraintMinimumSize(self.minimumSize)];
    [group addRectConstraint:VFRectConstraintMaximumRect(self.maximumAvailableFrame)];
    return group;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self isPointHitPanTouchAreas:point]) {
        return self;
    }
    return nil;
}

- (BOOL)isPointHitPanTouchAreas:(CGPoint)point {
    for (VFPanTouchArea *panTouchArea in _panTouchAreas) {
        if ([panTouchArea containsPoint:point inParentBounds:self.bounds]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark set frame

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    [self notifyDidChangeFrame];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    return [self isPointHitPanTouchAreas:point];
}

#pragma mark subclass notification methods

- (void)didBeginInteraction {
}

- (void)frameDidChange:(CGRect)frame {
}

- (void)didEndInteraction {
}

#pragma mark delegate

- (void)notifyDidBeginInteraction {
    if ([self.delegate respondsToSelector:@selector(interactiveFrameViewDidBeginInteraction:)]) {
        [self.delegate interactiveFrameViewDidBeginInteraction:self];
    }
}

- (void)notifyDidChangeFrame {
    [self frameDidChange:self.frame];
    
    if ([self.delegate respondsToSelector:@selector(interactiveFrameView:didChangeFrame:)]) {
        [self.delegate interactiveFrameView:self didChangeFrame:self.frame];
    }
}

- (void)notifyDidEndInteraction {
    if ([self.delegate respondsToSelector:@selector(interactiveFrameView:didEndInteractionWithFrame:aspectRatio:)]) {
        [self.delegate interactiveFrameView:self didEndInteractionWithFrame:self.frame aspectRatio:self.aspectRatio];
    }
}

@end

#import <UIKit/UIKit.h>

@class VFAspectRatio;
@protocol VFInteractiveFrameViewDelegate;

@interface VFInteractiveFrameView : UIView

@property (nonatomic, strong) VFAspectRatio *aspectRatio;

@property (nonatomic) UIEdgeInsets insetsInSuperView;
@property (nonatomic) CGSize minimumSize;

@property (nonatomic, readonly) BOOL interactionHappensNow;
@property (nonatomic, readonly) CGRect maximumAvailableFrame;
@property (nonatomic, readonly) CGRect maximumAllowedFrame;

@property (nonatomic, weak) id<VFInteractiveFrameViewDelegate> delegate;

#pragma mark subclass notification methods

- (void)interactionHappensNowDidChange:(BOOL)value;
- (void)frameDidChange:(CGRect)frame;

@end



@protocol VFInteractiveFrameViewDelegate <NSObject>

@optional

- (void)interactiveFrameView:(VFInteractiveFrameView *)interactiveFrameView interactionHappensNowDidChange:(BOOL)value;
- (void)interactiveFrameView:(VFInteractiveFrameView *)interactiveFrameView didChangeFrame:(CGRect)frame;

@end
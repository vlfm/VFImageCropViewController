#import <UIKit/UIKit.h>

@class VFAspectRatio;
@protocol VFInteractiveFrameViewDelegate;

@interface VFInteractiveFrameView : UIView

@property (nonatomic, strong) VFAspectRatio *aspectRatio;
@property (nonatomic) BOOL aspectRatioFixed;

@property (nonatomic) UIEdgeInsets insetsInSuperView;
@property (nonatomic) CGSize minimumSize;

@property (nonatomic, readonly) BOOL interactionHappensNow;
@property (nonatomic, readonly) CGRect maximumAvailableFrame;
@property (nonatomic, readonly) CGRect maximumAllowedFrame;

@property (nonatomic, weak) id<VFInteractiveFrameViewDelegate> delegate;

#pragma mark subclass notification methods

- (void)didBeginInteraction;
- (void)frameDidChange:(CGRect)frame;
- (void)didEndInteraction;

@end



@protocol VFInteractiveFrameViewDelegate <NSObject>

@optional

- (void)interactiveFrameViewDidBeginInteraction:(VFInteractiveFrameView *)interactiveFrameView;

- (void)interactiveFrameView:(VFInteractiveFrameView *)interactiveFrameView didChangeFrame:(CGRect)frame;

- (void)interactiveFrameView:(VFInteractiveFrameView *)interactiveFrameView
  didEndInteractionWithFrame:(CGRect)frame
                 aspectRatio:(VFAspectRatio *)aspectRatio;

@end
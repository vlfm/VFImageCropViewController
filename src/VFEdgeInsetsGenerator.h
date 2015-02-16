#import <UIKit/UIKit.h>

@protocol VFEdgeInsetsGenerator <NSObject>

- (UIEdgeInsets)edgeInsetsWithBounds:(CGSize)bounds;

@end
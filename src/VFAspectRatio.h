#import <Foundation/Foundation.h>

@interface VFAspectRatio : NSObject

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height;

/* internal */
- (CGSize)aspectSizeThatFits:(CGSize)size padding:(CGFloat)padding;

@end

VFAspectRatio * VFAspectRatioMake(NSInteger width, NSInteger height);
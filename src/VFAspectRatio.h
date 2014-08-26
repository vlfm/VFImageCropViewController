#import <Foundation/Foundation.h>

@interface VFAspectRatio : NSObject

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height;

@end

#import "VFAspectRatio.h"

@implementation VFAspectRatio

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height {
    self = [super init];
    _width = width;
    _height = height;
    return self;
}

@end

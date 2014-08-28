#import "VFAspectRatio.h"

@implementation VFAspectRatio

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height {
    self = [super init];
    _width = width;
    _height = height;
    return self;
}

- (CGSize)aspectSizeThatFits:(CGSize)size padding:(CGFloat)padding {
    CGFloat w = 0;
    CGFloat h = 0;
    
    if (_width >= _height) {
        w = size.width - padding;
        h = (w / _width) * _height;
    } else {
        h = size.height - padding;
        w = (h / _height) * _width;
    }
    
    return CGSizeMake(w, h);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d:%d", _width, _height];
}

@end

#import "VFCropAreaView.h"

@implementation VFCropAreaView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.userInteractionEnabled = NO;
    
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
    
    return  self;
}

- (CGRect)cropAreaRect {
    return self.frame;
}

@end
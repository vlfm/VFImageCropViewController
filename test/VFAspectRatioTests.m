#import "VFAspectRatioTests.h"

@implementation VFAspectRatioTests

- (instancetype)initWithInvocation:(NSInvocation *)invocation
                       aspectRatio:(VFAspectRatio *)aspectRatio
                         inputSize:(CGSize)inputSize
                      expectedSize:(CGSize)expectedSize {
    
    self = [super initWithInvocation:invocation];
    _aspectRatio = aspectRatio;
    _inputSize = inputSize;
    _expectedSize = expectedSize;
    return self;
}

+ (void)addTestWithAspectRatio:(VFAspectRatio *)aspectRatio
                     inputSize:(CGSize)inputSize
                  expectedSize:(CGSize)expectedSize
                     testSuite:(XCTestSuite *)testSuite {
    
    for (NSInvocation *invocation in [self testInvocations]) {
        
        XCTestCase *test = [[self alloc] initWithInvocation:invocation
                                                aspectRatio:aspectRatio
                                                  inputSize:inputSize
                                               expectedSize:expectedSize];
        [testSuite addTest:test];
        
    }
}

- (void)assertActualSize:(CGSize)actualSize {
    XCTAssertTrue(CGSizeEqualToSize(actualSize, self.expectedSize), @"%@ x %@ = %@, v %@",
                  self.aspectRatio, NSStringFromCGSize(self.inputSize), NSStringFromCGSize(actualSize), NSStringFromCGSize(self.expectedSize));
}

@end

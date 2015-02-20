#import "VFAspectRatioTests.h"

@interface VFAspectRatioTests_aspectSizeWithFixedWidthThatFits : VFAspectRatioTests

@end

@implementation VFAspectRatioTests_aspectSizeWithFixedWidthThatFits

+ (XCTestSuite *)defaultTestSuite {
    XCTestSuite *testSuite = [[XCTestSuite alloc] initWithName:NSStringFromClass(self)];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 1) inputSize:CGSizeMake(100, 200) expectedSize:CGSizeMake(100, 100) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 1) inputSize:CGSizeMake(200, 200) expectedSize:CGSizeMake(200, 200) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 1) inputSize:CGSizeMake(200, 100) expectedSize:CGSizeMake(200, 200) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(100, 200) expectedSize:CGSizeMake(100, 200) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(200, 200) expectedSize:CGSizeMake(200, 400) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(200, 100) expectedSize:CGSizeMake(200, 400) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(100, 200) expectedSize:CGSizeMake(100, 50) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(200, 200) expectedSize:CGSizeMake(200, 100) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(200, 100) expectedSize:CGSizeMake(200, 100) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(50, 200) expectedSize:CGSizeMake(50, 100) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(200, 50) expectedSize:CGSizeMake(200, 100) testSuite:testSuite];
    
    return testSuite;
}

- (void)testAspectSizeThatFitsInside {
    CGSize actualSize = [self.aspectRatio aspectSizeWithFixedWidthThatFits:self.inputSize];
    [self assertActualSize:actualSize];
}

@end

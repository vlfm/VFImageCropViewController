#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VFAspectRatio.h"

@interface VFAspectRatioTests : XCTestCase

@property (nonatomic, readonly) VFAspectRatio *aspectRatio;
@property (nonatomic, readonly) CGSize inputSize;
@property (nonatomic, readonly) CGSize expectedSize;

@end

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

+ (XCTestSuite *)defaultTestSuite {
    XCTestSuite *testSuite = [[XCTestSuite alloc] initWithName:NSStringFromClass(self)];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 1) inputSize:CGSizeMake(100, 200) expectedSize:CGSizeMake(100, 100) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 1) inputSize:CGSizeMake(200, 200) expectedSize:CGSizeMake(200, 200) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 1) inputSize:CGSizeMake(200, 100) expectedSize:CGSizeMake(100, 100) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(100, 200) expectedSize:CGSizeMake(100, 200) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(200, 200) expectedSize:CGSizeMake(100, 200) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(200, 100) expectedSize:CGSizeMake(50, 100) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(100, 200) expectedSize:CGSizeMake(100, 50) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(200, 200) expectedSize:CGSizeMake(200, 100) testSuite:testSuite];
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(200, 100) expectedSize:CGSizeMake(200, 100) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(1, 2) inputSize:CGSizeMake(50, 200) expectedSize:CGSizeMake(50, 100) testSuite:testSuite];
    
    [self addTestWithAspectRatio:VFAspectRatioMake(2, 1) inputSize:CGSizeMake(200, 50) expectedSize:CGSizeMake(100, 50) testSuite:testSuite];
    
    return testSuite;
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

- (void)testAspectSizeThatFits {
    CGSize actualSize = [_aspectRatio aspectSizeThatFits:_inputSize padding:0];
    XCTAssertTrue(CGSizeEqualToSize(actualSize, _expectedSize), @"%@ x %@ = %@, v %@",
                  _aspectRatio, NSStringFromCGSize(_inputSize), NSStringFromCGSize(actualSize), NSStringFromCGSize(_expectedSize));
}

@end

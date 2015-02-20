#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VFAspectRatio.h"

@interface VFAspectRatioTests : XCTestCase

@property (nonatomic, readonly) VFAspectRatio *aspectRatio;
@property (nonatomic, readonly) CGSize inputSize;
@property (nonatomic, readonly) CGSize expectedSize;

- (instancetype)initWithInvocation:(NSInvocation *)invocation
                       aspectRatio:(VFAspectRatio *)aspectRatio
                         inputSize:(CGSize)inputSize
                      expectedSize:(CGSize)expectedSize;

+ (void)addTestWithAspectRatio:(VFAspectRatio *)aspectRatio
                     inputSize:(CGSize)inputSize
                  expectedSize:(CGSize)expectedSize
                     testSuite:(XCTestSuite *)testSuite;

- (void)assertActualSize:(CGSize)actualSize;

@end
//
//  ViewControllerTests.m
//  MalltipProfile
//
//  Created by DJ Mitchell on 4/7/15.
//  Copyright (c) 2015 Killectro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface ViewControllerTests : XCTestCase

@property (strong, nonatomic) ViewController *controller;

@end

@implementation ViewControllerTests

- (void)setUp {
    [super setUp];
    self.controller = [ViewController new];
}

- (void)tearDown {

    [super tearDown];
}

- (void)test99PointsGetsCorrectLevelAndProgress {
    self.controller.totalScore = 99;
    
    XCTAssertTrue(self.controller.level == 1);
    XCTAssertTrue(self.controller.currentProgress == 99);
}

- (void)test100PointsGetsCorrectLevelAndProgress {
    self.controller.totalScore = 100;
    
    XCTAssertTrue(self.controller.level == 2);
    XCTAssertTrue(self.controller.currentProgress == 0);
}

- (void)test101PointsGetsCorrectLevelAndProgress {
    self.controller.totalScore = 101;
    
    XCTAssertTrue(self.controller.level == 2);
    XCTAssertTrue(self.controller.currentProgress == 1);
}

- (void)test9999PointsGetsCorrectLevelAndProgress {
    self.controller.totalScore = 9999;
    
    XCTAssertTrue(self.controller.level == 100);
    XCTAssertTrue(self.controller.currentProgress == 99);
}

- (void)test10000PointsGetsCorrectLevelAndProgress {
    self.controller.totalScore = 10000;
    
    XCTAssertTrue(self.controller.level == 101);
    XCTAssertTrue(self.controller.currentProgress == 0);
}

- (void)testVeryLargeTotalScore {
    self.controller.totalScore = 600000010;
    
    XCTAssertTrue(self.controller.level == 6000001);
    XCTAssertTrue(self.controller.currentProgress == 10);
}
@end

//
//  ImagesLocalCacheTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 25.07.2024.
//

import XCTest
@testable import NetworkAPI

final class ImagesLocalCacheTest: XCTestCase {
    private let placeholder = UIImage(systemName: "photo")!

    func test_count_initiallyShouldBeEqualToZero() {
        let sut = sut()
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_count_shouldBeEqualToOne() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut.set(placeholder, forURL: url)
        
        XCTAssertEqual(sut.count, 1, "count should be one")
    }
    func test_count_shouldBeEqualToOneAfterLoopFive() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        for _ in 0..<5 {
            sut.set(placeholder, forURL: url)
        }
        
        XCTAssertEqual(sut.count, 1, "count should be one")
    }
    func test_count_shouldBeEqualToFiveAfterLoopFive() {
        let sut = sut()
        
        for i in 0..<5 {
            let url = URL(string: "http://test\(i)")!
            sut.set(placeholder, forURL: url)
        }
        
        XCTAssertEqual(sut.count, 5, "count should be one")
    }
    func test_count_shouldBeEqualToZero() {
        let sut = sut()
        
        for i in 0..<5 {
            let url = URL(string: "http://test\(i)")!
            sut.set(placeholder, forURL: url)
        }
        for i in 0..<5 {
            let url = URL(string: "http://test\(i)")!
            sut.set(nil, forURL: url)
        }
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_count_shouldBeEqualToZeroAfterDeletingFiveTimes() {
        let sut = sut()
        let url = URL(string: "http://test")!
        
        sut.set(placeholder, forURL: url)
        for _ in 0..<5 {
            sut.set(nil, forURL: url)
        }
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_count_shouldBeEqualToZeroAfterClean() {
        let sut = sut()
        
        for i in 0..<5 {
            let url = URL(string: "http://test\(i)")!
            sut.set(placeholder, forURL: url)
        }
        sut.clean()
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_image_shouldNotBeNil() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut.set(placeholder, forURL: url)
        
        let image = sut.image(forURL: url)
        XCTAssertNotNil(image, "image should not be nil")
    }
    func test_image_shouldBeNil() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut.set(placeholder, forURL: url)
        sut.set(nil, forURL: url)
        
        let image = sut.image(forURL: url)
        XCTAssertNil(image, "image should be nil")
    }
    func test_count_shouldBeEqualToOneHundred() {
        let sut = sut()
        
        for i in 1...101 {
            let url = URL(string: "http://test\(i)")!
            sut.set(placeholder, forURL: url)
        }
        
        XCTAssertEqual(sut.count, 100, "image should be one hundred")
    }
}
private extension ImagesLocalCacheTest {
    func sut() -> ImagesLocalCache {
        ImagesLocalCache(countLimit: 100, totalCostLimit: 0)
    }
}

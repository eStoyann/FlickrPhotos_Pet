//
//  ImagesLocalCacheTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 25.07.2024.
//

import XCTest
@testable import FlickrPhotos

final class ImagesLocalCacheTest: XCTestCase {

    func test_count_initiallyShouldBeEqualToZero() {
        let sut = sut()
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_count_shouldBeEqualToOne() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut[url] = .placeholder
        
        XCTAssertEqual(sut.count, 1, "count should be one")
    }
    func test_count_shouldBeEqualToOneAfterLoopFive() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        for _ in 0..<5 {
            sut[url] = .placeholder
        }
        
        XCTAssertEqual(sut.count, 1, "count should be one")
    }
    func test_count_shouldBeEqualToFiveAfterLoopFive() {
        let five = 5
        let sut = sut()
        
        for i in 0..<five {
            let url = URL(string: "http://test\(i)")!
            sut[url] = .placeholder
        }
        
        XCTAssertEqual(sut.count, five, "count should be one")
    }
    func test_count_shouldBeEqualToZero() {
        let sut = sut()
        
        for i in 0..<5 {
            let url = URL(string: "http://test\(i)")!
            sut[url] = .placeholder
        }
        for i in 0..<5 {
            let url = URL(string: "http://test\(i)")!
            sut[url] = nil
        }
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_count_shouldBeEqualToZeroAfterDeletingFiveTimes() {
        let sut = sut()
        let url = URL(string: "http://test")!
        
        sut[url] = .placeholder
        for _ in 0..<5 {
            sut[url] = nil
        }
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_count_shouldBeEqualToZeroAfterClean() {
        let sut = sut()
        
        for i in 0..<5 {
            let url = URL(string: "http://test\(i)")!
            sut[url] = .placeholder
        }
        sut.clean()
        
        XCTAssertEqual(sut.count, 0, "count should be zero")
    }
    func test_image_shouldNotBeNil() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut[url] = .placeholder
        
        let image = sut[url]
        XCTAssertNotNil(image, "image should not be nil")
    }
    func test_image_shouldBeNil() {
        let url = URL(string: "http://test")!
        let sut = sut()
        
        sut[url] = .placeholder
        sut[url] = nil
        
        let image = sut[url]
        XCTAssertNil(image, "image should be nil")
    }
    func test_count_shouldBeEqualToOneHundred() {
        let sut = sut()
        
        for i in 1...101 {
            let url = URL(string: "http://test\(i)")!
            sut[url] = .placeholder
        }
        
        XCTAssertEqual(sut.count, 100, "image should be one hundred")
    }
}
private extension ImagesLocalCacheTest {
    func sut() -> ImagesLocalCache {
        ImagesLocalCache(countLimit: 100, totalCostLimit: 1024*1024*100)
    }
}

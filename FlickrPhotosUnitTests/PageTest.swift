//
//  PageTest.swift
//  FlickrPhotosUnitTests
//
//  Created by Evgeniy Stoyan on 01.10.2024.
//

import XCTest
@testable import FlickrPhotos

final class PageTest: XCTestCase {

    func test_pageInit_numberAndSizeShouldBeOne() {
        //given
        let page = Page(number: 1, size: 1)
        //then
        XCTAssertEqual(page.number, 1)
        XCTAssertEqual(page.size, 1)
    }
}

@testable import CarSample
import XCTest

class SearchTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_search_withOneCharacterContainsIntoAttribute_shouldReturnTrue() {
        XCTAssertTrue(CarSearcher.search(searchText: "r", attribute: "renault"))
    }
    
    func test_search_withoutOneCharacterContainsIntoAttribute_shouldReturnFalse() {
        XCTAssertFalse(CarSearcher.search(searchText: "r", attribute: "peugeot"))
    }
    
    func test_search_with3FlollowedCharactersFoundIntoAttribute_shouldReturnTrue() {
        XCTAssertTrue(CarSearcher.search(searchText: "peugot", attribute: "peugeot"))
    }
    
    func test_search_withNot3FlollowedCharactersFoundIntoAttribute_shouldReturnFalse() {
        XCTAssertFalse(CarSearcher.search(searchText: "euot", attribute: "peugeot"))
    }
}

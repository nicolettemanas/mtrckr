//
//  MockAlertAction.swift
//  mtrckrTests
//
//  Created by User on 7/4/17.
//
// source: http://swiftandpainless.com/how-to-test-uialertcontroller-in-swift/
import UIKit
@testable import mtrckr

class MockAlertAction: UIAlertAction {
    typealias Handler = ((UIAlertAction) -> Void)
    var mockHandler: Handler?
    var mockTitle: String?
    var mockStyle: UIAlertActionStyle
    
    convenience init(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) {
        self.init()
        mockTitle = title
        mockStyle = style
        self.mockHandler = handler
    }
    
    override init() {
        mockStyle = .default
        super.init()
    }
    
    override class func makeActionWithTitle(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) -> MockAlertAction {
        return MockAlertAction(title: title, style: style, handler: handler)
    }
}

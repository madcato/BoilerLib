//
//  MarkdownTests.swift
//  
//
//  Created by Daniel Vela on 3/9/23.
//

@testable import BoilerLib
import XCTest

final class MarkdownTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testSimpleMarkDown() throws {
        let markdown = """
Hola **dani**

Mira esta ***lista***:
- Uno
- Dos
- Tres

Y esta otra:

1. ABC
2. DEF
3. GHI

```swift
var a = 1
var b = a + 1
```

![Image](src/image.png)

[Apple](http://apple.es)

~~This was mistaken text~~

"""
        print(MarkdownParser.parse(string: markdown))
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}

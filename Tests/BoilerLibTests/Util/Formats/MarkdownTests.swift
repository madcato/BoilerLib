//
//  MarkdownTests.swift
//  
//
//  Created by Daniel Vela on 3/9/23.
//

@testable import BoilerLib
import XCTest

final class MarkdownTests: XCTestCase {

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
        let count = MarkdownParser.parse(string: markdown).length
        XCTAssertNotEqual(count, 0)
    }


}

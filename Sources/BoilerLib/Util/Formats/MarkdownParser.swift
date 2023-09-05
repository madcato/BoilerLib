//
//  MarkdownParser.swift
//  
//
//  Created by Daniel Vela on 3/9/23.
//

import Foundation
import Markdown
import UIKit

internal struct Style {
  var strong: Bool = false
  var emphasis: Bool = false
  var strikethrough: Bool = false
  var unorderedList: Bool = false
  var orderedList: Bool = false
  var order: Int = 0
  var heading: Bool = false
  var headingLevel: Int = 0
  var codeBlock: Bool = false
  var codeLangugae: String = "unknown"
  var link: Bool = false
  var linkDestination: String = "unknown"

  static let headeingFont: [UIFontDescriptor] =  [
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1),
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2),
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
  ]

    init() { }

    init(copy: Style) {
        self.strong = copy.strong
        self.emphasis = copy.emphasis
        self.strikethrough = copy.strikethrough
        self.unorderedList = copy.unorderedList
        self.orderedList = copy.orderedList
        self.order = copy.order
        self.heading = copy.heading
        self.headingLevel = copy.headingLevel
        self.codeBlock = copy.codeBlock
        self.codeLangugae = copy.codeLangugae
        self.link = copy.link
        self.linkDestination = copy.linkDestination
    }

}

public class MarkdownParser {

  public static func parse(string: String) -> NSMutableAttributedString {
    let document = Markdown.Document(parsing: string, source: nil,
                                     options: ParseOptions(arrayLiteral: ParseOptions.parseBlockDirectives))
#if DEBUG
//        print(document.debugDescription())
#endif
    let leading = leadingCopy()
    let style = Style()
    leading.append(traverseChilds(doc: document, style: style))
    return leading
  }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  private static func traverseChilds(doc: Markup, style: Style) -> NSMutableAttributedString {
    let partialResult = NSMutableAttributedString(string: "")
      var internalStyle = Style(copy: style)
    doc.children.forEach { child in
      switch child.self {
      case let block as CodeBlock:
        internalStyle = Style(copy: style)
        internalStyle.codeBlock = true
        internalStyle.codeLangugae = block.language ?? "unknown"
        partialResult.append(NSAttributedString(string: "\n"))
        partialResult.append(apply(style: internalStyle, to: block.code))
      case is BlockDirective:
        break
      case let block as Heading:
          internalStyle = Style(copy: style)
        internalStyle.heading = true
        internalStyle.headingLevel = block.level
      case let block as HTMLBlock:
          if let data = block.rawHTML.data(using: .utf16),
             let attributedString = try? NSAttributedString(data: data,
                                                            options: [.documentType:
                                                                        NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil) {
              partialResult.append(attributedString)
          }
      case is ThematicBreak:
        break
      case is BlockQuote:
        break
      case is CustomBlock:
        break
      case is ListItem:
          internalStyle.order += 1
      case is OrderedList:
          internalStyle = Style(copy: style)
          internalStyle.orderedList = true
      case is UnorderedList:
          internalStyle = Style(copy: style)
          internalStyle.unorderedList = true
      case is Paragraph:
//        partialResult.append(NSAttributedString(string: "\n"))
          break
      case let text as Text:
        partialResult.append(apply(style: internalStyle, to: text.string))
      case let block as InlineCode:
          internalStyle = Style(copy: style)
          internalStyle.codeBlock = true
          partialResult.append(apply(style: internalStyle, to: block.code))
      case let block as CustomInline:
          partialResult.append(apply(style: internalStyle, to: block.text))
      case let block as InlineHTML:
          let data = block.rawHTML.data(using: .utf16)!
          if let attributedString = try? NSAttributedString(data: data,
                                                            options: [.documentType:
                                                                        NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil) {
              partialResult.append(attributedString)
          }
      case is SoftBreak:
          partialResult.append(apply(style: internalStyle, to: " "))
      case is SymbolLink:
        break
      case is Emphasis:
          internalStyle = Style(copy: style)
        internalStyle.emphasis = true
      case let block as Image:
        if let source = block.source {
            internalStyle = Style(copy: style)
          internalStyle.link = true
          internalStyle.linkDestination = source
        }
      case is InlineAttributes:
        break
      case let block as Link:
        if let destination = block.destination {
            internalStyle = Style(copy: style)
          internalStyle.link = true
          internalStyle.linkDestination = destination
        }
      case is Strikethrough:
          internalStyle = Style(copy: style)
        internalStyle.strikethrough = true
      case is Strong:
          internalStyle = Style(copy: style)
        internalStyle.strong = true
      default:
        fatalError("Unknown markup type \(child)")
      }
      partialResult.append(traverseChilds(doc: child, style: internalStyle))

      switch child.self {
      case is Heading, is LineBreak, is Paragraph:
        partialResult.append(NSAttributedString(string: "\n"))
      case is UnorderedList:
          internalStyle.unorderedList = false
          partialResult.append(NSAttributedString(string: "\n"))
      case is OrderedList:
          internalStyle.orderedList = false
          internalStyle.order = 0
          partialResult.append(NSAttributedString(string: "\n"))
      case is CodeBlock:
          internalStyle.codeBlock = false
          partialResult.append(NSAttributedString(string: "\n"))
      default:
        break
      }
    }
    return partialResult
  }

  // swiftlint:disable:next function_body_length
  private static func apply(style: Style, to text: String) -> NSMutableAttributedString {
    var attributedString = NSMutableAttributedString(string: text)

    if style.link,
       let url = URL(string: style.linkDestination) {
      let linkString = NSMutableAttributedString(string: text)
      linkString.addAttribute(.link, value: url, range: NSRange(location: 0, length: linkString.length))
      attributedString = linkString
    }

    if style.unorderedList {
        let symbol = NSMutableAttributedString(string: "• ")
        symbol.append(attributedString)
        attributedString = symbol
    }

    if style.orderedList {
        let symbol = NSMutableAttributedString(string: "\(style.order). ")
        symbol.append(attributedString)
        attributedString = symbol
    }

    let stringRange = NSRange(location: 0, length: attributedString.length)
    attributedString.addAttribute(NSAttributedString.Key.font,
                                  value: UIFont.preferredFont(forTextStyle: .body), range: stringRange)

    if style.strong {
      let boldFontDescriptor = UIFontDescriptor
        .preferredFontDescriptor(withTextStyle: .body)
        .withSymbolicTraits(.traitBold)!
      let boldFont = UIFont(descriptor: boldFontDescriptor, size: 0) // size 0 means 'keep the size as it is'
      attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: stringRange)
    }

    if style.emphasis {
      let boldFontDescriptor = UIFontDescriptor
        .preferredFontDescriptor(withTextStyle: .body)
        .withSymbolicTraits(.traitItalic)!
      let boldFont = UIFont(descriptor: boldFontDescriptor, size: 0) // size 0 means 'keep the size as it is'
      attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: stringRange)
    }

    if style.strikethrough {
      attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: stringRange)
    }

    if style.heading {
      let boldFontDescriptor = Style.headeingFont[style.headingLevel - 1]
      let boldFont = UIFont(descriptor: boldFontDescriptor, size: 0) // size 0 means 'keep the size as it is'
      attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: stringRange)

    }

    if style.codeBlock {
      let copyString = NSMutableAttributedString(string: "copy\n")  // "📋\n")
      let copyRange = NSRange(location: 0, length: copyString.length)
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .right
      copyString.addAttribute(.paragraphStyle, value: paragraphStyle, range: copyRange)
      var components = URLComponents()
          components.scheme = "http"
          components.host = "copyCode"
          components.path = "/"
          components.queryItems = [
            URLQueryItem(name: "q", value: attributedString.string)
          ]
      if let url = components.url {
        copyString.addAttribute(.link, value: url, range: NSRange(location: 0, length: copyRange.length))
      }
      let codeFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
      let codeFont = UIFont(descriptor: codeFontDescriptor, size: 0)
      attributedString.addAttribute(.font, value: codeFont, range: stringRange)

      copyString.append(attributedString)
      attributedString = copyString
    }

    return attributedString
  }

  private static func leadingCopy() -> NSMutableAttributedString {
    let attributedString = NSMutableAttributedString(string: "copy\n")  // "📋\n")
    let stringRange = NSRange(location: 0, length: attributedString.length)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    var components = URLComponents()
    components.scheme = "http"
    components.host = "copyAll"
    components.path = "/"
    if let url = components.url {
        attributedString.addAttribute(.link, value: url, range: NSRange(location: 0, length: stringRange.length))
    }
    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: stringRange)
    return attributedString
  }
}

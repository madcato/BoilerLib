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

  static let headeingFont: [UIFontDescriptor] =  [
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1),
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2),
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
  ]

}

public class MarkdownParser {

    public static func parse(string: String) -> NSMutableAttributedString {
      let document = Markdown.Document(parsing: string, source: nil,
                                       options: ParseOptions(arrayLiteral: ParseOptions.parseBlockDirectives))
#if DEBUG
//        print(document.debugDescription())
#endif
      let leading = leadingCopy()
      leading.append(traverseChilds(doc: document))
      return leading
    }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  private static func traverseChilds(doc: Markup, style: Style? = nil) -> NSMutableAttributedString {
    let partialResult = NSMutableAttributedString(string: "")
    var internalStyle = style ?? Style()
    doc.children.forEach { child in
      switch child.self {
      case let block as CodeBlock:
        internalStyle.codeBlock = true
        internalStyle.codeLangugae = block.language ?? "unknown"
        partialResult.append(NSAttributedString(string: "\n"))
        partialResult.append(apply(style: internalStyle, to: block.code))
//      case is BlockDirective:
//        let text = child as! BlockDirective
      case let block as Heading:
        internalStyle.heading = true
        internalStyle.headingLevel = block.level
//      case is HTMLBlock:
//        let text = child as! HTMLBlock
//      case is ThematicBreak:
//        let text = child as! ThematicBreak
//      case is BlockQuote:
//        let text = child as! BlockQuote
//      case is CustomBlock:
//        let text = child as! CustomBlock
      case let _ as ListItem:
        break
      case let _ as OrderedList:
        break
      case let _ as UnorderedList:
        break
      case is Paragraph:
        partialResult.append(NSAttributedString(string: "\n"))
      case let text as Text:
        partialResult.append(apply(style: internalStyle, to: text.string))
      case is InlineCode:
        break
      case is CustomInline:
        break
      case is InlineHTML:
        break
      case is SoftBreak:
        break
      case is SymbolLink:
        break
      case is Emphasis:
        internalStyle.emphasis = true
      case is Image:
        break
      case is InlineAttributes:
        break
      case is Link:
        break
      case is Strikethrough:
        internalStyle.strikethrough = true
      case is Strong:
        internalStyle.strong = true
      default:
        fatalError("Unknown markup type \(child)")
      }
      partialResult.append(traverseChilds(doc: child, style: internalStyle))
      internalStyle = Style()

      switch child.self {
      case is Heading, is LineBreak, is Paragraph, is CodeBlock:
        partialResult.append(NSAttributedString(string: "\n"))
      default:
        break
      }
    }
    return partialResult
  }

  private static func apply(style: Style, to text: String) -> NSMutableAttributedString {
    let attributedString = NSMutableAttributedString(string: text)
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

    if style.unorderedList {

    }

    if style.orderedList {
//      order

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

        let codeFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
        let codeFont = UIFont(descriptor: codeFontDescriptor, size: 0)
        attributedString.addAttribute(.font, value: codeFont, range: stringRange)

        copyString.append(attributedString)
        return copyString
    }
    return attributedString
  }

  private static func leadingCopy() -> NSMutableAttributedString {
    let attributedString = NSMutableAttributedString(string: "copy\n")  // "📋\n")
    let stringRange = NSRange(location: 0, length: attributedString.length)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: stringRange)
    return attributedString
  }
}

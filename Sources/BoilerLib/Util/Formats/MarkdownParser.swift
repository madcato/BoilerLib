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
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3),
  ]

}

public class MarkdownParser {

    public static func parse(string: String) -> NSMutableAttributedString {
      let document = Markdown.Document(parsing: string, source: nil, options: ParseOptions(arrayLiteral: ParseOptions.parseBlockDirectives))
#if DEBUG
//        print(document.debugDescription())
#endif
      let leading = leadingCopy()
      leading.append(traverseChilds(doc: document))
      return leading
    }

  private static func traverseChilds(doc: Markup, style: Style? = nil) -> NSMutableAttributedString {
    let partialResult = NSMutableAttributedString(string: "")
    var internalStyle = style ?? Style()
    doc.children.forEach { child in
      switch child.self {
      case is CodeBlock:
        let text = child as! CodeBlock
        internalStyle.codeBlock = true
        internalStyle.codeLangugae = text.language ?? "unknown"
        partialResult.append(NSAttributedString(string: "\n"))
        partialResult.append(apply(style: internalStyle, to: text.code))
//        partialResult += "* CodeBlock\n"
//        partialResult += "LANGUAGE: \(text.language ?? "unknown") --> \(text.code)\n"
      case is BlockDirective:
        let text = child as! BlockDirective
//        partialResult += "* BlockDirective\n"
//        partialResult += "\(text.name)\n"
      case is Heading:
        let text = child as! Heading
        internalStyle.heading = true
        internalStyle.headingLevel = text.level
//        partialResult += "* Heading\n"
//        partialResult += "\(text.level)\n"
      case is HTMLBlock:
        let text = child as! HTMLBlock
//        partialResult += "* HTMLBlock\n"
//        partialResult += "\(text.rawHTML)\n"
      case is ThematicBreak:
        let text = child as! ThematicBreak
//        partialResult += "* ThematicBreak\n"
      case is BlockQuote:
        let text = child as! BlockQuote
//        partialResult += "* BlockQuote\n"
      case is CustomBlock:
        let text = child as! CustomBlock
//        partialResult += "* CustomBlock\n"
      case is ListItem:
        let text = child as! ListItem
//        partialResult += "* ListItem\n"
      case is OrderedList:
        let text = child as! OrderedList
//        partialResult += "* OrderedList\n"
      case is UnorderedList:
        let text = child as! UnorderedList
//        partialResult += "* UnorderedList\n"
      case is Paragraph:
//        partialResult += "* Paragraph\n"
        let text = child as! Paragraph
        partialResult.append(NSAttributedString(string: "\n"))
      case is Text:
        let text = child as! Text
        partialResult.append(apply(style: internalStyle, to: text.string))
      case is InlineCode:
//        partialResult += "* InlineCode\n"
        let text = child as! InlineCode
//        partialResult += "\(text.code)\n"
      case is CustomInline:
//        partialResult += "* CustomInline\n"
        let text = child as! CustomInline
//        partialResult += "\(text.text)\n"
      case is InlineHTML:
//        partialResult += "* InlineHTML\n"
        let text = child as! InlineHTML
//        partialResult += "\(text.rawHTML)\n"
      case is SoftBreak:
//        partialResult += "* SoftBreak\n"
        let text = child as! SoftBreak
      case is SymbolLink:
//        partialResult += "* SymbolLink\n"
        let text = child as! SymbolLink
//        partialResult += "\(text.destination)\n"
      case is Emphasis:
        internalStyle.emphasis = true
      case is Image:
//        partialResult += "* Image\n"
        let text = child as! Image
//        partialResult += "SOURCE: \(text.source ?? "unknown") --> TITLE: \(text.title)\n"
      case is InlineAttributes:
//        partialResult += "* InlineAttributes\n"
        let text = child as! InlineAttributes
//        partialResult += "\(text.attributes)\n"
      case is Link:
//        partialResult += "* Link\n"
        let text = child as! Link
//        partialResult += "\(text.destination ?? "")\n"
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
      let boldFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withSymbolicTraits(.traitBold)!
      let boldFont = UIFont(descriptor: boldFontDescriptor, size: 0) // size 0 means 'keep the size as it is'
      attributedString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: stringRange)
    }

    if style.emphasis {
      let boldFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withSymbolicTraits(.traitItalic)!
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
        let copyString = NSMutableAttributedString(string: "copy\n") //"📋\n")
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
    let attributedString = NSMutableAttributedString(string: "copy\n") //"📋\n")
    let stringRange = NSRange(location: 0, length: attributedString.length)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: stringRange)
    return attributedString
  }
}

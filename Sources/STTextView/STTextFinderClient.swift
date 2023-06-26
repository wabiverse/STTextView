/* -----------------------------------------------------------
 * :: :  C  O  S  M  O  :                                   ::
 * -----------------------------------------------------------
 * @wabistudios :: cosmos :: realms
 *
 * CREDITS.
 *
 * T.Furby              @furby-tm       <devs@wabi.foundation>
 *
 *         Copyright (C) 2023 Wabi Animation Studios, Ltd. Co.
 *                                        All Rights Reserved.
 * -----------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ----------------------------------------------------------- */

import Cocoa

final class STTextFinderClient: NSObject, NSTextFinderClient
{
  weak var textView: STTextView?

  private var textContentManager: NSTextContentManager?
  {
    textView?.textContentManager
  }

  var string: String
  {
    textView?.string ?? ""
  }

  var isSelectable: Bool
  {
    textView?.isSelectable ?? false
  }

  public var allowsMultipleSelection: Bool
  {
    false
  }

  func replaceCharacters(in range: NSRange, with string: String)
  {
    guard let textContentManager,
          let textRange = NSTextRange(range, in: textContentManager),
          let textView
    else
    {
      return
    }

    textView.replaceCharacters(in: textRange, with: string, useTypingAttributes: true, allowsTypingCoalescing: false)
  }

  public var firstSelectedRange: NSRange
  {
    guard let firstTextSelectionRange = textView?.textLayoutManager.textSelections.first?.textRanges.first,
          let textContentManager
    else
    {
      return NSRange()
    }

    return NSRange(firstTextSelectionRange, in: textContentManager)
  }

  public var selectedRanges: [NSValue]
  {
    set
    {
      guard let textContentManager,
            let textLayoutManager = textView?.textLayoutManager
      else
      {
        assertionFailure()
        return
      }

      let textRanges = newValue.map(\.rangeValue).compactMap
      {
        NSTextRange($0, in: textContentManager)
      }

      textLayoutManager.textSelections = [NSTextSelection(textRanges, affinity: .downstream, granularity: .character)]
      textView?.updateSelectionHighlights()
      textView?.updateTypingAttributes()
    }

    get
    {
      guard let textContentManager,
            let textLayoutManager = textView?.textLayoutManager,
            !textLayoutManager.textSelections.isEmpty
      else
      {
        return []
      }

      return textLayoutManager.textSelections
        .filter
        {
          !$0.isTransient
        }
        .flatMap(\.textRanges)
        .compactMap
        {
          NSRange($0, in: textContentManager)
        }.map(\.nsValue)
    }
  }

  var isEditable: Bool
  {
    textView?.isEditable ?? false
  }

  func scrollRangeToVisible(_ range: NSRange)
  {
    guard let textContentManager,
          let textRange = NSTextRange(range, in: textContentManager)
    else
    {
      return
    }

    textView?.scrollToSelection(NSTextSelection(range: textRange, affinity: .downstream, granularity: .character))
  }

  var visibleCharacterRanges: [NSValue]
  {
    guard let viewportTextRange = textView?.textLayoutManager.textViewportLayoutController.viewportRange,
          let textContentManager
    else
    {
      return []
    }

    return [NSRange(viewportTextRange, in: textContentManager).nsValue]
  }

  func rects(forCharacterRange range: NSRange) -> [NSValue]?
  {
    guard let textContentManager,
          let textRange = NSTextRange(range, in: textContentManager)
    else
    {
      return nil
    }

    var rangeRects: [CGRect] = []
    textView?.textLayoutManager.enumerateTextSegments(in: textRange, type: .selection, options: .rangeNotRequired, using: { _, rect, _, _ in
      rangeRects.append(rect.pixelAligned)
      return true
    })

    return rangeRects.map { NSValue(rect: $0) }
  }

  func contentView(at _: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView
  {
    guard let textView,
          let viewportRange = textView.textLayoutManager.textViewportLayoutController.viewportRange
    else
    {
      assertionFailure()
      return textView!
    }

    outRange.pointee = NSRange(viewportRange, in: textView.textContentManager)
    return textView
  }

  func drawCharacters(in range: NSRange, forContentView view: NSView)
  {
    guard let textView = view as? STTextView,
          let textRange = NSTextRange(range, in: textView.textContentManager),
          let context = NSGraphicsContext.current?.cgContext
    else
    {
      assertionFailure()
      return
    }

    if let layoutFragment = textView.textLayoutManager.textLayoutFragment(for: textRange.location)
    {
      layoutFragment.draw(at: layoutFragment.layoutFragmentFrame.pixelAligned.origin, in: context)
    }
  }
}

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
import Foundation

public extension STTextView
{
  /// Updates the insertion point’s location and optionally restarts the blinking cursor timer.
  func updateInsertionPointStateAndRestartTimer()
  {
    // Remove insertion point layers
    contentView.subviews.removeAll(where: { view in
      type(of: view) == insertionPointViewClass
    })

    if shouldDrawInsertionPoint
    {
      for textRange in textLayoutManager.insertionPointSelections.flatMap(\.textRanges)
      {
        textLayoutManager.enumerateTextSegments(in: textRange, type: .selection, options: .rangeNotRequired)
        { _, textSegmentFrame, _, _ in
          var selectionFrame = textSegmentFrame.intersection(frame).pixelAligned
          guard !selectionFrame.isNull, !selectionFrame.isInfinite
          else
          {
            return true
          }

          // because `textLayoutManager.enumerateTextLayoutFragments(from: nil, options: [.ensuresExtraLineFragment, .ensuresLayout, .estimatesSize])`
          // returns unexpected value for extra line fragment height (return 14) that is not correct in the context,
          // therefore for empty override height with value manually calculated from font + paragraph style
          if textRange == textContentManager.documentRange
          {
            selectionFrame = NSRect(origin: selectionFrame.origin, size: CGSize(width: selectionFrame.width, height: typingLineHeight)).pixelAligned
          }

          let insertionView = insertionPointViewClass.init(frame: selectionFrame)
          insertionView.insertionPointColor = insertionPointColor
          insertionView.insertionPointWidth = insertionPointWidth
          insertionView.updateGeometry()

          if isFirstResponder
          {
            insertionView.blinkStart()
          }
          else
          {
            insertionView.blinkStop()
          }

          contentView.addSubview(insertionView)

          return true
        }
      }
    }
  }
}

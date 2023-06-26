/* -----------------------------------------------------------
 * :: :  C  O  S  M  O  :                                   ::
 * -----------------------------------------------------------
 * @wabistudios :: cosmos :: realms
 *
 * CREDITS.
 *
 * T.Furby              @furby-tm       <devs@wabi.foundation>
 * D.Kirkpatrick  @dkirkpatrick99  <d.kirkpatrick99@gmail.com>
 *
 *         Copyright (C) 2023 Wabi Animation Studios, Ltd. Co.
 *                                        All Rights Reserved.
 * -----------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ----------------------------------------------------------- */

import Cocoa

public extension NSTextLayoutManager
{
  @available(*, deprecated, message: "Use insertionPointLocations")
  var insertionPointLocation: NSTextLocation?
  {
    guard let textSelection = insertionPointSelections.first
    else
    {
      return nil
    }

    return textSelection.textRanges.first?.location

    // FB11961508 NSTextSelectionNavigation.resolvedInsertionLocation sometimes crashes instead return nil
    // return textSelectionNavigation.resolvedInsertionLocation(for: textSelection, writingDirection: .leftToRight)
  }

  var insertionPointLocations: [NSTextLocation]
  {
    insertionPointSelections.flatMap(\.textRanges).map(\.location)
  }

  var insertionPointSelections: [NSTextSelection]
  {
    textSelections.filter(_textSelectionInsertionPointFilter)
  }

  /// Append insertion point.
  /// - Parameter point: A CGPoint that represents the location of the tap or click.
  internal func appendInsertionPointSelection(interactingAt point: CGPoint)
  {
    // Insertion points are either tge selections with a single empty range
    // or single selection with multiple empty ranges. Both cases are handled.
    // I didn't find an advantage of one approach over the other
    textSelections += textSelectionNavigation.textSelections(
      interactingAt: point,
      inContainerAt: documentRange.location,
      anchors: [],
      modifiers: [],
      selecting: false,
      bounds: usageBoundsForTextContainer
    )
  }
}

private let _textSelectionInsertionPointFilter: (NSTextSelection) -> Bool = { textSelection in
  !textSelection.isLogical
    && !textSelection.isTransient
    && textSelection.textRanges.contains
    { textRange in
      textRange.isEmpty
    }
}

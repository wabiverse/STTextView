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

extension STTextView
{
  override open func centerSelectionInVisibleArea(_: Any?)
  {
    guard let firstTextSelection = textLayoutManager.textSelections.last
    else
    {
      return
    }

    scrollToSelection(firstTextSelection)
    needsDisplay = true
  }

  override open func pageUp(_ sender: Any?)
  {
    scrollPageUp(sender)
  }

  override open func pageUpAndModifySelection(_ sender: Any?)
  {
    pageUp(sender)
  }

  override open func pageDown(_ sender: Any?)
  {
    scrollPageDown(sender)
  }

  override open func pageDownAndModifySelection(_ sender: Any?)
  {
    pageDown(sender)
  }

  override open func scrollPageDown(_: Any?)
  {
    scroll(visibleRect.moved(dy: visibleRect.height).origin)
  }

  override open func scrollPageUp(_: Any?)
  {
    scroll(visibleRect.moved(dy: -visibleRect.height).origin)
  }

  override open func scrollToBeginningOfDocument(_: Any?)
  {
    scroll(CGPoint(x: visibleRect.origin.x, y: frame.minY))
  }

  override open func scrollToEndOfDocument(_: Any?)
  {
    scroll(CGPoint(x: visibleRect.origin.x, y: frame.maxY))
  }
}

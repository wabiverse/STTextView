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

extension STTextView: NSColorChanging
{
  public func changeColor(_ colorPanel: NSColorPanel?)
  {
    guard isEditable, let colorPanel
    else
    {
      return
    }

    if !textLayoutManager.insertionPointLocations.isEmpty
    {
      typingAttributes[.foregroundColor] = colorPanel.color
    }
    else
    {
      for textRange in textLayoutManager.textSelections.flatMap(\.textRanges) where !textRange.isEmpty
      {
        addAttributes([.foregroundColor: colorPanel.color], range: textRange)
      }
    }
  }
}

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

extension STTextView: NSTextLayoutOrientationProvider
{
  public var layoutOrientation: NSLayoutManager.TextLayoutOrientation
  {
    switch textLayoutManager.textLayoutOrientation(at: textLayoutManager.documentRange.location)
    {
      case .horizontal:
        return .horizontal
      case .vertical:
        return .vertical
      @unknown default:
        return textContainer.layoutOrientation
    }
  }
}

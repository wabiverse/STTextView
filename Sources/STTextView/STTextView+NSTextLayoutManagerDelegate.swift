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

extension STTextView: NSTextLayoutManagerDelegate
{
  public func textLayoutManager(_: NSTextLayoutManager, textLayoutFragmentFor _: NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment
  {
    STTextLayoutFragment(
      textElement: textElement,
      range: textElement.elementRange,
      paragraphStyle: typingAttributes[.paragraphStyle] as? NSParagraphStyle ?? .default
    )
  }
}

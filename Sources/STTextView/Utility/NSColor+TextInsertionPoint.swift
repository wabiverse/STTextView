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

import AppKit

extension NSColor
{
  static var defaultTextInsertionPoint: NSColor
  {
    #if swift(>=5.9)
      /* for macOS 14, Sonoma. */
      if #available(macOS 14, *)
      {
        return .textInsertionPointColor
      }
    #endif /* swift(>=5.9) */

    return .controlAccentColor
  }
}

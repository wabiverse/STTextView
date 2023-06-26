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

final class STTextLayoutManager: NSTextLayoutManager
{
  override var textSelections: [NSTextSelection]
  {
    didSet
    {
      NotificationCenter.default.post(
        Notification(name: STTextView.didChangeSelectionNotification, object: self, userInfo: nil)
      )
    }
  }
}

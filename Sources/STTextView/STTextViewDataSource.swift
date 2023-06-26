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
import Foundation

/// The methods that an object adopts to manage data and provide views for text view.
public protocol STTextViewDataSource: AnyObject
{
  /// View for annotaion
  func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: STLineAnnotation, textLineFragment: NSTextLineFragment) -> NSView?

  /// Annotations.
  ///
  /// Call `reloadData()` to notify STTextView about changes to annotations returned by this method.
  func textViewAnnotations(_ textView: STTextView) -> [STLineAnnotation]
}

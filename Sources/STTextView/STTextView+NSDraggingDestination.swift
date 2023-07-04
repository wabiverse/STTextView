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

/// A set of methods that the destination object (or recipient) of a dragged image must implement.
///
/// NSView conforms to NSDraggingDestination
extension STTextView
{
  override open func concludeDragOperation(_ sender: NSDraggingInfo?)
  {
    super.concludeDragOperation(sender)
    cleanUpAfterDragOperation()
  }
}

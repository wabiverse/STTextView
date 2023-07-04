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

extension STTextView: NSDraggingSource
{
  public func draggingSession(_: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation
  {
    context == .outsideApplication ? .copy : .move
  }

  public func draggingSession(_: NSDraggingSession, endedAt _: NSPoint, operation _: NSDragOperation)
  {
    cleanUpAfterDragOperation()
    draggingSession = nil
  }
}

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
  override open func keyDown(with event: NSEvent)
  {
    guard isEditable
    else
    {
      super.keyDown(with: event)
      return
    }

    processingKeyEvent = true
    defer
    {
      processingKeyEvent = false
    }

    NSCursor.setHiddenUntilMouseMoves(true)

    // ^Space -> complete:
    if event.modifierFlags.contains(.control), event.charactersIgnoringModifiers == " "
    {
      doCommand(by: #selector(NSStandardKeyBindingResponding.complete(_:)))
      return
    }

    if inputContext?.handleEvent(event) == false
    {
      interpretKeyEvents([event])
    }
  }
}

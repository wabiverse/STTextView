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
import Foundation

// NSResponder.undoManager doesn work out of the box (as 03.2022, macOS 12.3)
// see https://gist.github.com/krzyzanowskim/1a13f27e6b469ca2ffcf9b53588b837a

extension STTextView
{
  override open var undoManager: UndoManager?
  {
    guard allowsUndo
    else
    {
      return nil
    }

    return delegate?.undoManager(for: self) ?? _undoManager
  }

  @objc func undo(_: AnyObject?)
  {
    if allowsUndo
    {
      undoManager?.undo()
    }
  }

  @objc func redo(_: AnyObject?)
  {
    if allowsUndo
    {
      undoManager?.redo()
    }
  }
}

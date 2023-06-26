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
  override open func insertLineBreak(_: Any?)
  {
    guard let scalar = Unicode.Scalar(NSLineSeparatorCharacter)
    else
    {
      assertionFailure()
      return
    }

    insertText(String(Character(scalar)), replacementRange: .notFound)
  }

  override open func insertTab(_: Any?)
  {
    guard let scalar = Unicode.Scalar(NSTabCharacter)
    else
    {
      assertionFailure()
      return
    }
    insertText(String(Character(scalar)), replacementRange: .notFound)
  }

  override open func insertBacktab(_: Any?)
  {
    guard let scalar = Unicode.Scalar(NSBackTabCharacter)
    else
    {
      assertionFailure()
      return
    }
    insertText(String(Character(scalar)), replacementRange: .notFound)
  }

  override open func insertTabIgnoringFieldEditor(_ sender: Any?)
  {
    insertTab(sender)
  }

  override open func insertParagraphSeparator(_: Any?)
  {
    guard let scalar = Unicode.Scalar(NSParagraphSeparatorCharacter)
    else
    {
      assertionFailure()
      return
    }
    insertText(String(Character(scalar)), replacementRange: .notFound)
  }

  override open func insertNewline(_: Any?)
  {
    insertText("\n")
  }

  override open func insertNewlineIgnoringFieldEditor(_ sender: Any?)
  {
    insertNewline(sender)
  }

  override open func insertText(_ insertString: Any)
  {
    insertText(insertString, replacementRange: .notFound)
  }
}

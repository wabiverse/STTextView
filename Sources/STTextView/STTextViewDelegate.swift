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

/// A set of optional methods that text view delegates can use to manage selection,
/// set text attributes and more.
public protocol STTextViewDelegate: AnyObject
{
  /// Returns the undo manager for the specified text view.
  ///
  /// This method provides the flexibility to return a custom undo manager for the text view.
  /// Although STTextView implements undo and redo for changes to text,
  /// applications may need a custom undo manager to handle interactions between changes
  /// to text and changes to other items in the application.
  func undoManager(for textView: STTextView) -> UndoManager?
  /// Any keyDown or paste which changes the contents causes this
  func textViewWillChangeText(_ notification: Notification)
  /// Any keyDown or paste which changes the contents causes this
  func textViewDidChangeText(_ notification: Notification)
  /// Sent when the selection changes in the text view.
  func textViewDidChangeSelection(_ notification: Notification)
  /// Sent when a text view needs to determine if text in a specified range should be changed.
  func textView(_ textView: STTextView, shouldChangeTextIn affectedCharRange: NSTextRange, replacementString: String?) -> Bool
  /// Sent when a text view will change text.
  func textView(_ textView: STTextView, willChangeTextIn affectedCharRange: NSTextRange, replacementString: String)
  /// Sent when a text view did change text.
  func textView(_ textView: STTextView, didChangeTextIn affectedCharRange: NSTextRange, replacementString: String)

  /// Allows delegate to control the context menu returned by the text view.
  /// - Parameters:
  ///   - view: The text view sending the message.
  ///   - menu: The proposed contextual menu.
  ///   - event: The mouse-down event that initiated the contextual menu’s display.
  /// - Returns: A menu to use as the contextual menu. You can return `menu` unaltered, or you can return a customized menu.
  func textView(_ view: STTextView, menu: NSMenu, for event: NSEvent, at location: NSTextLocation) -> NSMenu?

  /// Completion items
  func textView(_ textView: STTextView, completionItemsAtLocation location: NSTextLocation) -> [Any]?

  func textView(_ textView: STTextView, insertCompletionItem item: Any)

  /// Due to Swift 5.6 generics limitation it can't return STCompletionViewControllerProtocol
  func textViewCompletionViewController(_ textView: STTextView) -> STAnyCompletionViewController?
}

public extension STTextViewDelegate
{
  func undoManager(for _: STTextView) -> UndoManager?
  {
    nil
  }

  func textViewWillChangeText(_: Notification)
  {
    //
  }

  func textViewDidChangeText(_: Notification)
  {
    //
  }

  func textViewDidChangeSelection(_: Notification)
  {
    //
  }

  func textView(_: STTextView, shouldChangeTextIn _: NSTextRange, replacementString _: String?) -> Bool
  {
    true
  }

  func textView(_: STTextView, willChangeTextIn _: NSTextRange, replacementString _: String) {}

  func textView(_: STTextView, didChangeTextIn _: NSTextRange, replacementString _: String) {}

  func textView(_: STTextView, menu: NSMenu, for _: NSEvent, at _: NSTextLocation) -> NSMenu?
  {
    menu
  }

  func textView(_: STTextView, completionItemsAtLocation _: NSTextLocation) -> [Any]?
  {
    nil
  }

  func textView(_: STTextView, insertCompletionItem _: Any) {}

  func textViewCompletionViewController(_: STTextView) -> STAnyCompletionViewController?
  {
    nil
  }
}

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

extension STTextView
{
  /// Supporting Autocomplete
  ///
  /// see NSStandardKeyBindingResponding
  override open func complete(_: Any?)
  {
    if completionWindowController.isVisible
    {
      completionWindowController.close()
    }
    else
    {
      performCompletion()
    }
  }

  override open func cancelOperation(_ sender: Any?)
  {
    complete(sender)
  }

  @MainActor
  private func performCompletion()
  {
    guard let insertionPointLocation = textLayoutManager.insertionPointLocations.first,
          let textCharacterSegmentRect = textLayoutManager.textSelectionSegmentFrame(at: insertionPointLocation, type: .standard)
    else
    {
      completionWindowController.close()
      return
    }

    // move left by arbitrary 14px
    let characterSegmentFrame = textCharacterSegmentRect.moved(dx: -14, dy: textCharacterSegmentRect.height)

    let completions = delegate?.textView(self, completionItemsAtLocation: insertionPointLocation) ?? []

    dispatchPrecondition(condition: .onQueue(.main))

    if completions.isEmpty
    {
      completionWindowController.close()
    }
    else if let window
    {
      let completionWindowOrigin = window.convertPoint(toScreen: convert(characterSegmentFrame.origin, to: nil))
      completionWindowController.showWindow(at: completionWindowOrigin, items: completions, parent: window)
      completionWindowController.delegate = self
    }
  }
}

extension STTextView: CompletionWindowDelegate
{
  func completionWindowController(_: CompletionWindowController, complete item: Any, movement _: NSTextMovement)
  {
    delegate?.textView(self, insertCompletionItem: item)
  }
}

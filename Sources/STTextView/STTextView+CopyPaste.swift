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
import UniformTypeIdentifiers

extension STTextView
{
  @objc open func copy(_: Any?)
  {
    if textLayoutManager.textSelections.isEmpty, let attributedString = textContentManager.attributedString(in: nil)
    {
      updatePasteboard(with: attributedString)
    }
    else if !textLayoutManager.textSelections.isEmpty
    {
      if let textSelectionsAttributedString = textLayoutManager.textSelectionsAttributedString()
      {
        updatePasteboard(with: textSelectionsAttributedString)
      }
    }
  }

  @objc open func paste(_ sender: Any?)
  {
    let pasteboard = NSPasteboard.general

    if pasteboard.canReadItem(withDataConformingToTypes: [UTType.rtf.identifier])
    {
      pasteAsRichText(sender)
    }
    else if pasteboard.canReadItem(withDataConformingToTypes: [UTType.plainText.identifier])
    {
      pasteAsPlainText(sender)
    }
  }

  @objc open func pasteAsPlainText(_: Any?)
  {
    guard let string = NSPasteboard.general.string(forType: .string)
    else
    {
      return
    }

    replaceCharacters(
      in: textLayoutManager.textSelections.flatMap(\.textRanges),
      with: string,
      useTypingAttributes: true,
      allowsTypingCoalescing: false
    )
  }

  /// This action method inserts the contents of the pasteboard into the receiver’s text as rich text, maintaining its attributes.
  @objc open func pasteAsRichText(_: Any?)
  {
    let pasteboard = NSPasteboard.general
    if pasteboard.canReadItem(withDataConformingToTypes: [UTType.rtf.identifier]), let attributedString = pasteboard.readObjects(forClasses: [NSAttributedString.self])?.first as? NSAttributedString
    {
      replaceCharacters(
        in: textLayoutManager.textSelections.flatMap(\.textRanges),
        with: attributedString,
        allowsTypingCoalescing: false
      )
    }
  }

  @objc open func cut(_ sender: Any?)
  {
    copy(sender)
    delete(sender)
  }

  @objc open func delete(_: Any?)
  {
    for textRange in textLayoutManager.textSelections.flatMap(\.textRanges)
    {
      // "replaceContents" doesn't work with NSTextContentStorage at all
      // textLayoutManager.replaceContents(in: textRange, with: NSAttributedString())
      let nsrange = NSRange(textRange, in: textContentManager)
      insertText("", replacementRange: nsrange)
    }
  }

  private func updatePasteboard(with text: String)
  {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects([text as NSPasteboardWriting])
  }

  private func updatePasteboard(with text: NSAttributedString)
  {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects([text as NSPasteboardWriting])
  }
}

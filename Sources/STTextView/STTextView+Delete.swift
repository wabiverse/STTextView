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

extension STTextView
{
  override open func deleteForward(_: Any?)
  {
    if let deletedString = delete(direction: .forward, destination: .character, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .delete, string: deletedString)
    }
  }

  override open func deleteBackward(_: Any?)
  {
    if let deletedString = delete(direction: .backward, destination: .character, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .delete, string: deletedString)
    }
  }

  override open func deleteBackwardByDecomposingPreviousCharacter(_: Any?)
  {
    if let deletedString = delete(direction: .backward, destination: .character, allowsDecomposition: true)
    {
      Yanking.shared.kill(action: .delete, string: deletedString)
    }
  }

  override open func deleteWordBackward(_: Any?)
  {
    if let deletedString = delete(direction: .backward, destination: .word, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .deleteWordBackward, string: deletedString)
    }
  }

  override open func deleteWordForward(_: Any?)
  {
    if let deletedString = delete(direction: .forward, destination: .word, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .deleteWordForward, string: deletedString)
    }
  }

  override open func deleteToBeginningOfLine(_: Any?)
  {
    if let deletedString = delete(direction: .backward, destination: .line, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .deleteToBeginningOfLine, string: deletedString)
    }
  }

  override open func deleteToEndOfLine(_: Any?)
  {
    if let deletedString = delete(direction: .forward, destination: .line, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .deleteToEndOfLine, string: deletedString)
    }
  }

  override open func deleteToBeginningOfParagraph(_: Any?)
  {
    if let deletedString = delete(direction: .backward, destination: .paragraph, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .deleteToBeginningOfLine, string: deletedString)
    }
  }

  override open func deleteToEndOfParagraph(_: Any?)
  {
    if let deletedString = delete(direction: .forward, destination: .paragraph, allowsDecomposition: false)
    {
      Yanking.shared.kill(action: .deleteToEndOfParagraph, string: deletedString)
    }
  }

  @discardableResult
  private func delete(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, allowsDecomposition: Bool) -> String?
  {
    let textRanges = textLayoutManager.textSelections.flatMap
    { textSelection -> [NSTextRange] in
      if destination == .word
      {
        // FB9925766. deletionRanges only works correctly if textSelection is at the end of the word
        // Workaround
        return textLayoutManager.textSelectionNavigation.destinationSelection(
          for: textSelection,
          direction: direction,
          destination: destination,
          extending: true,
          confined: false
        )?.textRanges ?? []
      }
      else
      {
        return textLayoutManager.textSelectionNavigation.deletionRanges(
          for: textSelection,
          direction: direction,
          destination: destination,
          allowsDecomposition: allowsDecomposition
        )
      }
    }

    if textRanges.isEmpty
    {
      return nil
    }

    let deletedString = textRanges.reduce(into: "")
    { partialResult, textRange in
      partialResult += textLayoutManager.substring(for: textRange) ?? ""
    }

    replaceCharacters(in: textRanges, with: "", useTypingAttributes: false, allowsTypingCoalescing: true)
    return deletedString
  }
}

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
  public func setSelectedTextRange(_ textRange: NSTextRange, updateLayout: Bool = true)
  {
    guard isSelectable, textRange.endLocation <= textContentManager.documentRange.endLocation
    else
    {
      return
    }

    textLayoutManager.textSelections = [
      NSTextSelection(range: textRange, affinity: .downstream, granularity: .character),
    ]

    updateTypingAttributes()

    if updateLayout
    {
      needsLayout = true
    }
  }

  public func setSelectedRange(_ range: NSRange)
  {
    guard let textRange = NSTextRange(range, in: textContentManager)
    else
    {
      preconditionFailure("Invalid range \(range)")
    }
    setSelectedTextRange(textRange)
  }

  override open func selectAll(_: Any?)
  {
    guard isSelectable
    else
    {
      return
    }

    textLayoutManager.textSelections = [
      NSTextSelection(range: textLayoutManager.documentRange, affinity: .downstream, granularity: .line),
    ]

    updateTypingAttributes()
    updateSelectionHighlights()
  }

  override open func selectLine(_: Any?)
  {
    guard isSelectable, let enclosingSelection = textLayoutManager.textSelections.last
    else
    {
      return
    }

    textLayoutManager.textSelections = [
      textLayoutManager.textSelectionNavigation.textSelection(
        for: .line,
        enclosing: enclosingSelection
      ),
    ]

    updateTypingAttributes()
    needsScrollToSelection = true
    needsDisplay = true
  }

  override open func selectWord(_: Any?)
  {
    guard isSelectable, let enclosingSelection = textLayoutManager.textSelections.last
    else
    {
      return
    }

    textLayoutManager.textSelections = [
      textLayoutManager.textSelectionNavigation.textSelection(
        for: .word,
        enclosing: enclosingSelection
      ),
    ]

    updateTypingAttributes()
    needsScrollToSelection = true
    needsDisplay = true
  }

  override open func selectParagraph(_: Any?)
  {
    guard isSelectable, let enclosingSelection = textLayoutManager.textSelections.last
    else
    {
      return
    }

    textLayoutManager.textSelections = [
      textLayoutManager.textSelectionNavigation.textSelection(
        for: .paragraph,
        enclosing: enclosingSelection
      ),
    ]

    updateTypingAttributes()
    needsScrollToSelection = true
    needsDisplay = true
  }

  override open func moveLeft(_: Any?)
  {
    setTextSelections(
      direction: .left,
      destination: .character,
      extending: false
    )
  }

  override open func moveLeftAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .left,
      destination: .character,
      extending: true
    )
  }

  override open func moveRight(_: Any?)
  {
    setTextSelections(
      direction: .right,
      destination: .character,
      extending: false
    )
  }

  override open func moveRightAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .right,
      destination: .character,
      extending: true
    )
  }

  override open func moveUp(_: Any?)
  {
    setTextSelections(
      direction: .up,
      destination: .character,
      extending: false
    )
  }

  override open func moveUpAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .up,
      destination: .character,
      extending: true
    )
  }

  override open func moveDown(_: Any?)
  {
    setTextSelections(
      direction: .down,
      destination: .character,
      extending: false
    )
  }

  override open func moveDownAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .down,
      destination: .character,
      extending: true
    )
  }

  override open func moveForward(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .character,
      extending: false
    )
  }

  override open func moveForwardAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .character,
      extending: true
    )
  }

  override open func moveBackward(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .character,
      extending: false
    )
  }

  override open func moveBackwardAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .character,
      extending: true
    )
  }

  override open func moveWordLeft(_: Any?)
  {
    setTextSelections(
      direction: .left,
      destination: .word,
      extending: false
    )
  }

  override open func moveWordLeftAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .left,
      destination: .word,
      extending: true
    )
  }

  override open func moveWordRight(_: Any?)
  {
    setTextSelections(
      direction: .right,
      destination: .word,
      extending: false
    )
  }

  override open func moveWordRightAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .right,
      destination: .word,
      extending: true
    )
  }

  override open func moveWordForward(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .word,
      extending: false
    )
  }

  override open func moveWordForwardAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .word,
      extending: true
    )
  }

  override open func moveWordBackward(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .word,
      extending: false
    )
  }

  override open func moveWordBackwardAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .word,
      extending: true
    )
  }

  override open func moveToBeginningOfLine(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .line,
      extending: false
    )
  }

  override open func moveToBeginningOfLineAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .line,
      extending: true
    )
  }

  override open func moveToLeftEndOfLine(_: Any?)
  {
    setTextSelections(
      direction: .left,
      destination: .line,
      extending: false
    )
  }

  override open func moveToLeftEndOfLineAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .left,
      destination: .line,
      extending: true
    )
  }

  override open func moveToEndOfLine(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .line,
      extending: false
    )
  }

  override open func moveToEndOfLineAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .line,
      extending: true
    )
  }

  override open func moveToRightEndOfLine(_: Any?)
  {
    setTextSelections(
      direction: .right,
      destination: .line,
      extending: false
    )
  }

  override open func moveToRightEndOfLineAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .right,
      destination: .line,
      extending: true
    )
  }

  override open func moveParagraphForwardAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .paragraph,
      extending: true
    )
  }

  override open func moveParagraphBackwardAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .paragraph,
      extending: true
    )
  }

  override open func moveToBeginningOfParagraph(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .paragraph,
      extending: false
    )
  }

  override open func moveToBeginningOfParagraphAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .paragraph,
      extending: true
    )
  }

  override open func moveToEndOfParagraph(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .paragraph,
      extending: false
    )
  }

  override open func moveToEndOfParagraphAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .paragraph,
      extending: true
    )
  }

  override open func moveToBeginningOfDocument(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .document,
      extending: false
    )
  }

  override open func moveToBeginningOfDocumentAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .backward,
      destination: .document,
      extending: true
    )
  }

  override open func moveToEndOfDocument(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .document,
      extending: false
    )
  }

  override open func moveToEndOfDocumentAndModifySelection(_: Any?)
  {
    setTextSelections(
      direction: .forward,
      destination: .document,
      extending: true
    )
  }

  private func setTextSelections(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, extending: Bool)
  {
    guard isSelectable else { return }

    textLayoutManager.textSelections = textLayoutManager.textSelections.compactMap
    { textSelection in
      textLayoutManager.textSelectionNavigation.destinationSelection(
        for: textSelection,
        direction: direction,
        destination: destination,
        extending: extending,
        confined: false
      )
    }

    updateTypingAttributes()
    needsScrollToSelection = true
    needsDisplay = true
  }

  internal func updateTextSelection(
    interactingAt point: CGPoint,
    inContainerAt location: NSTextLocation,
    anchors: [NSTextSelection] = [],
    extending: Bool,
    isDragging: Bool = false,
    visual: Bool = false
  )
  {
    guard isSelectable else { return }

    var modifiers: NSTextSelectionNavigation.Modifier = []
    if extending
    {
      modifiers.insert(.extend)
    }
    if visual
    {
      modifiers.insert(.visual)
    }

    let selections = textLayoutManager.textSelectionNavigation.textSelections(
      interactingAt: point,
      inContainerAt: location,
      anchors: anchors,
      modifiers: modifiers,
      selecting: isDragging,
      bounds: textLayoutManager.usageBoundsForTextContainer
    )

    if !selections.isEmpty
    {
      textLayoutManager.textSelections = selections
    }

    updateTypingAttributes()
    updateSelectionHighlights()
    needsDisplay = true
  }
}

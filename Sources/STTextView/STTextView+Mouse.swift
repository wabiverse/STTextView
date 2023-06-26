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
  override open func mouseDown(with event: NSEvent)
  {
    guard (inputContext?.handleEvent(event) ?? false) == false
    else
    {
      return
    }

    guard isSelectable, event.type == .leftMouseDown
    else
    {
      super.mouseDown(with: event)
      return
    }

    var handled = false
    if event.clickCount == 1
    {
      let point = convert(event.locationInWindow, from: nil)
      if event.modifierFlags.isSuperset(of: [.control, .shift])
      {
        textLayoutManager.appendInsertionPointSelection(interactingAt: point)
        updateTypingAttributes()
        updateSelectionHighlights()
        needsDisplay = true
      }
      else
      {
        updateTextSelection(
          interactingAt: point,
          inContainerAt: textLayoutManager.documentRange.location,
          anchors: event.modifierFlags.contains(.shift) ? textLayoutManager.textSelections : [],
          extending: event.modifierFlags.contains(.shift),
          isDragging: false,
          visual: event.modifierFlags.contains(.option)
        )
      }
      handled = true
    }
    else if event.clickCount == 2
    {
      selectWord(self)
      handled = true
    }
    else if event.clickCount == 3
    {
      selectLine(self)
      handled = true
    }

    if !handled
    {
      super.mouseDown(with: event)
    }
  }

  override open func mouseUp(with event: NSEvent)
  {
    guard (inputContext?.handleEvent(event) ?? false) == false
    else
    {
      return
    }

    mouseDraggingSelectionAnchors = nil
    super.mouseUp(with: event)
  }

  override open func mouseDragged(with event: NSEvent)
  {
    guard (inputContext?.handleEvent(event) ?? false) == false
    else
    {
      return
    }

    if isSelectable, event.type == .leftMouseDragged, !event.deltaY.isZero || !event.deltaX.isZero
    {
      let point = convert(event.locationInWindow, from: nil)

      if mouseDraggingSelectionAnchors == nil
      {
        mouseDraggingSelectionAnchors = textLayoutManager.textSelections
      }

      updateTextSelection(
        interactingAt: point,
        inContainerAt: mouseDraggingSelectionAnchors?.first?.textRanges.first?.location ?? textLayoutManager.documentRange.location,
        anchors: mouseDraggingSelectionAnchors!,
        extending: true,
        isDragging: true,
        visual: event.modifierFlags.contains(.option)
      )

      if autoscroll(with: event)
      {
        // TODO: periodic repeat this event, until don't
      }
    }
    else
    {
      super.mouseDragged(with: event)
    }
  }

  override open func mouseMoved(with event: NSEvent)
  {
    guard (inputContext?.handleEvent(event) ?? false) == false
    else
    {
      return
    }

    super.mouseMoved(with: event)
  }

  override open func menu(for event: NSEvent) -> NSMenu?
  {
    let proposedMenu = super.menu(for: event)

    // Disable context menu when adding an insertion point in mouseDown
    if proposedMenu != nil, event.type == .leftMouseDown, event.modifierFlags.isSuperset(of: [.shift, .control])
    {
      return nil
    }

    let point = convert(event.locationInWindow, from: nil)
    if let delegate,
       let proposedMenu,
       let eventLocation = textLayoutManager.lineFragmentRange(for: point, inContainerAt: textLayoutManager.documentRange.location)?.location,
       let location = textLayoutManager.textSelectionNavigation.textSelections(interactingAt: point, inContainerAt: eventLocation, anchors: [], modifiers: [], selecting: false, bounds: textLayoutManager.usageBoundsForTextContainer).first?.textRanges.first?.location
    {
      return delegate.textView(self, menu: proposedMenu, for: event, at: location)
    }

    return proposedMenu
  }

  override open func rightMouseDown(with event: NSEvent)
  {
    if menu(for: event) != nil
    {
      if textLayoutManager.textSelections.isEmpty
      {
        let point = convert(event.locationInWindow, from: nil)
        updateTextSelection(
          interactingAt: point,
          inContainerAt: textLayoutManager.documentRange.location,
          anchors: event.modifierFlags.contains(.shift) ? textLayoutManager.textSelections : [],
          extending: event.modifierFlags.contains(.shift)
        )

        selectWord(self)
      }
    }

    super.rightMouseDown(with: event)
  }
}

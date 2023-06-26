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
  /// This action method shows or hides the ruler, if the receiver is enclosed in a scroll view.
  @objc public func toggleRuler(_: Any?)
  {
    isRulerVisible.toggle()
  }

  /// A Boolean value that controls whether the scroll view enclosing text views sharing the receiver’s layout manager displays the ruler.
  public var isRulerVisible: Bool
  {
    set
    {
      enclosingScrollView?.rulersVisible = newValue
    }
    get
    {
      enclosingScrollView?.rulersVisible ?? false
    }
  }

  override open func rulerView(_: NSRulerView, willAdd _: NSRulerMarker, atLocation location: CGFloat) -> CGFloat
  {
    location
  }

  override open func rulerView(_ ruler: NSRulerView, shouldAdd _: NSRulerMarker) -> Bool
  {
    isEditable && ((ruler as? STLineNumberRulerView)?.allowsMarkers ?? true)
  }

  override open func rulerView(_ ruler: NSRulerView, didAdd _: NSRulerMarker)
  {
    ruler.invalidateHashMarks()
  }

  override open func rulerView(_ ruler: NSRulerView, didRemove _: NSRulerMarker)
  {
    ruler.invalidateHashMarks()
  }

  override open func rulerView(_: NSRulerView, locationFor point: NSPoint) -> CGFloat
  {
    if let textLayoutFragment = textLayoutManager.textLayoutFragment(for: point)
    {
      var baselineOffset: CGFloat = 0
      if let paragraphStyle = typingAttributes[.paragraphStyle] as? NSParagraphStyle, !paragraphStyle.lineHeightMultiple.isAlmostZero()
      {
        baselineOffset = -(typingLineHeight * (paragraphStyle.lineHeightMultiple - 1.0) / 2)
      }

      let effectiveFrame = textLayoutFragment.layoutFragmentFrame.moved(dy: baselineOffset)
      return effectiveFrame.maxY
    }

    return point.y
  }

  override open func rulerView(_ ruler: NSRulerView, handleMouseDownWith event: NSEvent)
  {
    let point = convert(event.locationInWindow, from: nil)
    guard let textLayoutFragment = textLayoutManager.textLayoutFragment(for: point),
          let textSegmentFrame = textLayoutManager.textSelectionSegmentFrame(in: NSTextRange(location: textLayoutFragment.rangeInElement.location), type: .highlight)?.pixelAligned
    else
    {
      return
    }

    let relativePoint = convert(NSZeroPoint, from: self)
    let selectionFrame = textSegmentFrame.pixelAligned

    let markerLocation = (ruler.markers ?? []).filter
    { marker in
      selectionFrame.maxY.isAlmostEqual(to: marker.markerLocation)
    }

    if markerLocation.isEmpty
    {
      let marker = STRulerMarker(rulerView: ruler, markerLocation: selectionFrame.maxY + relativePoint.y, height: selectionFrame.height)
      marker.isMovable = true
      marker.isRemovable = true

      // For unknown reason an NSRulerView automatically increases the reservedThicknessForMarkers to 2.0
      // Adds 2px in the marker.imageRectInRuler to the left in
      ruler.clientView?.rulerView(ruler, willAdd: marker, atLocation: marker.markerLocation)
      ruler.addMarker(marker)
      ruler.clientView?.rulerView(ruler, didAdd: marker)

      // track not supported until solve tracking visual glithes
      // ruler.trackMarker(marker, withMouseEvent: event)
    }
    else
    {
      markerLocation.forEach
      { marker in
        ruler.removeMarker(marker)
        ruler.clientView?.rulerView(ruler, didRemove: marker)
      }
    }
    ruler.needsDisplay = true
  }
}

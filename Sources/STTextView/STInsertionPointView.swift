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

open class STInsertionPointView: NSView
{
  private var timer: Timer?

  open internal(set) var insertionPointWidth: CGFloat?
  {
    didSet
    {
      if let insertionPointWidth
      {
        frame.size.width = insertionPointWidth
      }
    }
  }

  open internal(set) var insertionPointColor: NSColor = .defaultTextInsertionPoint
  {
    didSet
    {
      layer?.backgroundColor = insertionPointColor.cgColor
    }
  }

  override public required init(frame frameRect: NSRect)
  {
    super.init(frame: frameRect)
    commonInit()
  }

  public required init?(coder: NSCoder)
  {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit()
  {
    wantsLayer = true
    updateGeometry()
  }

  override public var isFlipped: Bool
  {
    #if os(macOS)
      true
    #else
      false
    #endif
  }

  public func updateGeometry()
  {
    if let insertionPointWidth
    {
      frame.size.width = insertionPointWidth
    }
    frame = frame.insetBy(dx: 0, dy: 1).pixelAligned
    layer?.backgroundColor = insertionPointColor.cgColor
    layer?.cornerRadius = 1
  }

  open func blinkStart()
  {
    if timer != nil
    {
      return
    }

    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
    { [weak self] _ in
      guard let self else { return }
      isHidden.toggle()
    }
  }

  open func blinkStop()
  {
    isHidden = false
    timer = nil
  }
}

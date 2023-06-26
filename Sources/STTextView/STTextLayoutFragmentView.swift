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
import CoreGraphics

final class STTextLayoutFragmentView: NSView
{
  private let layoutFragment: NSTextLayoutFragment

  override var isFlipped: Bool
  {
    #if os(macOS)
      true
    #else
      false
    #endif
  }

  init(layoutFragment: NSTextLayoutFragment)
  {
    self.layoutFragment = layoutFragment
    super.init(frame: .zero)
    wantsLayer = true
    needsDisplay = true
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_: NSRect)
  {
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    layoutFragment.draw(at: .zero, in: ctx)
  }
}

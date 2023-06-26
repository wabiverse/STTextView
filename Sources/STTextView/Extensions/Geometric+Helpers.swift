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
import CoreGraphics

extension CGRect
{
  enum Inset
  {
    case left(CGFloat)
    case right(CGFloat)
    case top(CGFloat)
    case bottom(CGFloat)
  }

  func inset(by edgeInsets: NSEdgeInsets) -> CGRect
  {
    var result = self
    result.origin.x += edgeInsets.left
    result.origin.y += edgeInsets.top
    result.size.width -= edgeInsets.left + edgeInsets.right
    result.size.height -= edgeInsets.top + edgeInsets.bottom
    return result
  }

  func inset(_ insets: Inset...) -> CGRect
  {
    var result = self
    for inset in insets
    {
      switch inset
      {
        case let .left(value):
          result = self.inset(by: NSEdgeInsets(top: 0, left: value, bottom: 0, right: 0))
        case let .right(value):
          result = self.inset(by: NSEdgeInsets(top: 0, left: 0, bottom: 0, right: value))
        case let .top(value):
          result = self.inset(by: NSEdgeInsets(top: value, left: 0, bottom: 0, right: 0))
        case let .bottom(value):
          result = self.inset(by: NSEdgeInsets(top: 0, left: 0, bottom: value, right: 0))
      }
    }
    return result
  }

  func inset(dx: CGFloat) -> CGRect
  {
    insetBy(dx: dx, dy: 0)
  }

  func inset(dy: CGFloat) -> CGRect
  {
    insetBy(dx: 0, dy: dy)
  }

  func scale(_ scale: CGSize) -> CGRect
  {
    applying(.init(scaleX: scale.width, y: scale.height))
  }

  func margin(_ margin: CGSize) -> CGRect
  {
    insetBy(dx: -margin.width / 2, dy: -margin.height / 2)
  }

  func moved(dx: CGFloat = 0, dy: CGFloat = 0) -> CGRect
  {
    applying(.init(translationX: dx, y: dy))
  }

  func moved(by point: CGPoint) -> CGRect
  {
    applying(.init(translationX: point.x, y: point.y))
  }

  func margin(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> CGRect
  {
    inset(by: .init(top: -top, left: -left, bottom: -bottom, right: -right))
  }
}

extension CGPoint
{
  func moved(dx: CGFloat, dy: CGFloat) -> CGPoint
  {
    applying(.init(translationX: dx, y: dy))
  }

  func moved(by point: CGPoint) -> CGPoint
  {
    applying(.init(translationX: point.x, y: point.y))
  }
}

extension CGRect
{
  func isAlmostEqual(to other: CGRect) -> Bool
  {
    origin.isAlmostEqual(to: other.origin) && size.isAlmostEqual(to: other.size)
  }
}

extension CGPoint
{
  func isAlmostEqual(to other: CGPoint) -> Bool
  {
    x.isAlmostEqual(to: other.x) && y.isAlmostEqual(to: other.y)
  }
}

extension CGSize
{
  func isAlmostEqual(to other: CGSize) -> Bool
  {
    width.isAlmostEqual(to: other.width) && height.isAlmostEqual(to: other.height)
  }
}

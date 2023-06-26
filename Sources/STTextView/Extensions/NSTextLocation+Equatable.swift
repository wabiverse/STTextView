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

extension NSTextLocation
{
  static func == (lhs: Self, rhs: Self) -> Bool
  {
    lhs.compare(rhs) == .orderedSame
  }

  static func != (lhs: Self, rhs: Self) -> Bool
  {
    lhs.compare(rhs) != .orderedSame
  }

  static func < (lhs: Self, rhs: Self) -> Bool
  {
    lhs.compare(rhs) == .orderedAscending
  }

  static func <= (lhs: Self, rhs: Self) -> Bool
  {
    lhs == rhs || lhs < rhs
  }

  static func > (lhs: Self, rhs: Self) -> Bool
  {
    lhs.compare(rhs) == .orderedDescending
  }

  static func >= (lhs: Self, rhs: Self) -> Bool
  {
    lhs == rhs || lhs > rhs
  }
}

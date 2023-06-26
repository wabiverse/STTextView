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

extension NSRange
{
  static let notFound = NSRange(location: NSNotFound, length: 0)

  var isEmpty: Bool
  {
    length == 0
  }

  init(_ textRange: NSTextRange, in textContentManager: NSTextContentManager)
  {
    let offset = textContentManager.offset(from: textContentManager.documentRange.location, to: textRange.location)
    let length = textContentManager.offset(from: textRange.location, to: textRange.endLocation)
    self.init(location: offset, length: length)
  }

  init(_ textLocation: NSTextLocation, in textContentManager: NSTextContentManager)
  {
    let offset = textContentManager.offset(from: textContentManager.documentRange.location, to: textLocation)
    self.init(location: offset, length: 0)
  }

  var nsValue: NSValue
  {
    NSValue(range: self)
  }
}

extension NSTextRange
{
  convenience init?(_ nsRange: NSRange, in textContentManager: NSTextContentManager)
  {
    guard let start = textContentManager.location(textContentManager.documentRange.location, offsetBy: nsRange.location)
    else
    {
      return nil
    }
    let end = textContentManager.location(start, offsetBy: nsRange.length)
    self.init(location: start, end: end)
  }

  func length(in textContentManager: NSTextContentManager) -> Int
  {
    textContentManager.offset(from: location, to: endLocation)
  }
}

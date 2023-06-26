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
  override open func isAccessibilityElement() -> Bool
  {
    true
  }

  override open func isAccessibilityEnabled() -> Bool
  {
    isEditable || isSelectable
  }

  override open func accessibilityRole() -> NSAccessibility.Role?
  {
    .textArea
  }

  override open func accessibilityLabel() -> String?
  {
    NSLocalizedString("Text Editor", comment: "")
  }

  override open func accessibilityValue() -> Any?
  {
    string
  }

  override open func setAccessibilityValue(_ accessibilityValue: Any?)
  {
    guard let string = accessibilityValue as? String
    else
    {
      return
    }

    self.string = string
  }

  override open func accessibilityAttributedString(for range: NSRange) -> NSAttributedString?
  {
    attributedSubstring(forProposedRange: range, actualRange: nil)
  }

  override open func accessibilityVisibleCharacterRange() -> NSRange
  {
    if let viewportRange = textLayoutManager.textViewportLayoutController.viewportRange
    {
      return NSRange(viewportRange, in: textContentManager)
    }

    return NSRange()
  }

  override open func accessibilityString(for range: NSRange) -> String?
  {
    attributedSubstring(forProposedRange: range, actualRange: nil)?.string
  }

  override open func accessibilityNumberOfCharacters() -> Int
  {
    string.count
  }

  override open func accessibilitySelectedText() -> String?
  {
    textLayoutManager.textSelectionsString()
  }

  override open func accessibilitySelectedTextRange() -> NSRange
  {
    selectedRange()
  }

  override open func setAccessibilitySelectedTextRange(_ accessibilitySelectedTextRange: NSRange)
  {
    if let textRange = NSTextRange(accessibilitySelectedTextRange, in: textContentManager)
    {
      setSelectedTextRange(textRange)
    }
    else
    {
      assertionFailure()
    }
  }
}

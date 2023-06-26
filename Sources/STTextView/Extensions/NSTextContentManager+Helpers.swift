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

extension NSTextContentManager
{
  var documentString: String
  {
    var result = ""
    result.reserveCapacity(1024 * 4)

    enumerateTextElements(from: nil)
    { textElement in
      if let textParagraph = textElement as? NSTextParagraph
      {
        result += textParagraph.attributedString.string
      }

      return true
    }
    return result
  }

  /// Attributes at location
  func attributes(at location: NSTextLocation) -> [NSAttributedString.Key: Any]
  {
    guard !documentRange.isEmpty
    else
    {
      return [:]
    }

    let effectiveLocation: NSTextLocation
    if location == documentRange.location
    {
      effectiveLocation = location
    }
    else if location == documentRange.endLocation
    {
      effectiveLocation = self.location(location, offsetBy: -1) ?? location
    }
    else
    {
      effectiveLocation = location
    }

    // requires non-empty range
    return attributedString(
      in: NSTextRange(
        location: effectiveLocation,
        end: self.location(effectiveLocation, offsetBy: 1)
      )
    )?.attributes(
      at: 0,
      effectiveRange: nil
    ) ?? [:]
  }

  /// Attributed string for the range
  /// - Parameter range: Text range, or nil for the whole document.
  /// - Returns: Attributed string, or nil.
  func attributedString(in range: NSTextRange?) -> NSAttributedString?
  {
    if let range
    {
      precondition(range.isEmpty == false)
    }

    if range != nil, range?.isEmpty == true
    {
      return nil
    }

    let result = NSMutableAttributedString()
    result.beginEditing()
    enumerateTextElements(from: range?.location)
    { textElement in
      if let range,
         let textParagraph = textElement as? NSTextParagraph,
         let elementRange = textElement.elementRange,
         let textContentManager = textElement.textContentManager
      {
        var shouldStop = false
        var needAdjustment = false
        var constrainedElementRange = elementRange
        if elementRange.contains(range.location)
        {
          // start location
          constrainedElementRange = NSTextRange(location: range.location, end: constrainedElementRange.endLocation)!
          needAdjustment = true
        }

        if elementRange.contains(range.endLocation)
        {
          // end location
          constrainedElementRange = NSTextRange(location: constrainedElementRange.location, end: range.endLocation)!
          needAdjustment = true
          shouldStop = true
        }

        if needAdjustment
        {
          if let constrainedRangeInDocument = NSTextRange(location: constrainedElementRange.location, end: constrainedElementRange.endLocation)
          {
            let constrainedRangeInDocumentLength = constrainedRangeInDocument.length(in: textContentManager)
            let leadingOffset = textContentManager.offset(from: elementRange.location, to: constrainedElementRange.location)

            // translate contentRangeInDocument from document namespace to textElement.attributedString namespace
            let nsRangeInDocumentDocument = NSRange(
              location: leadingOffset,
              length: constrainedRangeInDocumentLength
            )

            result.append(
              textParagraph.attributedString.attributedSubstring(from: nsRangeInDocumentDocument)
            )
          }
        }
        else
        {
          result.append(
            textParagraph.attributedString
          )
        }

        if shouldStop
        {
          return false
        }
      }
      else if range == nil, let textParagraph = textElement as? NSTextParagraph
      {
        result.append(
          textParagraph.attributedString
        )
      }

      return true
    }

    result.endEditing()
    if result.length == 0
    {
      return nil
    }

    return result
  }
}

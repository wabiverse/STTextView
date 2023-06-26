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

public extension NSTextLayoutManager
{
  internal func substring(for range: NSTextRange) -> String?
  {
    guard !range.isEmpty else { return nil }
    var output = String()
    output.reserveCapacity(128)
    enumerateSubstrings(from: range.location, options: .byComposedCharacterSequences, using: { substring, textRange, _, stop in
      if let substring
      {
        output += substring
      }

      if textRange.endLocation >= range.endLocation
      {
        stop.pointee = true
      }
    })
    return output
  }

  internal func textSelectionsString() -> String?
  {
    textSelections.flatMap(\.textRanges).reduce(nil)
    { partialResult, textRange in
      guard let substring = substring(for: textRange)
      else
      {
        return partialResult
      }

      var partialResult = partialResult
      if partialResult == nil
      {
        partialResult = ""
      }

      return partialResult?.appending(substring)
    }
  }

  internal func textSelectionsAttributedString() -> NSAttributedString?
  {
    let attributedString = textSelections.flatMap(\.textRanges).reduce(NSMutableAttributedString())
    { partialResult, range in
      if let attributedString = textContentManager?.attributedString(in: range)
      {
        partialResult.append(attributedString)
      }
      return partialResult
    }

    if attributedString.length == 0
    {
      return nil
    }
    return attributedString
  }

  ///  A text segment is both logically and visually contiguous portion of the text content inside a line fragment.
  func textSelectionSegmentFrame(at location: NSTextLocation, type: NSTextLayoutManager.SegmentType) -> CGRect?
  {
    textSelectionSegmentFrame(in: NSTextRange(location: location), type: type)
  }

  func textSelectionSegmentFrame(in textRange: NSTextRange, type: NSTextLayoutManager.SegmentType) -> CGRect?
  {
    var result: CGRect?
    // .upstreamAffinity: When specified, the segment is placed based on the upstream affinity for an empty range.
    //
    // In the context of text editing, upstream affinity means that the selection is biased towards the preceding or earlier portion of the text,
    // while downstream affinity means that the selection is biased towards the following or later portion of the text. The affinity helps determine
    // the behavior of the text selection when the text is modified or manipulated.
    enumerateTextSegments(in: textRange, type: type, options: [.rangeNotRequired, .upstreamAffinity])
    { _, textSegmentFrame, _, _ -> Bool in
      result = textSegmentFrame
      return true
    }
    return result
  }

  func textLineFragment(at location: NSTextLocation) -> NSTextLineFragment?
  {
    textLayoutFragment(for: location)?.textLineFragment(at: location)
  }

  func textLineFragment(at point: CGPoint) -> NSTextLineFragment?
  {
    textLayoutFragment(for: point)?.textLineFragment(at: point)
  }
}

public extension NSTextLayoutManager
{
  /// Returns a location of text produced by a tap or click at the point you specify.
  /// - Parameters:
  ///   - point: A CGPoint that represents the location of the tap or click.
  ///   - containerLocation: A NSTextLocation that describes the contasiner location.
  /// - Returns: A location
  func location(interactingAt point: CGPoint, inContainerAt containerLocation: NSTextLocation) -> NSTextLocation?
  {
    guard let lineFragmentRange = lineFragmentRange(for: point, inContainerAt: containerLocation)
    else
    {
      return nil
    }

    var distance = CGFloat.infinity
    var caretLocation: NSTextLocation?
    enumerateCaretOffsetsInLineFragment(at: lineFragmentRange.location)
    { caretOffset, location, leadingEdge, stop in
      let localDistance = abs(caretOffset - point.x)
      if leadingEdge
      {
        if localDistance < distance
        {
          distance = localDistance
          caretLocation = location
        }
        else if localDistance > distance
        {
          stop.pointee = true
        }
      }
    }

    return caretLocation
  }
}

extension NSTextLayoutFragment
{
  @available(*, deprecated, message: "Unused")
  var hasExtraLineFragment: Bool
  {
    textLineFragments.last?.isExtraLineFragment ?? false
  }

  func textLineFragment(at location: NSTextLocation, in textContentManager: NSTextContentManager? = nil) -> NSTextLineFragment?
  {
    guard let textContentManager = textContentManager ?? textLayoutManager?.textContentManager
    else
    {
      assertionFailure()
      return nil
    }

    let searchNSLocation = NSRange(location, in: textContentManager).location
    let fragmentLocation = NSRange(rangeInElement.location, in: textContentManager).location
    return textLineFragments.first
    { lineFragment in
      let absoluteLineRange = NSRange(location: lineFragment.characterRange.location + fragmentLocation, length: lineFragment.characterRange.length)
      return absoluteLineRange.contains(searchNSLocation)
    }
  }

  func textLineFragment(at location: CGPoint, in _: NSTextContentManager? = nil) -> NSTextLineFragment?
  {
    textLineFragments.first
    { lineFragment in
      CGRect(origin: layoutFragmentFrame.origin, size: lineFragment.typographicBounds.size).contains(location)
    }
  }
}

extension NSTextLineFragment
{
  var isExtraLineFragment: Bool
  {
    // textLineFragment.characterRange.isEmpty the extra line fragment at the end of a document.
    characterRange.isEmpty
  }
}

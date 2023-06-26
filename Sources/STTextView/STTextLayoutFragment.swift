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

final class STTextLayoutFragment: NSTextLayoutFragment
{
  private let paragraphStyle: NSParagraphStyle

  init(textElement: NSTextElement, range rangeInElement: NSTextRange?, paragraphStyle: NSParagraphStyle)
  {
    self.paragraphStyle = paragraphStyle
    super.init(textElement: textElement, range: rangeInElement)
  }

  required init?(coder: NSCoder)
  {
    paragraphStyle = NSParagraphStyle.default
    super.init(coder: coder)
  }

  override func draw(at point: CGPoint, in context: CGContext)
  {
    // Layout fragment draw text at the bottom (after apply baselineOffset) but ignore the paragraph line height
    // This is a workaround/patch to position text nicely in the line
    //
    // Center vertically after applying lineHeightMultiple value
    // super.draw(at: point.moved(dx: 0, dy: offset), in: context)
    for lineFragment in textLineFragments
    {
      // Determine paragraph style. Either from the fragment string or default for the text view
      // the ExtraLineFragment doesn't have information about typing attributes hence layout manager uses a default values - not from text view
      let paragraphStyle: NSParagraphStyle
      if !lineFragment.isExtraLineFragment,
         let lineParagraphStyle = lineFragment.attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
      {
        paragraphStyle = lineParagraphStyle
      }
      else
      {
        paragraphStyle = self.paragraphStyle
      }

      if !paragraphStyle.lineHeightMultiple.isAlmostZero()
      {
        let offset = -(lineFragment.typographicBounds.height * (paragraphStyle.lineHeightMultiple - 1.0) / 2)
        lineFragment.draw(at: point.moved(dx: lineFragment.typographicBounds.origin.x, dy: lineFragment.typographicBounds.origin.y + offset), in: context)
      }
      else
      {
        lineFragment.draw(at: lineFragment.typographicBounds.origin, in: context)
      }
    }
  }
}

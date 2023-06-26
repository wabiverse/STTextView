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

import CoreGraphics
import Foundation

extension CGRect
{
  var pixelAligned: CGRect
  {
    // https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/APIs/APIs.html#//apple_ref/doc/uid/TP40012302-CH5-SW9
    // NSIntegralRectWithOptions(self, [.alignMinXOutward, .alignMinYOutward, .alignWidthOutward, .alignMaxYOutward])
    #if os(macOS)
      NSIntegralRectWithOptions(self, .alignAllEdgesNearest)
    #else
      // NSIntegralRectWithOptions is not available in ObjC Foundation on iOS
      // "self.integral" is not the same, but for now it has to be enough
      // https://twitter.com/krzyzanowskim/status/1512451888515629063
      integral
    #endif
  }
}

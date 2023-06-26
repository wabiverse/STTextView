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

extension STTextView: NSTextViewportLayoutControllerDelegate
{
  public func viewportBounds(for _: NSTextViewportLayoutController) -> CGRect
  {
    let overdrawRect = preparedContentRect
    var minY: CGFloat = 0
    var maxY: CGFloat = 0

    if overdrawRect.intersects(visibleRect)
    {
      // Use preparedContentRect for vertical overdraw and ensure visibleRect is included at the minimum,
      // the width is always bounds width for proper line wrapping.
      minY = min(overdrawRect.minY, max(visibleRect.minY, bounds.minY))
      maxY = max(overdrawRect.maxY, visibleRect.maxY)
    }
    else
    {
      // We use visible rect directly if preparedContentRect does not intersect.
      // This can happen if overdraw has not caught up with scrolling yet, such as before the first layout.
      minY = visibleRect.minY
      maxY = visibleRect.maxY
    }
    return CGRect(x: bounds.minX, y: minY, width: bounds.width, height: maxY - minY)
  }

  public func textViewportLayoutControllerWillLayout(_: NSTextViewportLayoutController)
  {
    // TODO: update difference, not all layers
    contentView.subviews.removeAll()
  }

  public func textViewportLayoutControllerDidLayout(_: NSTextViewportLayoutController)
  {
    updateFrameSizeIfNeeded()
    updateSelectionHighlights()
    adjustViewportOffsetIfNeeded()
    scrollView?.verticalRulerView?.invalidateHashMarks()
  }

  public func textViewportLayoutController(_: NSTextViewportLayoutController, configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment)
  {
    let fragmentView = fragmentViewMap.object(forKey: textLayoutFragment) ?? STTextLayoutFragmentView(layoutFragment: textLayoutFragment)
    // Adjust position
    let oldFrame = fragmentView.frame
    fragmentView.frame = textLayoutFragment.layoutFragmentFrame.pixelAligned
    if !oldFrame.isAlmostEqual(to: fragmentView.frame)
    {
      fragmentView.needsLayout = true
      fragmentView.needsDisplay = true
    }

    contentView.addSubview(fragmentView)
    fragmentViewMap.setObject(fragmentView, forKey: textLayoutFragment)
  }

  internal func adjustViewportOffsetIfNeeded()
  {
    guard let scrollView else { return }
    let clipView = scrollView.contentView

    func adjustViewportOffset()
    {
      let viewportLayoutController = textLayoutManager.textViewportLayoutController
      var layoutYPoint: CGFloat = 0
      textLayoutManager.enumerateTextLayoutFragments(from: viewportLayoutController.viewportRange!.location, options: [.reverse, .ensuresLayout])
      { layoutFragment in
        layoutYPoint = layoutFragment.layoutFragmentFrame.origin.y
        return true // return false?
      }

      if !layoutYPoint.isZero
      {
        let adjustmentDelta = bounds.minY - layoutYPoint
        viewportLayoutController.adjustViewport(byVerticalOffset: adjustmentDelta)
        scroll(CGPoint(x: clipView.bounds.minX, y: clipView.bounds.minY + adjustmentDelta))
        scrollView.reflectScrolledClipView(scrollView.contentView)
      }
    }

    let viewportLayoutController = textLayoutManager.textViewportLayoutController
    let contentOffset = clipView.bounds.minY
    if contentOffset < clipView.bounds.height, let viewportRange = viewportLayoutController.viewportRange,
       viewportRange.location > textLayoutManager.documentRange.location
    {
      // Nearing top, see if we need to adjust and make room above.
      adjustViewportOffset()
    }
    else if let viewportRange = viewportLayoutController.viewportRange, viewportRange.location == textLayoutManager.documentRange.location
    {
      // At top, see if we need to adjust and reduce space above.
      adjustViewportOffset()
    }
  }
}

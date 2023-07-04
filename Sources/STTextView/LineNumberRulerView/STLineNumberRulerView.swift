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

/// A ruler view to display line numbers to the side of the text view.
open class STLineNumberRulerView: NSRulerView
{
  private var textView: STTextView?
  {
    clientView as? STTextView
  }

  /// The font used to draw line numbers.
  ///
  /// Initialized with a textView font value and does not update automatically when
  /// text view font changes.
  @Invalidating(.display)
  open var font: NSFont = .init(descriptor: NSFont.monospacedDigitSystemFont(ofSize: 0, weight: .regular).fontDescriptor.withSymbolicTraits(.condensed), size: 0) ?? NSFont.monospacedSystemFont(ofSize: 0, weight: .regular)

  /// The insets of the ruler view.
  @Invalidating(.display)
  open var rulerInsets: STRulerInsets = .init(leading: 6.0, trailing: 6.0)

  /// The text color of the line numbers.
  @Invalidating(.display)
  open var textColor: NSColor = .secondaryLabelColor

  /// A Boolean indicating whether to draw a separator or not.
  @Invalidating(.display)
  open var drawSeparator: Bool = true

  /// The background color of the ruler view.
  @Invalidating(.display)
  open var backgroundColor: NSColor = .controlBackgroundColor

  @Invalidating(.display)
  open var highlightSelectedLine: Bool = false

  /// A Boolean value that indicates whether the receiver draws its background.
  @Invalidating(.display)
  open var drawsBackground: Bool = true

  /// The background color of the highlighted line.
  @Invalidating(.display)
  open var selectedLineHighlightColor: NSColor = .selectedTextBackgroundColor.withAlphaComponent(0.25)

  /// The text color of the highligted line numbers.
  @Invalidating(.display)
  open var selectedLineTextColor: NSColor? = nil

  /// The color of the separator.
  ///
  /// Needs ``drawSeparator`` to be set to `true`.
  @Invalidating(.display)
  open var separatorColor: NSColor = .separatorColor

  /// The bottom baseline offset of each line number.
  ///
  /// Use this to offset the line number when the line height is not the default of the used font.
  @Invalidating(.display)
  open var baselineOffset: CGFloat = 0

  /// Allows to set markers. Disabled by default.
  @Invalidating(.layout)
  open var allowsMarkers: Bool = false

  override public var reservedThicknessForMarkers: CGFloat
  {
    get
    {
      // Never called anyway
      super.reservedThicknessForMarkers
    }

    set
    {
      // Sadly something from addMarker adds 2px and there's no easy way to fix it
      // super.reservedThicknessForMarkers = newValue
    }
  }

  struct Line
  {
    let number: Int
    let textPosition: CGPoint
    let textRange: NSTextRange
    let layoutFragmentFrame: CGRect
    let ctLine: CTLine
  }

  private var lines: [Line] = []

  public required init(textView: STTextView, scrollView: NSScrollView? = nil)
  {
    super.init(scrollView: scrollView ?? textView.enclosingScrollView, orientation: .verticalRuler)

    if let textViewFont = textView.font
    {
      font = adjustFont(textViewFont)
    }

    highlightSelectedLine = textView.highlightSelectedLine
    selectedLineHighlightColor = textView.selectedLineHighlightColor
    selectedLineTextColor = textView.textColor

    clientView = textView

    NotificationCenter.default.addObserver(forName: STTextView.didChangeSelectionNotification, object: textView.textLayoutManager, queue: .main)
    { [weak self] _ in
      self?.invalidateHashMarks()
    }
  }

  @available(*, unavailable)
  public required init(coder _: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }

  override open func invalidateHashMarks()
  {
    invalidateLineNumbers()
    needsDisplay = true
  }

  override open func addMarker(_ marker: NSRulerMarker)
  {
    guard allowsMarkers
    else
    {
      return
    }

    guard clientView != nil
    else
    {
      assertionFailure("receiver has no client view")
      return
    }

    if markers == nil
    {
      markers = [marker]
    }
    else
    {
      markers?.append(marker)
    }
    enclosingScrollView?.tile()
  }

  private func invalidateLineNumbers()
  {
    guard let textLayoutManager = textView?.textLayoutManager,
          let textContentManager = textLayoutManager.textContentManager,
          let viewportRange = textLayoutManager.textViewportLayoutController.viewportRange
    else
    {
      return
    }

    let lineTextAttributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: textColor.cgColor,
    ]

    let selectedLineTextAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: (selectedLineTextColor ?? textColor).cgColor,
    ]

    lines.removeAll(keepingCapacity: true)

    if textLayoutManager.documentRange.isEmpty
    {
      // For empty document, layout the extra line as if it has text in it
      // the ExtraLineFragment doesn't have information about typing attributes hence layout manager uses a default values - not from text view
      textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.location, options: [.ensuresLayout, .ensuresExtraLineFragment])
      { layoutFragment in
        for lineFragment in layoutFragment.textLineFragments where lineFragment.isExtraLineFragment || layoutFragment.textLineFragments.first == lineFragment
        {
          var baselineOffset: CGFloat = 0
          if let paragraphStyle = textView?.typingAttributes[.paragraphStyle] as? NSParagraphStyle, !paragraphStyle.lineHeightMultiple.isAlmostZero()
          {
            baselineOffset = -(textView!.typingLineHeight * (paragraphStyle.lineHeightMultiple - 1.0) / 2)
          }

          let lineNumber = lines.count + 1
          let attributedString = NSAttributedString(string: "\(lineNumber)", attributes: lineTextAttributes)
          let ctLine = CTLineCreateWithAttributedString(attributedString)

          var ascent: CGFloat = 0
          var descent: CGFloat = 0
          var leading: CGFloat = 0
          CTLineGetTypographicBounds(ctLine, &ascent, &descent, &leading)
          let locationForFirstCharacter = CGPoint(x: 0, y: ascent + descent + leading)

          lines.append(
            Line(
              number: lineNumber,
              textPosition: layoutFragment.layoutFragmentFrame.origin.moved(dx: 0, dy: locationForFirstCharacter.y + baselineOffset),
              textRange: layoutFragment.rangeInElement,
              layoutFragmentFrame: layoutFragment.layoutFragmentFrame,
              ctLine: ctLine
            )
          )
        }

        return false
      }
    }
    else
    {
      let textElements = textContentManager.textElements(for: NSTextRange(location: textLayoutManager.documentRange.location, end: viewportRange.location)!)
      let startLineIndex = textElements.count
      let firstFragmentLayout = textLayoutManager.textLayoutFragment(for: viewportRange.location)!

      textLayoutManager.enumerateTextLayoutFragments(from: firstFragmentLayout.rangeInElement.location, options: [.ensuresLayout, .ensuresExtraLineFragment])
      { layoutFragment in
        let shouldContinue = layoutFragment.rangeInElement.location <= viewportRange.endLocation
        if !shouldContinue
        {
          return false
        }

        for lineFragment in layoutFragment.textLineFragments where lineFragment.isExtraLineFragment || layoutFragment.textLineFragments.first == lineFragment
        {
          var baselineOffset: CGFloat = 0

          if let paragraphStyle = lineFragment.attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle, !paragraphStyle.lineHeightMultiple.isAlmostZero()
          {
            baselineOffset = -(lineFragment.typographicBounds.height * (paragraphStyle.lineHeightMultiple - 1.0) / 2)
          }

          let lineNumber = startLineIndex + lines.count + 1
          let locationForFirstCharacter = lineFragment.locationForCharacter(at: 0)

          var effectiveAttributes = lineTextAttributes
          if highlightSelectedLine, !selectedLineTextAttributes.isEmpty
          {
            if textLayoutManager.textSelections.flatMap(\.textRanges).contains(where: { layoutFragment.rangeInElement.intersects($0) || layoutFragment.rangeInElement.contains($0) })
            {
              effectiveAttributes.merge(selectedLineTextAttributes, uniquingKeysWith: { _, new in new })
            }
          }

          let attributedString = NSAttributedString(string: "\(lineNumber)", attributes: effectiveAttributes)
          let ctLine = CTLineCreateWithAttributedString(attributedString)

          lines.append(
            Line(
              number: lineNumber,
              textPosition: layoutFragment.layoutFragmentFrame.origin.moved(dx: 0, dy: locationForFirstCharacter.y + baselineOffset),
              textRange: layoutFragment.rangeInElement,
              layoutFragmentFrame: layoutFragment.layoutFragmentFrame,
              ctLine: ctLine
            )
          )
        }

        return shouldContinue
      }
    }

    // Adjust ruleThickness based on last (longest) value
    let prevThickness = ruleThickness
    var calculatedThickness: CGFloat = ruleThickness
    if let lastLine = lines.last
    {
      let ctLineWidth = ceil(CTLineGetTypographicBounds(lastLine.ctLine, nil, nil, nil))
      if calculatedThickness < (ctLineWidth + (rulerInsets.leading + rulerInsets.trailing))
      {
        calculatedThickness = max(calculatedThickness, ctLineWidth + (rulerInsets.leading + rulerInsets.trailing))
      }
    }

    let delta = prevThickness - calculatedThickness
    if !delta.isZero
    {
      ruleThickness = calculatedThickness
      if let scrollView
      {
        let clipView = scrollView.contentView
        scrollView.contentView.bounds.origin.x = -(clipView.contentInsets.left + clipView.contentInsets.right)
        scrollView.reflectScrolledClipView(clipView)

        invalidateMarkersRect()
      }
    }

    // align to right
    lines = lines.map
    {
      let ctLineWidth = ceil(CTLineGetTypographicBounds($0.ctLine, nil, nil, nil))

      return Line(
        number: $0.number,
        textPosition: $0.textPosition.moved(dx: requiredThickness - (ctLineWidth + rulerInsets.trailing), dy: -baselineOffset),
        textRange: $0.textRange,
        layoutFragmentFrame: $0.layoutFragmentFrame,
        ctLine: $0.ctLine
      )
    }
  }

  private func invalidateMarkersRect()
  {
    guard let markers, !markers.isEmpty
    else
    {
      return
    }

    for marker in markers
    {
      (marker as? STRulerMarker)?.size.width = ruleThickness
    }
  }

  override open func drawHashMarksAndLabels(in _: NSRect)
  {
    //
  }

  open func drawBackground(in _: NSRect)
  {
    guard drawsBackground, let context = NSGraphicsContext.current?.cgContext
    else
    {
      return
    }

    context.saveGState()
    context.setFillColor(backgroundColor.cgColor)
    context.fill(bounds)
    context.restoreGState()
  }

  private func drawHighlightedRuler(line: Line, at relativePoint: NSPoint, in _: NSRect)
  {
    guard let context = NSGraphicsContext.current?.cgContext
    else
    {
      return
    }

    context.saveGState()
    context.setFillColor(selectedLineHighlightColor.cgColor)

    let fillOrigin: CGPoint
    if #available(macOS 14, *)
    {
      // TODO: macOS 14 adds leading space. Investigate whether it's really ruler inset or something else
      fillOrigin = line.layoutFragmentFrame.moved(dx: -rulerInsets.leading, dy: relativePoint.y).origin
    }
    else
    {
      fillOrigin = line.layoutFragmentFrame.moved(dx: 0, dy: relativePoint.y).origin
    }
    let fillRect = CGRect(
      origin: fillOrigin,
      size: CGSize(
        width: bounds.width,
        height: line.layoutFragmentFrame.height
      )
    )
    context.fill(fillRect)
    context.restoreGState()
  }

  override open func draw(_ dirtyRect: NSRect)
  {
    guard let context = NSGraphicsContext.current?.cgContext, let textView else { return }

    drawBackground(in: dirtyRect)
    drawHashMarksAndLabels(in: dirtyRect)

    if markers?.isEmpty == false
    {
      drawMarkers(in: dirtyRect)
    }

    let relativePoint = convert(NSZeroPoint, from: textView)
    context.saveGState()

    if drawSeparator
    {
      context.setLineWidth(1)
      context.setStrokeColor(separatorColor.cgColor)
      context.addLines(between: [CGPoint(x: requiredThickness - 0.5, y: 0), CGPoint(x: requiredThickness - 0.5, y: bounds.maxY)])
      context.strokePath()
    }

    context.textMatrix = CGAffineTransform(scaleX: 1, y: isFlipped ? -1 : 1)

    for line in lines where dirtyRect.inset(dy: -font.pointSize).contains(line.textPosition.moved(dx: 0, dy: relativePoint.y))
    {
      // Draw a background rectangle to highlight the selected ruler line
      if highlightSelectedLine,
         // don't highlight when there's selection
         textView.textLayoutManager.insertionPointSelections.flatMap(\.textRanges).allSatisfy(\.isEmpty),
         textView.textLayoutManager.insertionPointSelections.flatMap(\.textRanges).contains(where: { line.textRange.intersects($0) || line.textRange.contains($0) })
      {
        drawHighlightedRuler(line: line, at: relativePoint, in: dirtyRect)
      }

      context.textPosition = line.textPosition.moved(dx: 0, dy: relativePoint.y)
      CTLineDraw(line.ctLine, context)
    }

    context.restoreGState()
  }
}

private extension STLineNumberRulerView
{
  func adjustFont(_ font: NSFont) -> NSFont
  {
    // https://useyourloaf.com/blog/ios-9-proportional-numbers/
    // https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html
    let features: [[NSFontDescriptor.FeatureKey: Int]] = [
      [
        .typeIdentifier: kTextSpacingType,
        .selectorIdentifier: kMonospacedTextSelector,
      ],
      [
        .typeIdentifier: kNumberSpacingType,
        .selectorIdentifier: kMonospacedNumbersSelector,
      ],
      [
        .typeIdentifier: kNumberCaseType,
        .selectorIdentifier: kUpperCaseNumbersSelector,
      ],
      [
        .typeIdentifier: kStylisticAlternativesType,
        .selectorIdentifier: kStylisticAltOneOnSelector,
      ],
      [
        .typeIdentifier: kStylisticAlternativesType,
        .selectorIdentifier: kStylisticAltTwoOnSelector,
      ],
      [
        .typeIdentifier: kTypographicExtrasType,
        .selectorIdentifier: kSlashedZeroOnSelector,
      ],
    ]

    let adjustedFont = NSFont(descriptor: font.fontDescriptor.addingAttributes([.featureSettings: features]), size: 0)
    return adjustedFont ?? font
  }
}

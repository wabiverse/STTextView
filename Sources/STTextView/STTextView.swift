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

/// A TextKit2 text view without NSTextView baggage
open class STTextView: NSView, NSTextInput, NSTextContent
{
  /// Posted before an object performs any operation that changes characters or formatting attributes.
  public static let textWillChangeNotification = NSNotification.Name("NSTextWillChangeNotification")

  /// Posted after an object performs any operation that changes characters or formatting attributes.
  public static let textDidChangeNotification = NSText.didChangeNotification

  /// Posted when the selected range of characters changes.
  public static let didChangeSelectionNotification = NSTextView.didChangeSelectionNotification

  /// Returns the type of layer used by the receiver.
  open var insertionPointViewClass = STInsertionPointView.self

  /// A Boolean value that controls whether the text view allows the user to edit text.
  @Invalidating(.insertionPoint)
  @objc open dynamic var isEditable: Bool = true
  {
    didSet
    {
      isSelectable = isEditable
    }
  }

  /// A Boolean value that controls whether the text views allows the user to select text.
  @Invalidating(.insertionPoint, .cursorRects)
  @objc open dynamic var isSelectable: Bool = true

  @objc public let isRichText: Bool = true
  @objc public let isFieldEditor: Bool = false
  @objc public let importsGraphics: Bool = false

  /// A Boolean value that determines whether the text view should draw its insertion point.
  open var shouldDrawInsertionPoint: Bool
  {
    if !isFirstResponder
    {
      return false
    }

    if !isEditable
    {
      return false
    }

    if let window, window.isKeyWindow, window.firstResponder == self
    {
      return true
    }

    return false
  }

  /// The color of the insertion point.
  @Invalidating(.display, .insertionPoint)
  @objc open dynamic var insertionPointColor: NSColor = .defaultTextInsertionPoint

  /// The width of the insertion point.
  @Invalidating(.display, .insertionPoint)
  @objc open dynamic var insertionPointWidth: CGFloat = 2.0

  /// The font of the text.
  ///
  /// This property applies to the entire text string.
  /// Assigning a new value to this property causes the new font to be applied to the entire contents of the text view.
  @objc open dynamic var font: NSFont?
  {
    get
    {
      // if not empty, return a font at location 0
      if !textContentManager.documentRange.isEmpty
      {
        let location = textContentManager.documentRange.location
        let endLocation = textContentManager.location(location, offsetBy: 1)
        return textContentManager.attributedString(in: NSTextRange(location: location, end: endLocation))?.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
      }

      // otherwise return current typing attribute
      return typingAttributes[.font] as? NSFont
    }

    set
    {
      guard let newValue
      else
      {
        NSException(name: .invalidArgumentException, reason: "nil NSFont given").raise()
        return
      }

      if !textContentManager.documentRange.isEmpty
      {
        addAttributes([.font: newValue], range: textContentManager.documentRange)
      }

      typingAttributes[.font] = newValue
    }
  }

  open func setFont(_ font: NSFont, range: NSRange)
  {
    addAttributes([.font: font], range: range)
  }

  /// The text color of the text view.
  @objc open dynamic var textColor: NSColor?
  {
    get
    {
      typingAttributes[.foregroundColor] as? NSColor
    }

    set
    {
      typingAttributes[.foregroundColor] = newValue
    }
  }

  /// Sets the text color of characters within the specified range to the specified color.
  open func setTextColor(_ color: NSColor?, range: NSRange)
  {
    if let color
    {
      addAttributes([.foregroundColor: color], range: range)
    }
    else
    {
      removeAttribute(.foregroundColor, range: range)
    }
  }

  /// Deprecated. The text view’s default paragraph style.
  @available(*, deprecated, message: "Use typingAttributes[.paragraphStyle] instead")
  @objc public dynamic var defaultParagraphStyle: NSParagraphStyle?
  {
    get
    {
      typingAttributes[.paragraphStyle] as? NSParagraphStyle
    }

    set
    {
      typingAttributes[.paragraphStyle] = newValue
    }
  }

  private static let defaultTypingAttributes: [NSAttributedString.Key: Any] = [
    .paragraphStyle: NSParagraphStyle.default,
    .font: NSFont.userFont(ofSize: 0) ?? .preferredFont(forTextStyle: .body),
    .foregroundColor: NSColor.textColor,
  ]

  /// The text view's typing attributes
  ///
  /// Typing attributes are reset automatically whenever the selection changes. However, if you add any user actions that change text attributes, the action should use this method to apply those attributes afterwards. User actions that change attributes should always set the typing attributes because there might not be a subsequent change in selection before the next typing.
  @objc public dynamic var typingAttributes: [NSAttributedString.Key: Any]
  {
    didSet
    {
      // make sure to keep the main attributes set.
      if typingAttributes.isEmpty
      {
        typingAttributes = Self.defaultTypingAttributes
      }
      else
      {
        for key in Self.defaultTypingAttributes.keys
        {
          if typingAttributes[key] == nil
          {
            typingAttributes[key] = Self.defaultTypingAttributes[key]
          }
        }
      }

      needsLayout = true
      needsDisplay = true
    }
  }

  internal func updateTypingAttributes()
  {
    // TODO: doesn't work work correctly (at all) for multiple insertion points where each has different typing attribute
    if let insertionPointSelection = textLayoutManager.insertionPointSelections.first,
       let startLocation = insertionPointSelection.textRanges.first?.location
    {
      var attrs: [NSAttributedString.Key: Any] = [:]
      // The attribute is derived from the previous (upstream) location,
      // except for the beginning of the document where it from whatever is at location 0
      let options: NSTextContentManager.EnumerationOptions = startLocation == textContentManager.documentRange.location ? [] : [.reverse]
      let offsetDiff = startLocation == textContentManager.documentRange.location ? 0 : -1
      textContentManager.enumerateTextElements(from: startLocation, options: options)
      { textElement in
        if let textParagraph = textElement as? NSTextParagraph,
           let elementRange = textElement.elementRange,
           let textContentManager = textElement.textContentManager
        {
          let offset = textContentManager.offset(from: elementRange.location, to: startLocation)
          assert(offset != NSNotFound, "Unexpected location")
          attrs = textParagraph.attributedString.attributes(at: offset + offsetDiff, effectiveRange: nil)
        }

        return false
      }

      // fill in with missing typing attributes if needed
      for key in Self.defaultTypingAttributes.keys
      {
        if attrs[key] == nil
        {
          attrs[key] = Self.defaultTypingAttributes[key]
        }
      }

      typingAttributes = attrs
    }
  }

  /// line height based on current typing font and current typing paragraph
  internal var typingLineHeight: CGFloat
  {
    let font = typingAttributes[.font] as? NSFont ?? Self.defaultTypingAttributes[.font] as! NSFont
    let paragraphStyle = typingAttributes[.paragraphStyle] as? NSParagraphStyle ?? Self.defaultTypingAttributes[.paragraphStyle] as! NSParagraphStyle
    let lineHeightMultiple = paragraphStyle.lineHeightMultiple.isAlmostZero() ? 1.0 : paragraphStyle.lineHeightMultiple
    return NSLayoutManager().defaultLineHeight(for: font) * lineHeightMultiple
  }

  /// The characters of the receiver’s text.
  ///
  /// For performance reasons, this value is the current backing store of the text object.
  /// If you want to maintain a snapshot of this as you manipulate the text storage, you should make a copy of the appropriate substring.
  public var string: String
  {
    set
    {
      let prevLocation = textLayoutManager.insertionPointLocations.first

      setString(newValue)

      // restore selection location
      if let prevLocation
      {
        setSelectedTextRange(NSTextRange(location: prevLocation))
      }
    }
    get
    {
      textContentManager.documentString
    }
  }

  public func setAttributedString(_ attributedString: NSAttributedString)
  {
    setString(attributedString)
  }

  /// A Boolean that controls whether the text container adjusts the width of its bounding rectangle when its text view resizes.
  ///
  /// When the value of this property is `true`, the text container adjusts its width when the width of its text view changes. The default value of this property is `false`.
  @objc public dynamic var widthTracksTextView: Bool
  {
    set
    {
      if textContainer.widthTracksTextView != newValue
      {
        textContainer.widthTracksTextView = newValue

        if textContainer.widthTracksTextView == true
        {
          textContainer.size = CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: textContainer.size.height)
        }
        else
        {
          textContainer.size = CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: CGFloat(Float.greatestFiniteMagnitude))
        }

        if let scrollView
        {
          setFrameSize(scrollView.contentSize)
        }

        needsLayout = true
        needsDisplay = true
      }
    }
    get
    {
      textContainer.widthTracksTextView
    }
  }

  /// A Boolean that controls whether the text view highlights the currently selected line.
  @Invalidating(.display)
  @objc open dynamic var highlightSelectedLine: Bool = false

  /// The highlight color of the selected line.
  ///
  /// Note: Needs ``highlightSelectedLine`` to be set to `true`
  @Invalidating(.display)
  @objc open dynamic var selectedLineHighlightColor: NSColor = .selectedTextBackgroundColor.withAlphaComponent(0.25)

  /// The background color of a text selection.
  @Invalidating(.display)
  @objc open dynamic var selectionBackgroundColor: NSColor = .selectedTextBackgroundColor

  /// The text view's background color
  @Invalidating(.display)
  @objc open dynamic var backgroundColor: NSColor? = nil
  {
    didSet
    {
      layer?.backgroundColor = backgroundColor?.cgColor
    }
  }

  @objc open dynamic var allowsDocumentBackgroundColorChange: Bool = true

  @objc open func changeDocumentBackgroundColor(_ sender: Any?)
  {
    guard allowsDocumentBackgroundColorChange, let color = sender as? NSColor
    else
    {
      return
    }

    backgroundColor = color
  }

  open var contentType: NSTextContentType?

  /// A Boolean value that indicates whether the receiver allows undo.
  ///
  /// `true` if the receiver allows undo, otherwise `false`. Default `true`.
  @objc open dynamic var allowsUndo: Bool
  internal var _undoManager: UndoManager?

  internal class MarkedText: CustomDebugStringConvertible
  {
    var markedText: NSAttributedString
    var markedRange: NSRange
    var selectedRange: NSRange

    init(markedText: NSAttributedString, markedRange: NSRange, selectedRange: NSRange)
    {
      self.markedText = markedText
      self.markedRange = markedRange
      self.selectedRange = selectedRange
    }

    var debugDescription: String
    {
      "markedText: \"\(markedText.string)\", markedRange: \(markedRange), selectedRange: \(selectedRange)"
    }
  }

  internal var markedText: MarkedText? = nil

  /// The attributes used to draw marked text.
  ///
  /// Text color, background color, and underline are the only supported attributes for marked text.
  public var markedTextAttributes: [NSAttributedString.Key: Any]?

  /// A flag
  internal var processingKeyEvent: Bool = false

  /// The delegate for all text views sharing the same layout manager.
  public weak var delegate: STTextViewDelegate?
  public weak var dataSource: STTextViewDataSource?

  /// The manager that lays out text for the text view's text container.
  public let textLayoutManager: NSTextLayoutManager

  @available(*, deprecated, renamed: "textContentManager")
  open var textContentStorage: NSTextContentStorage
  {
    textContentManager as! NSTextContentStorage
  }

  /// The text view's text storage object.
  public let textContentManager: NSTextContentManager

  /// The text view's text container
  public let textContainer: NSTextContainer

  internal let contentView: ContentView
  internal let selectionView: SelectionView
  internal var backingScaleFactor: CGFloat { window?.backingScaleFactor ?? 1 }
  internal var fragmentViewMap: NSMapTable<NSTextLayoutFragment, STTextLayoutFragmentView>
  private var usageBoundsForTextContainerObserver: NSKeyValueObservation?
  internal lazy var speechSynthesizer: NSSpeechSynthesizer = .init()

  internal lazy var completionWindowController: CompletionWindowController = {
    let viewController = delegate?.textViewCompletionViewController(self) ?? STCompletionViewController()
    return CompletionWindowController(viewController)
  }()

  internal var annotationViewMap: NSMapTable<STLineAnnotation, NSView>

  /// Search-and-replace find interface inside a view.
  public let textFinder: NSTextFinder

  /// NSTextFinderClient
  internal let textFinderClient: STTextFinderClient

  /// A Boolean value that indicates whether incremental searching is enabled.
  public var isIncrementalSearchingEnabled: Bool
  {
    get
    {
      textFinder.isIncrementalSearchingEnabled
    }
    set
    {
      textFinder.isIncrementalSearchingEnabled = newValue
    }
  }

  /// A Boolean value that controls whether the text views sharing the receiver’s layout manager use the Font panel and Font menu.
  open var usesFontPanel: Bool = true

  /// A Boolean value that controls whether the text views sharing the receiver’s layout manager use a ruler.
  ///
  /// true to cause text views sharing the receiver's layout manager to respond to NSRulerView client messages and to paragraph-related menu actions, and update the ruler (when visible) as the selection changes with its paragraph and tab attributes, otherwise false.
  open var usesRuler: Bool = true

  /// A Boolean value indicating whether the view needs scroll to visible selection pass before it can be drawn.
  internal var needsScrollToSelection: Bool = false
  {
    didSet
    {
      if needsScrollToSelection
      {
        needsLayout = true
      }
    }
  }

  override open var isFlipped: Bool
  {
    #if os(macOS)
      true
    #else
      false
    #endif
  }

  /// Generates and returns a scroll view with a STTextView set as its document view.
  open class func scrollableTextView() -> NSScrollView
  {
    let scrollView = NSScrollView()
    let textView = STTextView()

    let textContainer = textView.textContainer
    textContainer.widthTracksTextView = true
    textContainer.heightTracksTextView = false

    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    scrollView.drawsBackground = false
    scrollView.documentView = textView
    return scrollView
  }

  internal var scrollView: NSScrollView?
  {
    guard let result = enclosingScrollView else { return nil }
    if result.documentView == self
    {
      return result
    }
    else
    {
      return nil
    }
  }

  /// A dragging selection anchor
  ///
  /// FB11898356 - Something if wrong with textSelectionsInteractingAtPoint
  /// it expects that the dragging operation does not change anchor selections
  /// significantly. Specifically it does not play well if anchor and current
  /// location is too close to each other, therefore `mouseDraggingSelectionAnchors`
  /// keep the anchors unchanged while dragging.
  internal var mouseDraggingSelectionAnchors: [NSTextSelection]? = nil

  override open class var defaultMenu: NSMenu?
  {
    let menu = super.defaultMenu ?? NSMenu()

    let pasteAsPlainText = NSMenuItem(title: NSLocalizedString("Paste and Match Style", comment: ""), action: #selector(pasteAsPlainText(_:)), keyEquivalent: "V")
    pasteAsPlainText.keyEquivalentModifierMask = [.option, .command, .shift]

    menu.items = [
      NSMenuItem(title: NSLocalizedString("Cut", comment: ""), action: #selector(cut(_:)), keyEquivalent: "x"),
      NSMenuItem(title: NSLocalizedString("Copy", comment: ""), action: #selector(copy(_:)), keyEquivalent: "c"),
      NSMenuItem(title: NSLocalizedString("Paste", comment: ""), action: #selector(paste(_:)), keyEquivalent: "v"),
      pasteAsPlainText,
      NSMenuItem.separator(),
      NSMenuItem(title: NSLocalizedString("Select All", comment: ""), action: #selector(selectAll(_:)), keyEquivalent: "a"),
    ]
    return menu
  }

  /// Initializes a text view.
  /// - Parameter frameRect: The frame rectangle of the text view.
  override public init(frame frameRect: NSRect)
  {
    fragmentViewMap = .weakToWeakObjects()
    annotationViewMap = .strongToWeakObjects()

    textContentManager = STTextContentStorage()
    textContainer = NSTextContainer(containerSize: CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: CGFloat(Float.greatestFiniteMagnitude)))
    textLayoutManager = STTextLayoutManager()
    textLayoutManager.textContainer = textContainer
    textContentManager.addTextLayoutManager(textLayoutManager)
    textContentManager.primaryTextLayoutManager = textLayoutManager

    contentView = ContentView()
    contentView.wantsLayer = true
    contentView.autoresizingMask = [.height, .width]
    selectionView = SelectionView()
    selectionView.wantsLayer = true
    selectionView.autoresizingMask = [.height, .width]

    typingAttributes = Self.defaultTypingAttributes
    allowsUndo = true
    _undoManager = CoalescingUndoManager()

    textFinder = NSTextFinder()
    textFinderClient = STTextFinderClient()

    super.init(frame: frameRect)

    textLayoutManager.delegate = self
    textFinderClient.textView = self

    // Set insert point at the very beginning
    setSelectedTextRange(NSTextRange(location: textContentManager.documentRange.location))

    postsBoundsChangedNotifications = true
    postsFrameChangedNotifications = true

    wantsLayer = true
    autoresizingMask = [.width, .height]

    textLayoutManager.textViewportLayoutController.delegate = self

    addSubview(selectionView)
    addSubview(contentView)

    // Forward didChangeSelectionNotification from STTextLayoutManager
    NotificationCenter.default.addObserver(forName: STTextView.didChangeSelectionNotification, object: textLayoutManager, queue: .main)
    { [weak self] notification in
      guard let self else { return }

      Yanking.shared.selectionChanged()

      NotificationCenter.default.post(
        Notification(name: STTextView.didChangeSelectionNotification, object: self, userInfo: notification.userInfo)
      )
      delegate?.textViewDidChangeSelection(notification)
    }

    usageBoundsForTextContainerObserver = textLayoutManager.observe(\.usageBoundsForTextContainer, options: [.new])
    { [weak self] _, _ in
      self?.needsUpdateConstraints = true
    }
  }

  override open func resetCursorRects()
  {
    super.resetCursorRects()
    if isSelectable
    {
      addCursorRect(visibleRect, cursor: .iBeam)
    }
  }

  override open func viewDidChangeEffectiveAppearance()
  {
    super.viewDidChangeEffectiveAppearance()
    updateSelectionHighlights()
  }

  override open func viewDidMoveToWindow()
  {
    super.viewDidMoveToWindow()

    if window != nil
    {
      textFinder.client = textFinderClient
      textFinder.findBarContainer = scrollView
    }
  }

  override open func hitTest(_ point: NSPoint) -> NSView?
  {
    let result = super.hitTest(point)

    // click-through `contentView`, `selectionView` and `lineAnnotationView` subviews
    // that makes first responder properly redirect to main view
    // and ignore utility subviews that should remain transparent
    // for interaction.
    if let view = result, view != self,
       view.isDescendant(of: contentView) || view.isDescendant(of: selectionView)
    {
      return self
    }
    return result
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }

  override open var canBecomeKeyView: Bool
  {
    super.canBecomeKeyView && acceptsFirstResponder && !isHiddenOrHasHiddenAncestor
  }

  override open var needsPanelToBecomeKey: Bool
  {
    isSelectable || isEditable
  }

  override open var acceptsFirstResponder: Bool
  {
    isSelectable
  }

  @Invalidating(.insertionPoint)
  internal var isFirstResponder: Bool = false

  override open func becomeFirstResponder() -> Bool
  {
    if isEditable
    {
      NotificationCenter.default.post(name: NSText.didBeginEditingNotification, object: self, userInfo: nil)
    }

    defer
    {
      isFirstResponder = true
    }

    return super.becomeFirstResponder()
  }

  override open func resignFirstResponder() -> Bool
  {
    if isEditable
    {
      NotificationCenter.default.post(name: NSText.didEndEditingNotification, object: self, userInfo: nil)
    }

    defer
    {
      isFirstResponder = false
    }
    return super.resignFirstResponder()
  }

  /// Resigns the window’s key window status.
  ///
  /// Swift documentation to NSWindow.resignKey() is wrong about selector sent to the first responder.
  /// It uses resignKeyWindow(), not resignKey() selector.
  ///
  /// Never invoke this method directly.
  @objc private func resignKeyWindow()
  {
    updateInsertionPointStateAndRestartTimer()
  }

  @objc private func becomeKeyWindow()
  {
    updateInsertionPointStateAndRestartTimer()
  }

  override open class var isCompatibleWithResponsiveScrolling: Bool
  {
    true
  }

  override open func prepareContent(in rect: NSRect)
  {
    needsLayout = true
    super.prepareContent(in: rect)
  }

  override open func draw(_ dirtyRect: NSRect)
  {
    drawBackground(in: dirtyRect)
    super.draw(dirtyRect)
  }

  /// Draws the background of the text view.
  open func drawBackground(in rect: NSRect)
  {
    if highlightSelectedLine,
       // don't highlight when there's selection
       textLayoutManager.insertionPointSelections.flatMap(\.textRanges).allSatisfy(\.isEmpty)
    {
      drawHighlightedLine(in: rect)
    }
  }

  private func drawHighlightedLine(in _: NSRect)
  {
    guard let context = NSGraphicsContext.current?.cgContext
    else
    {
      return
    }

    for insertionRange in textLayoutManager.insertionPointSelections.flatMap(\.textRanges)
    {
      textLayoutManager.enumerateTextLayoutFragments(from: insertionRange.location)
      { layoutFragment in
        context.saveGState()
        context.setFillColor(selectedLineHighlightColor.cgColor)

        let fillRect = CGRect(
          origin: CGPoint(
            x: bounds.minX,
            y: layoutFragment.layoutFragmentFrame.origin.y
          ),
          size: CGSize(
            width: textContainer.size.width,
            height: layoutFragment.layoutFragmentFrame.height
          )
        )

        context.fill(fillRect)
        context.restoreGState()
        return false
      }
    }
  }

  internal func setString(_ string: Any?)
  {
    undoManager?.disableUndoRegistration()
    defer
    {
      undoManager?.enableUndoRegistration()
    }

    if case let .some(string) = string
    {
      switch string
      {
        case let attributedString as NSAttributedString:
          replaceCharacters(in: textContentManager.documentRange, with: attributedString, allowsTypingCoalescing: false)
        case let string as String:
          replaceCharacters(in: textContentManager.documentRange, with: string, useTypingAttributes: true, allowsTypingCoalescing: false)
        default:
          assertionFailure()
          return
      }
    }
    else if case .none = string
    {
      replaceCharacters(in: textContentManager.documentRange, with: "", useTypingAttributes: true, allowsTypingCoalescing: false)
    }
  }

  /// Add attribute. Need `needsViewportLayout = true` to reflect changes.
  open func addAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange, updateLayout: Bool = true)
  {
    guard let textRange = NSTextRange(range, in: textContentManager)
    else
    {
      preconditionFailure("Invalid range \(range)")
    }

    addAttributes(attrs, range: textRange, updateLayout: updateLayout)
  }

  /// Add attribute. Need `needsViewportLayout = true` to reflect changes.
  open func addAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSTextRange, updateLayout: Bool = true)
  {
    for attr in attrs
    {
      textLayoutManager.addRenderingAttribute(attr.key, value: attr.value, for: range)
    }

    textContentManager.performEditingTransaction
    {
      (textContentManager as? NSTextContentStorage)?.textStorage?.addAttributes(attrs, range: NSRange(range, in: textContentManager))
    }

    if updateLayout
    {
      updateTypingAttributes()
      needsLayout = true
    }
  }

  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  open func setAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange, updateLayout: Bool = true)
  {
    guard let textRange = NSTextRange(range, in: textContentManager)
    else
    {
      preconditionFailure("Invalid range \(range)")
    }

    setAttributes(attrs, range: textRange, updateLayout: updateLayout)
  }

  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  open func setAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSTextRange, updateLayout: Bool = true)
  {
    // FB9692714 This doesn't work
    textLayoutManager.setRenderingAttributes(attrs, for: range)

    textContentManager.performEditingTransaction
    {
      (textContentManager as? NSTextContentStorage)?.textStorage?.setAttributes(attrs, range: NSRange(range, in: textContentManager))
    }

    if updateLayout
    {
      updateTypingAttributes()
      needsLayout = true
    }
  }

  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  open func removeAttribute(_ attribute: NSAttributedString.Key, range: NSRange, updateLayout: Bool = true)
  {
    guard let textRange = NSTextRange(range, in: textContentManager)
    else
    {
      preconditionFailure("Invalid range \(range)")
    }

    removeAttribute(attribute, range: textRange, updateLayout: updateLayout)
  }

  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  open func removeAttribute(_ attribute: NSAttributedString.Key, range: NSTextRange, updateLayout: Bool = true)
  {
    // FB9692714 This doesn't work
    textLayoutManager.removeRenderingAttribute(attribute, for: range)

    textContentManager.performEditingTransaction
    {
      (textContentManager as? NSTextContentStorage)?.textStorage?.removeAttribute(attribute, range: NSRange(range, in: textContentManager))
    }

    updateTypingAttributes()

    if updateLayout
    {
      needsLayout = true
    }
  }

  internal func updateSelectionHighlights()
  {
    guard !textLayoutManager.textSelections.isEmpty
    else
    {
      selectionView.subviews.removeAll()
      return
    }

    selectionView.subviews.removeAll()

    for textRange in textLayoutManager.textSelections.flatMap(\.textRanges).sorted(by: { $0.location < $1.location })
    {
      textLayoutManager.enumerateTextSegments(in: textRange, type: .selection, options: .rangeNotRequired)
      { _, textSegmentFrame, _, _ in
        let highlightFrame = textSegmentFrame.intersection(frame).pixelAligned
        guard !highlightFrame.isNull
        else
        {
          return true
        }

        if !highlightFrame.size.width.isZero
        {
          let highlightView = HighlightView(frame: highlightFrame)
          highlightView.wantsLayer = true
          highlightView.layer?.backgroundColor = selectionBackgroundColor.cgColor
          selectionView.addSubview(highlightView)
        }
        else
        {
          // NOTE: this is to hide/show insertion point on selection.
          //       there's probably better place to handle that.
          updateInsertionPointStateAndRestartTimer()
        }

        return true // keep going
      }
    }
  }

  /// Update text view frame size
  internal func updateFrameSizeIfNeeded()
  {
    let currentSize = frame.size
    let viewportBounds = textLayoutManager.textViewportLayoutController.viewportBounds

    var proposedHeight: CGFloat = viewportBounds.height
    if textLayoutManager.documentRange.isEmpty
    {
      proposedHeight = typingLineHeight
    }
    else
    {
      let endLocation = textLayoutManager.documentRange.endLocation
      textLayoutManager.ensureLayout(for: NSTextRange(location: endLocation))
      textLayoutManager.enumerateTextLayoutFragments(from: endLocation, options: [.reverse, .ensuresLayout, .ensuresExtraLineFragment])
      { layoutFragment in
        proposedHeight = max(proposedHeight, layoutFragment.layoutFragmentFrame.maxY)
        return false // stop
      }
    }

    var proposedWidth: CGFloat = viewportBounds.width
    if !textContainer.widthTracksTextView
    {
      // TODO: if offset didn't change since last time, it is not necessary to relayout
      // not necessarly need to layout whole thing, is's enough to enumerate over visible area
      let startLocation = textLayoutManager.textViewportLayoutController.viewportRange?.location ?? textLayoutManager.documentRange.location
      let endLocation = textLayoutManager.textViewportLayoutController.viewportRange?.endLocation ?? textLayoutManager.documentRange.endLocation
      textLayoutManager.enumerateTextLayoutFragments(from: startLocation, options: [.ensuresLayout, .ensuresExtraLineFragment])
      { layoutFragment in
        proposedWidth = max(proposedWidth, layoutFragment.layoutFragmentFrame.maxX)
        return layoutFragment.rangeInElement.location < endLocation
      }
    }
    else
    {
      proposedWidth = max(currentSize.width, proposedWidth)
    }

    let proposedSize = CGSize(width: proposedWidth, height: proposedHeight)
    if !currentSize.isAlmostEqual(to: proposedSize)
    {
      setFrameSize(proposedSize)
    }
  }

  /// Update textContainer width to match textview width if track textview width
  internal func updateTextContainerSizeIfNeeded()
  {
    var proposedSize = textContainer.size

    if textContainer.widthTracksTextView, !textContainer.size.width.isAlmostEqual(to: bounds.width)
    {
      proposedSize.width = bounds.width
    }

    if textContainer.heightTracksTextView, !textContainer.size.height.isAlmostEqual(to: bounds.height)
    {
      proposedSize.height = bounds.height
    }

    if !textContainer.size.isAlmostEqual(to: proposedSize)
    {
      textContainer.size = proposedSize
    }
  }

  override open func setFrameSize(_ newSize: NSSize)
  {
    let maxW = CGFloat(Float(min(Float.greatestFiniteMagnitude, Float(newSize.width))))
    let maxH = CGFloat(Float(min(Float.greatestFiniteMagnitude, Float(newSize.height))))

    super.setFrameSize(.init(width: abs(maxW), height: abs(maxH)))
    updateTextContainerSizeIfNeeded()
    layoutAnnotationViewsIfNeeded(forceLayout: true)
  }

  override open func viewDidEndLiveResize()
  {
    super.viewDidEndLiveResize()
    adjustViewportOffsetIfNeeded()
    updateFrameSizeIfNeeded()
  }

  override open func layout()
  {
    super.layout()

    if needsScrollToSelection, let textSelection = textLayoutManager.textSelections.last
    {
      scrollToSelection(textSelection)
    }

    textLayoutManager.textViewportLayoutController.layoutViewport()
    needsScrollToSelection = false
    layoutAnnotationViewsIfNeeded()
  }

  internal func scrollToSelection(_ selection: NSTextSelection)
  {
    guard let selectionTextRange = selection.textRanges.last
    else
    {
      return
    }

    if selectionTextRange.isEmpty
    {
      if let selectionRect = textLayoutManager.textSelectionSegmentFrame(at: selectionTextRange.location, type: .selection)
      {
        scrollToVisible(selectionRect.margin(.init(width: visibleRect.width * 0.1, height: 0)))
      }
    }
    else
    {
      switch selection.affinity
      {
        case .upstream:
          if let selectionRect = textLayoutManager.textSelectionSegmentFrame(at: selectionTextRange.location, type: .selection)
          {
            scrollToVisible(selectionRect.margin(.init(width: visibleRect.width * 0.1, height: 0)))
          }
        case .downstream:
          if let location = textLayoutManager.location(selectionTextRange.endLocation, offsetBy: -1),
             let selectionRect = textLayoutManager.textSelectionSegmentFrame(at: location, type: .selection)
          {
            scrollToVisible(selectionRect.margin(.init(width: visibleRect.width * 0.1, height: 0)))
          }
        @unknown default:
          break
      }
    }
  }

  open func scrollRangeToVisible(_ range: NSRange)
  {
    textFinderClient.scrollRangeToVisible(range)
  }

  open func scrollRangeToVisible(_ range: NSTextRange)
  {
    scrollRangeToVisible(NSRange(range, in: textContentManager))
  }

  open func textWillChange(_: Any?)
  {
    if textFinder.isIncrementalSearchingEnabled
    {
      textFinder.noteClientStringWillChange()
    }

    let notification = Notification(name: STTextView.textWillChangeNotification, object: self, userInfo: nil)
    NotificationCenter.default.post(notification)
    delegate?.textViewWillChangeText(notification)
  }

  /// Sends out necessary notifications when a text change completes.
  open func textDidChange(_: Any?)
  {
    didChangeText()
  }

  /// Sends out necessary notifications when a text change completes.
  ///
  /// Invoked automatically at the end of a series of changes, this method posts an `textDidChangeNotification` to the default notification center, which also results in the delegate receiving `textViewDidChangeText(_:)` message.
  /// Subclasses implementing methods that change their text should invoke this method at the end of those methods.
  open func didChangeText()
  {
    needsScrollToSelection = true

    let notification = Notification(name: STTextView.textDidChangeNotification, object: self, userInfo: nil)
    NotificationCenter.default.post(notification)
    delegate?.textViewDidChangeText(notification)
    Yanking.shared.textChanged()

    // Because annotation location position changed
    // we need to reposition all views that may be
    // affected by the text change
    layoutAnnotationViewsIfNeeded(forceLayout: true)

    needsDisplay = true
  }

  public func replaceCharacters(in range: NSRange, with string: String)
  {
    textFinderClient.replaceCharacters(in: range, with: string)
  }

  public func replaceCharacters(in range: NSTextRange, with string: String)
  {
    replaceCharacters(in: range, with: string, useTypingAttributes: true, allowsTypingCoalescing: false)
  }

  internal func replaceCharacters(in textRanges: [NSTextRange], with replacementString: String, useTypingAttributes: Bool, allowsTypingCoalescing: Bool)
  {
    replaceCharacters(
      in: textRanges,
      with: NSAttributedString(string: replacementString, attributes: useTypingAttributes ? typingAttributes : [:]),
      allowsTypingCoalescing: allowsTypingCoalescing
    )
  }

  internal func replaceCharacters(in textRanges: [NSTextRange], with replacementString: NSAttributedString, allowsTypingCoalescing _: Bool)
  {
    // Replace from the end to beginning of the document
    for textRange in textRanges.sorted(by: { $0.location > $1.location })
    {
      replaceCharacters(in: textRange, with: replacementString, allowsTypingCoalescing: true)
    }
  }

  internal func replaceCharacters(in textRange: NSTextRange, with replacementString: String, useTypingAttributes: Bool, allowsTypingCoalescing: Bool)
  {
    replaceCharacters(
      in: textRange,
      with: NSAttributedString(string: replacementString, attributes: useTypingAttributes ? typingAttributes : [:]),
      allowsTypingCoalescing: allowsTypingCoalescing
    )
  }

  internal func replaceCharacters(in textRange: NSTextRange, with replacementString: NSAttributedString, allowsTypingCoalescing: Bool)
  {
    if allowsUndo, let undoManager, undoManager.isUndoRegistrationEnabled
    {
      // typing coalescing
      if processingKeyEvent, allowsTypingCoalescing,
         let undoManager = undoManager as? CoalescingUndoManager
      {
        if undoManager.isCoalescing
        {
          // Extend existing coalesce range
          if let coalescingValue = undoManager.coalescing?.value,
             textRange.location == coalescingValue.textRange.endLocation,
             let undoEndLocation = textContentManager.location(textRange.location, offsetBy: replacementString.string.utf16.count),
             let undoTextRange = NSTextRange(location: coalescingValue.textRange.location, end: undoEndLocation)
          {
            undoManager.coalesce(TypingTextUndo(
              textRange: undoTextRange,
              attribugedString: NSAttributedString()
            ))
          }
          else
          {
            breakUndoCoalescing()
          }
        }

        if !undoManager.isCoalescing
        {
          let undoRange = NSTextRange(
            location: textRange.location,
            end: textContentManager.location(textRange.location, offsetBy: replacementString.string.utf16.count)
          ) ?? textRange

          let previousStringInRange = (textContentManager as? NSTextContentStorage)!.attributedString!.attributedSubstring(from: NSRange(textRange, in: textContentManager))

          let startTypingUndo = TypingTextUndo(
            textRange: undoRange,
            attribugedString: previousStringInRange
          )

          undoManager.startCoalescing(startTypingUndo, withTarget: self)
          { textView, typingTextUndo in
            // Undo coalesced session action
            textView.replaceCharacters(
              in: typingTextUndo.textRange,
              with: typingTextUndo.attribugedString ?? NSAttributedString(),
              allowsTypingCoalescing: false
            )
          }
        }
      }
      else if !undoManager.isUndoing, !undoManager.isRedoing, undoManager.isUndoRegistrationEnabled
      {
        breakUndoCoalescing()

        // Reach to NSTextStorage because NSTextContentStorage range extraction is cumbersome.
        // A range that is as long as replacement string, so when undo it undo
        let undoRange = NSTextRange(
          location: textRange.location,
          end: textContentManager.location(textRange.location, offsetBy: replacementString.string.utf16.count)
        ) ?? textRange

        let previousStringInRange = (textContentManager as! NSTextContentStorage).attributedString!.attributedSubstring(from: NSRange(textRange, in: textContentManager))

        // Register undo/redo
        // I can't control internal redoStack, and coalescing messes up with the state
        // resulting in broken undo/redo availability
        undoManager.registerUndo(withTarget: self)
        { textView in
          // Regular undo action
          textView.replaceCharacters(
            in: undoRange,
            with: previousStringInRange,
            allowsTypingCoalescing: false
          )
        }
      }
    }

    textWillChange(self)
    delegate?.textView(self, willChangeTextIn: textRange, replacementString: replacementString.string)

    textContentManager.performEditingTransaction
    {
      textContentManager.replaceContents(
        in: textRange,
        with: [NSTextParagraph(attributedString: replacementString)]
      )
    }

    delegate?.textView(self, didChangeTextIn: textRange, replacementString: replacementString.string)
    textDidChange(self)
  }

  /// Whenever text is to be changed due to some user-induced action,
  /// this method should be called with information on the change.
  /// Coalesce consecutive typing events
  open func shouldChangeText(in affectedTextRange: NSTextRange, replacementString: String?) -> Bool
  {
    let result = delegate?.textView(self, shouldChangeTextIn: affectedTextRange, replacementString: replacementString) ?? true
    if !result
    {
      return result
    }

    return result
  }

  internal func shouldChangeText(in affectedTextRanges: [NSTextRange], replacementString: String?) -> Bool
  {
    affectedTextRanges.allSatisfy
    { textRange in
      shouldChangeText(in: textRange, replacementString: replacementString)
    }
  }

  /// Informs the receiver that it should begin coalescing successive typing operations in a new undo grouping
  public func breakUndoCoalescing()
  {
    (undoManager as? CoalescingUndoManager)?.breakCoalescing()
  }

  /// A Boolean value that indicates whether undo coalescing is in progress.
  public var isCoalescingUndo: Bool
  {
    (undoManager as? CoalescingUndoManager)?.isCoalescing ?? false
  }
}

// MARK: - NSViewInvalidating

private extension NSViewInvalidating where Self == NSView.Invalidations.InsertionPoint
{
  static var insertionPoint: NSView.Invalidations.InsertionPoint
  {
    NSView.Invalidations.InsertionPoint()
  }

  static var cursorRects: NSView.Invalidations.CursorRects
  {
    NSView.Invalidations.CursorRects()
  }
}

private extension NSView.Invalidations
{
  struct InsertionPoint: NSViewInvalidating
  {
    func invalidate(view: NSView)
    {
      guard let textView = view as? STTextView
      else
      {
        return
      }

      textView.updateInsertionPointStateAndRestartTimer()
    }
  }

  struct CursorRects: NSViewInvalidating
  {
    func invalidate(view: NSView)
    {
      view.window?.invalidateCursorRects(for: view)
    }
  }
}

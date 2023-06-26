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
import SwiftUI

public protocol STCompletionViewControllerDelegate: AnyObject
{
  func completionViewController<T: STCompletionViewControllerProtocol>(_ viewController: T, complete item: Any, movement: NSTextMovement)
}

public protocol STCompletionViewControllerProtocol: NSViewController
{
  var items: [Any] { get set }
  var delegate: STCompletionViewControllerDelegate? { get set }
}

open class STAnyCompletionViewController: NSViewController, STCompletionViewControllerProtocol
{
  open var items: [Any] = []
  open weak var delegate: STCompletionViewControllerDelegate?
}

open class STCompletionViewController: STAnyCompletionViewController
{
  override open var items: [Any]
  {
    didSet
    {
      tableView.reloadData()

      // preselect first row
      tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
  }

  public let tableView = NSTableView()
  private var contentScrollView: NSScrollView!

  private var eventMonitor: Any?

  override open func loadView()
  {
    view = NSView(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
    view.autoresizingMask = [.width, .height]
    view.wantsLayer = true
    view.layer?.cornerRadius = 5
    view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

    tableView.style = .plain
    tableView.headerView = nil
    tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
    tableView.allowsColumnResizing = false
    tableView.rowHeight = 22
    tableView.backgroundColor = .windowBackgroundColor
    tableView.action = #selector(tableViewAction(_:))
    tableView.doubleAction = #selector(tableViewDoubleAction(_:))
    tableView.target = self

    do
    {
      let nameColumn = NSTableColumn(identifier: .labelColumn)
      nameColumn.resizingMask = .autoresizingMask
      tableView.addTableColumn(nameColumn)
    }

    tableView.dataSource = self
    tableView.delegate = self

    let scrollView = NSScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    scrollView.automaticallyAdjustsContentInsets = false
    scrollView.contentInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
    scrollView.drawsBackground = false
    scrollView.autoresizingMask = [.width, .height]
    scrollView.hasVerticalScroller = true
    scrollView.documentView = tableView
    view.addSubview(scrollView)
    contentScrollView = scrollView
  }

  @objc open func tableViewAction(_: Any?)
  {
    // select row
  }

  @objc open func tableViewDoubleAction(_: Any?)
  {
    insertCompletion(movement: .other)
  }

  override open func viewDidAppear()
  {
    super.viewDidAppear()

    eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown)
    { [weak self] event -> NSEvent? in
      guard let self else { return nil }

      if let characters = event.characters
      {
        for c in characters
        {
          switch c
          {
            case "\u{001B}", // esc
                 "\u{0009}", // NSTabCharacter
                 "\u{0008}", // NSBackspaceCharacter
                 "\u{007F}", // NSDeleteCharacter
                 "\u{000A}", // NSNewlineCharacter
                 "\u{000D}", // NSCarriageReturnCharacter
                 "\u{0003}": // NSEnterCharacter
              interpretKeyEvents([event])
              return nil
            case "\u{F701}", // NSDownArrowFunctionKey
                 "\u{F700}": // NSUpArrowFunctionKey
              tableView.keyDown(with: event)
              return nil
            default:
              cancelOperation(self)
          }
        }
      }
      return event
    }
  }

  override open func viewDidDisappear()
  {
    super.viewDidDisappear()

    if let eventMonitor
    {
      NSEvent.removeMonitor(eventMonitor)
    }
    eventMonitor = nil
  }

  override open func insertTab(_: Any?)
  {
    insertCompletion(movement: .tab)
  }

  override open func insertLineBreak(_: Any?)
  {
    insertCompletion(movement: .return)
  }

  override open func insertNewline(_: Any?)
  {
    insertCompletion(movement: .return)
  }

  override open func deleteBackward(_: Any?)
  {
    view.window?.windowController?.close()
  }

  override open func deleteForward(_: Any?)
  {
    view.window?.windowController?.close()
  }

  override open func cancelOperation(_: Any?)
  {
    view.window?.windowController?.close()
  }

  private func insertCompletion(movement: NSTextMovement)
  {
    defer
    {
      self.cancelOperation(self)
    }

    guard tableView.selectedRow != -1 else { return }
    let item = items[tableView.selectedRow]
    delegate?.completionViewController(self, complete: item, movement: movement)
  }
}

extension STCompletionViewController: NSTableViewDelegate
{
  open func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
  {
    guard let tableColumn else { return nil }

    let item = items[row] as! STCompletion.Item

    switch tableColumn.identifier
    {
      case .labelColumn:
        let cellView = tableView.reuseOrCreateTableView(withIdentifier: .labelColumn) as CompletionLabelCellView
        cellView.setup(with: item)
        return cellView
      default:
        assertionFailure("Unknown column")
        return nil
    }
  }

  open func tableView(_: NSTableView, rowViewForRow _: Int) -> NSTableRowView?
  {
    STTableRowView()
  }
}

extension STCompletionViewController: NSTableViewDataSource
{
  open func numberOfRows(in _: NSTableView) -> Int
  {
    items.count
  }
}

private class STTableRowView: NSTableRowView
{
  override func drawSelection(in dirtyRect: NSRect)
  {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    context.saveGState()
    let path = NSBezierPath(roundedRect: dirtyRect, xRadius: 4, yRadius: 4)
    context.setFillColor(NSColor.selectedContentBackgroundColor.cgColor)
    path.fill()
    context.restoreGState()
  }
}

private class TableCellView: NSTableCellView
{
  override init(frame frameRect: NSRect)
  {
    super.init(frame: frameRect)

    let textField = NSTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.isEditable = false
    textField.isSelectable = false
    textField.drawsBackground = false
    textField.maximumNumberOfLines = 1
    textField.lineBreakMode = .byTruncatingTail
    textField.bezelStyle = .roundedBezel
    textField.isBordered = false
    textField.autoresizingMask = [.width, .height]

    addSubview(textField)

    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: leadingAnchor),
      textField.centerYAnchor.constraint(equalTo: centerYAnchor),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    self.textField = textField
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
}

private final class CompletionLabelCellView: TableCellView
{
  func setup(with item: STCompletion.Item)
  {
    guard let textField else { return }
    textField.font = .userFixedPitchFont(ofSize: NSFont.systemFontSize)
    textField.textColor = .labelColor
    textField.stringValue = item.label
    textField.allowsExpansionToolTips = true
  }
}

private extension NSTableView
{
  func reuseOrCreateTableView<V: NSView>(withIdentifier identifier: NSUserInterfaceItemIdentifier) -> V
  {
    guard let view = makeView(withIdentifier: identifier, owner: self)
    else
    {
      let view = V()
      view.identifier = identifier
      return view
    }
    return view as! V
  }
}

private extension NSUserInterfaceItemIdentifier
{
  static let labelColumn = NSUserInterfaceItemIdentifier("LabelColumn")
}

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
import UniformTypeIdentifiers

extension STTextView: NSMenuItemValidation
{
  public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
  {
    validateUserInterfaceItem(menuItem)
  }
}

extension STTextView: NSUserInterfaceValidations
{
  public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool
  {
    switch item.action
    {
      case #selector(copy(_:)), #selector(cut(_:)), #selector(delete(_:)):
        return !textContentManager.documentRange.isEmpty && !selectedRange().isEmpty
      case #selector(selectAll(_:)):
        return !textContentManager.documentRange.isEmpty
      case #selector(paste(_:)), #selector(pasteAsPlainText(_:)), #selector(pasteAsRichText(_:)):
        return isEditable && NSPasteboard.general.string(forType: .string) != nil
      case #selector(undo(_:)):
        let result = allowsUndo ? undoManager?.canUndo ?? false : false

        /// NSWindow does that like this, here (as debugged)
        if let undoManager
        {
          (item as? NSMenuItem)?.title = undoManager.undoMenuItemTitle
        }

        return result
      case #selector(redo(_:)):
        let result = allowsUndo ? undoManager?.canRedo ?? false : false

        /// NSWindow does that like this, here (as debugged)
        if let undoManager
        {
          (item as? NSMenuItem)?.title = undoManager.redoMenuItemTitle
        }
        return result
      case #selector(performFindPanelAction(_:)), #selector(performTextFinderAction(_:)):
        return textFinder.validateAction(NSTextFinder.Action(rawValue: item.tag)!)
      case #selector(stopSpeaking(_:)):
        return speechSynthesizer.isSpeaking
      case #selector(startSpeaking(_:)):
        return !textContentManager.documentRange.isEmpty
      case #selector(toggleRuler(_:)):
        return usesRuler && enclosingScrollView?.hasHorizontalRuler == true || enclosingScrollView?.hasVerticalRuler == true
      default:
        return true
    }
  }
}

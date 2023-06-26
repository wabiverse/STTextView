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

extension STTextView
{
  /// Performs a find panel action specified by the sender's tag.
  ///
  /// This is the generic action method for the find menu and find panel, and can be overridden to implement a custom find panel.
  /// See NSTextFinder.Action for list of possible tags
  @objc open func performFindPanelAction(_ sender: Any?)
  {
    performTextFinderAction(sender)
  }

  /// Performs all find oriented actions.
  /// Before OS X v10.7, the default action for these menu items was performFindPanelAction(_:)
  @objc override open func performTextFinderAction(_ sender: Any?)
  {
    guard let menuItem = sender as? NSMenuItem,
          let action = NSTextFinder.Action(rawValue: menuItem.tag)
    else
    {
      assertionFailure("Unexpected caller")
      return
    }

    if textFinder.validateAction(action)
    {
      textFinder.performAction(action)
    }
  }
}

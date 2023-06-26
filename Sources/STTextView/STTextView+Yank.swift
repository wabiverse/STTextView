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

import Foundation

extension STTextView
{
  /// Yanking means reinserting text previously killed. The usual way to move or copy text is to kill it and then yank it elsewhere.
  ///
  /// https://www.gnu.org/software/emacs/manual/html_node/emacs/Yanking.html
  override open func yank(_: Any?)
  {
    replaceCharacters(
      in: textLayoutManager.insertionPointSelections.flatMap(\.textRanges),
      with: Yanking.shared.yank(),
      useTypingAttributes: true,
      allowsTypingCoalescing: false
    )
  }
}

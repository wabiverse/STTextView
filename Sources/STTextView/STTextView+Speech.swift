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
import Foundation

extension STTextView
{
  /// Speaks the selected text, or all text if no selection.
  @objc func startSpeaking(_ sender: Any?)
  {
    stopSpeaking(sender)
    speechSynthesizer.startSpeaking(textLayoutManager.textSelectionsString() ?? string)
  }

  /// Stops the speaking of text.
  @objc func stopSpeaking(_: Any?)
  {
    guard speechSynthesizer.isSpeaking
    else
    {
      return
    }

    speechSynthesizer.stopSpeaking(at: .immediateBoundary)
  }
}

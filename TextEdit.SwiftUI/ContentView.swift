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

import STTextViewUI
import SwiftUI

struct ContentView: View
{
  @State private var text = try! String(contentsOf: Bundle.main.url(forResource: "content", withExtension: "txt")!)

  var body: some View
  {
    TextView(
      text: $text,
      font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular),
      options: [.wrapLines, .highlightSelectedLine]
    )
  }
}

struct ContentView_Previews: PreviewProvider
{
  static var previews: some View
  {
    ContentView()
  }
}

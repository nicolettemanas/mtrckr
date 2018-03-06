// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  typealias Color = UIColor
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable operator_usage_whitespace
extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
// swiftlint:enable operator_usage_whitespace

// swiftlint:disable identifier_name line_length type_body_length
struct Colors {
  let rgbaValue: UInt32
  var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  static let barBg = Colors(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ededf1"></span>
  /// Alpha: 100% <br/> (0xededf1ff)
  static let emptyDataSetBg = Colors(rgbaValue: 0xededf1ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#eeeeee"></span>
  /// Alpha: 100% <br/> (0xeeeeeeff)
  static let lightBg = Colors(rgbaValue: 0xeeeeeeff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  static let mainBg = Colors(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#00a7e1"></span>
  /// Alpha: 100% <br/> (0x00a7e1ff)
  static let mainBlue = Colors(rgbaValue: 0x00a7e1ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#45cb85"></span>
  /// Alpha: 100% <br/> (0x45cb85ff)
  static let mainGreen = Colors(rgbaValue: 0x45cb85ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f5ac72"></span>
  /// Alpha: 100% <br/> (0xf5ac72ff)
  static let mainOrange = Colors(rgbaValue: 0xf5ac72ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f45a5d"></span>
  /// Alpha: 100% <br/> (0xf45a5dff)
  static let mainRed = Colors(rgbaValue: 0xf45a5dff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#34374b"></span>
  /// Alpha: 100% <br/> (0x34374bff)
  static let mainText = Colors(rgbaValue: 0x34374bff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#a3a5b7"></span>
  /// Alpha: 100% <br/> (0xa3a5b7ff)
  static let placeholderText = Colors(rgbaValue: 0xa3a5b7ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#eeeeee"></span>
  /// Alpha: 100% <br/> (0xeeeeeeff)
  static let separatorColor = Colors(rgbaValue: 0xeeeeeeff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#cbf4ff"></span>
  /// Alpha: 100% <br/> (0xcbf4ffff)
  static let subBlue = Colors(rgbaValue: 0xcbf4ffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f4cba8"></span>
  /// Alpha: 100% <br/> (0xf4cba8ff)
  static let subOrange = Colors(rgbaValue: 0xf4cba8ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f4e3e3"></span>
  /// Alpha: 100% <br/> (0xf4e3e3ff)
  static let subRed = Colors(rgbaValue: 0xf4e3e3ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#6c6f87"></span>
  /// Alpha: 100% <br/> (0x6c6f87ff)
  static let subText = Colors(rgbaValue: 0x6c6f87ff)
}
// swiftlint:enable identifier_name line_length type_body_length

extension Color {
  convenience init(named color: Colors) {
    self.init(rgbaValue: color.rgbaValue)
  }
}

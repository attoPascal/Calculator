import Foundation

extension Double {
    var stringUsingSignificantDigits: String {
        let formatter = NSNumberFormatter()
        formatter.usesSignificantDigits = true
        formatter.decimalSeparator = "."
        return formatter.stringFromNumber(self)!
    }
}
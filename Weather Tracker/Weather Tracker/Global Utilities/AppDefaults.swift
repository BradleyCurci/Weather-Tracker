//
//  AppDefaults.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/30/25.
//

import Foundation
import SwiftUI


// Extending UIWindow and UIScreen to identify width and height bounds of device
extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}


func getTemp(_ data: WeatherModel, viewModel: WeatherManagerViewModel) -> Int {
    if viewModel.unit == "f" {
        return Int(data.current.temp_f)
    } else {
        return Int(data.current.temp_c)
    }
}

func getFeelsLike(_ data: WeatherModel, viewModel: WeatherManagerViewModel) -> Int {
    if viewModel.unit == "f" {
        return Int(data.current.feelslike_f)
    } else {
        return Int(data.current.feelslike_c)
    }
}

func cleanURL(urlString: String) -> String {
    let newString = urlString.replacingOccurrences(of: "\\", with: "")
    return newString
}


// Dismiss keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


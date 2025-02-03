//
//  WeatherManager.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/29/25.
//

import Foundation

class WeatherManager {
    
    static let shared = WeatherManager()
    
    private init() {}
    
    func fetchWeather(_ location: String) async throws -> WeatherModel {
        let url = "https://api.weatherapi.com/v1/current.json"
        
//      Init info Dictionary
        let infoDictionary: [String : Any] = Bundle.main.infoDictionary!
        let key: String = (infoDictionary["key"] as? String ?? "")
        let parameters: [String : Any] = [
            "q" : location,
            "key" : key
        ]
        let result: WeatherModel = try await APIClient.shared.asyncRequest(
            baseURL: url,
            parameters: parameters,
            printResponse: true
        )
        
        return result
    }
}

class WeatherManagerViewModel: ObservableObject {
    
    static let shared = WeatherManagerViewModel()
    
    private init() {}
    
    @Published var response: WeatherModel?
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var unit: String = "f"
    
    func loadWeather(_ location: String) async -> Bool  {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let response = try await WeatherManager.shared.fetchWeather(location)
            
            DispatchQueue.main.async {
                self.response = response
                self.isLoading = false
            }
            
            return true
            
        } catch {
            DispatchQueue.main.async {
                self.error = String(describing: error)
                self.isLoading = false
            }
            
            return false
        }
    }
    
    func updateUnit() {
        if unit == "f" {
            unit = "c"
        } else {
            unit = "f"
        }
    }
}

extension WeatherManagerViewModel {
    static var preview: WeatherManagerViewModel {
        let viewModel = WeatherManagerViewModel()
        viewModel.response = WeatherModel(
            location: LocationData(
                name: "Copenhagen",
                region: "Hovedstaden",
                country: "Denmark",
                lat: 55.667000000000002,
                lon: 12.583,
                tz_id: "Europe/Copenhagen",
                localtime_epoch: 1738219914,
                localtime: "2025-01-30 07:51"),
            current: CurrentData(last_updated: "2025-01-30 07:45", temp_c: 5.0999999999999996, temp_f: 41.200000000000003, is_day: 0, condition: Condition(text: "Overcast", code: 1009, icon: "//cdn.weatherapi.com/weather/64x64/night/296.png"), wind_mph: 11.199999999999999, wind_kph: 18, wind_dir: "SW", pressure_mb: 1007, pressure_in: 29.739999999999998, precip_mm: 0.02, precip_in: 0, humidity: 87, feelslike_c: 1.5, feelslike_f: 34.600000000000001, dewpoint_c: 3.1000000000000001, dewpoint_f: 37.5, vis_km: 10, vis_miles: 6, uv: 0, gust_mph: 17.5, gust_kph: 28.199999999999999)
        )
        return viewModel
    }
}

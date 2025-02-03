//
//  WeatherModel.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/29/25.
//

import Foundation

struct WeatherModel: Codable, Identifiable {
    var id: UUID { UUID() }
    var location: LocationData
    var current: CurrentData
}

struct LocationData: Codable {
    var name: String
    var region: String
    var country: String
    var lat: Double
    var lon: Double
    var tz_id: String
    var localtime_epoch: Float64
    var localtime: String
}

struct CurrentData: Codable {
    var last_updated: String
    var temp_c: Double
    var temp_f: Double
    var is_day: Int
    var condition: Condition
    var wind_mph: Double
    var wind_kph: Double
    var wind_dir: String
    var pressure_mb: Double
    var pressure_in: Double
    var precip_mm: Double
    var precip_in: Double
    var humidity: Int
    var feelslike_c: Double
    var feelslike_f: Double
    var dewpoint_c: Double
    var dewpoint_f: Double
    var vis_km: Double
    var vis_miles: Double
    var uv: Double
    var gust_mph: Double
    var gust_kph: Double
}

struct Condition: Codable {
    var text: String
    var code: Int
    var icon: String
}

// MARK: Example Response
/**
 {
     "location": {
         "name": "Philadelphia",
         "region": "Pennsylvania",
         "country": "United States of America",
         "lat": 39.9522,
         "lon": -75.1642,
         "tz_id": "America/New_York",
         "localtime_epoch": 1738159323,
         "localtime": "2025-01-29 09:02"
     },
     "current": {
         "last_updated_epoch": 1738159200,
         "last_updated": "2025-01-29 09:00",
         "temp_c": 1.7,
         "temp_f": 35.1,
         "is_day": 1,
         "condition": {
             "text": "Partly cloudy",
             "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png",
             "code": 1003
         },
         "wind_mph": 12.5,
         "wind_kph": 20.2,
         "wind_degree": 242,
         "wind_dir": "WSW",
         "pressure_mb": 1000.0,
         "pressure_in": 29.54,
         "precip_mm": 0.0,
         "precip_in": 0.0,
         "humidity": 64,
         "cloud": 25,
         "feelslike_c": -3.1,
         "feelslike_f": 26.4,
         "windchill_c": -4.1,
         "windchill_f": 24.7,
         "heatindex_c": 1.0,
         "heatindex_f": 33.8,
         "dewpoint_c": -2.3,
         "dewpoint_f": 27.8,
         "vis_km": 16.0,
         "vis_miles": 9.0,
         "uv": 0.3,
         "gust_mph": 21.2,
         "gust_kph": 34.1
     }
 }
 */

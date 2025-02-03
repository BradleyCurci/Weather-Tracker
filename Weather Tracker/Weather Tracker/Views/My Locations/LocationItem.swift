//
//  LocationItem.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/30/25.
//

import SwiftUI

struct LocationItem: View {
    //@StateObject private var viewModel = WeatherManagerViewModel.shared
    var location: String
    var temp: Int
    var icon: String
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(location)
                    .font(.title3)
                Text("\(temp)°")
                    .font(.system(size: 40))
            }
                
            Spacer()
            
            let url = URL(string: "https:\(icon)")
            AsyncImage(url: url) { image in
                image.resizable().frame(width: 100, height: 100)
            } placeholder: {
                ProgressView()
                    .frame(width: 100, height: 100) // same frame as icon to avoid unexpected layout results
            }
        }
        .task {
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.text.opacity(0.1))
        .clipShape(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        
    }
}

#Preview {
    LocationItem(location: "Philadelphia", temp: 50, icon: "//cdn.weatherapi.com/weather/64x64/night/122.png")
}

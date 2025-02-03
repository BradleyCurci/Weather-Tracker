//
//  TabView.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/30/25.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                Home()
            }
            
            Tab("My Locations", systemImage: "list.dash") {
                MyLocationsView()
            }
        }
    }
}

#Preview {
    TabBar()
}

//
//  BannerModifier.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/31/25.
//

import SwiftUI

struct BannerModifier: ViewModifier {
    
    struct BannerData {
        var title: String
        var detail: String
        var type: BannerType
    }
    
    enum BannerType {
        case info
        case warning
        case success
        case error
        
        var tintColor: Color {
            switch self {
                case .info:
                    return .blue
                case .success:
                    return .green
                case .warning:
                    return .yellow
                case .error:
                    return .red
            }
        }
    }
    
    @Binding var data: BannerData
    @Binding var showing: Bool
    
    @State private var animationValue: Int = 1
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if showing {
                VStack {
                    VStack(alignment: .leading ) {
                        Text(data.title)
                            .bold()
                        
                        Text(data.detail)
                            .font(.system(size: 15, weight: .light))
                    }
                    .foregroundStyle(.bg)
                    .padding(12)
                    .background(data.type.tintColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )
                }
                .animation(.easeInOut, value: animationValue)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.showing = false
                    }
                }.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        withAnimation {
                            self.showing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func banner(data: Binding<BannerModifier.BannerData>, showing: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, showing: showing))
    }
}

#Preview {
    VStack {
        Text("Hello World")
    }
    .banner(data: .constant(BannerModifier.BannerData(title: "Error", detail: "This is an error banner when something goes horribly wrong", type: .error)), showing: .constant(true))
}

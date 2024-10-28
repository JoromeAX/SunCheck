//
//  WeatherDetailView.swift
//  SunCheck
//
//  Created by Roman Khancha on 20.10.2024.
//

import SwiftUI

struct WeatherDetailView: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .bold()
        }
    }
}

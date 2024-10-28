//
//  MainView.swift
//  SunCheck
//
//  Created by Roman Khancha on 12.10.2024.
//

import SwiftUI
import Alamofire
import CoreLocation

struct MainView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var cityName = ""
    @State private var newCityName = ""
    @State private var temperature = "--°C"
    @State private var weatherDescription = ""
    @State private var icon = ""
    @State private var feels_like = "--°C"
    @State private var temp_min = "--°C"
    @State private var temp_max = "--°C"
    @State private var pressure = "--hPa"
    @State private var humidity = "--%"
    @State private var windSpeed = "--m/s"
    @State private var windDeg = "--°"
    @State private var sunrise = "--"
    @State private var sunset = "--"
    
    var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(gradient: Gradient(colors: [.indigo, .black]), startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom)
        }
    }
    
    let weatherService = WeatherService()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            fetchWeatherByLocation()
                        }) {
                            Image(systemName: "location")
                                .padding()
                                .foregroundColor(.white)
                        }
                        
                        TextField("Enter city", text: $newCityName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .frame(width: 200)
                        
                        Button(action: {
                            cityName = newCityName
                            fetchWeather()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding()
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 20)
                    
                    Text(cityName)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 30)
                    
                    Text(temperature)
                        .font(.system(size: 80))
                        .bold()
                        .padding(.vertical, 10)
                    
                    Text(weatherDescription.capitalized)
                        .font(.title2)
                        .padding(.bottom, 30)
                    
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")){ result in
                        result.image?
                            .resizable()
                    }
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 15) {
                        HStack {
                            WeatherDetailView(title: "Min Temp", value: temp_min)
                            Spacer()
                            WeatherDetailView(title: "Max Temp", value: temp_max)
                        }
                        
                        HStack {
                            WeatherDetailView(title: "Feels Like", value: feels_like)
                            Spacer()
                            WeatherDetailView(title: "Pressure", value: pressure)
                        }
                        
                        HStack {
                            WeatherDetailView(title: "Wind Degree", value: windDeg)
                            Spacer()
                            WeatherDetailView(title: "Wind Speed", value: windSpeed)
                        }
                        
                        HStack {
                            WeatherDetailView(title: "Sunrise", value: sunrise)
                            Spacer()
                            WeatherDetailView(title: "Sunset", value: sunset)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .onAppear {
                    loadLastCity()
                    fetchWeather()
                }
                .ignoresSafeArea()
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .refreshable {
                fetchWeather()
            }
        }
        .gesture(
            TapGesture()
                .onEnded{
                    hideKeyboard()
                }
        )
    }
    
    func loadLastCity() {
        if let savedCity = UserDefaults.standard.string(forKey: "lastCityName") {
            cityName = savedCity
        } else {
            cityName = "Kyiv"
        }
    }
    
    func saveLastCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: "lastCityName")
    }
    
    func fetchWeatherByLocation() {
        guard let location = locationManager.userLocation else {
            if let cachedData = CoreDataManager.shared.fetchWeather(for: cityName) {
                cityName = cachedData.cityName ?? "N/A"
                temperature = "\(Int(cachedData.temperature))°C"
                weatherDescription = cachedData.weatherDescription ?? "N/A"
            } else {
                print("No cached data found for city: \(cityName)")
            }
            return
        }
        
        weatherService.fetchWeather(forLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { weatherData in
            guard let weatherData = weatherData else {
                if let cachedData = CoreDataManager.shared.fetchWeather(for: cityName) {
                    cityName = cachedData.cityName ?? "N/A"
                    temperature = "\(Int(cachedData.temperature))°C"
                    weatherDescription = cachedData.weatherDescription ?? "N/A"
                } else {
                    print("No cached data found for city: \(cityName)")
                }
                return
            }
            
            DispatchQueue.main.async {
                updateUI(with: weatherData)
                CoreDataManager.shared.saveWeather(cityName: weatherData.name, temperature: weatherData.main.temp, description: weatherData.weather.first?.description ?? "")
                saveLastCity(weatherData.name)
            }
        }
    }
    
    func fetchWeather() {
        weatherService.fetchWeather(for: cityName) { weatherData in
            guard let weatherData = weatherData else {
                if let cachedData = CoreDataManager.shared.fetchWeather(for: cityName) {
                    DispatchQueue.main.async {
                        cityName = cachedData.cityName ?? "N/A"
                        temperature = "\(Int(cachedData.temperature))°C"
                        weatherDescription = cachedData.weatherDescription ?? "N/A"
                    }
                } else {
                    print("No cached data found for city: \(cityName)")
                }
                return
            }
            
            DispatchQueue.main.async {
                updateUI(with: weatherData)
                CoreDataManager.shared.saveWeather(cityName: weatherData.name, temperature: weatherData.main.temp, description: weatherData.weather.first?.description ?? "")
                saveLastCity(weatherData.name)
            }
        }
    }
    
    func updateUI(with data: WeatherDataModel) {
        cityName = data.name
        temperature = "\(Int(data.main.temp))°C"
        weatherDescription = data.weather.first?.description ?? "N/A"
        icon = data.weather.first?.icon ?? "01\(colorScheme == .light ? "d" : "n")"
        feels_like = "\(Int(data.main.feels_like))°C"
        temp_min = "\(Int(data.main.temp_min))°C"
        temp_max = "\(Int(data.main.temp_max))°C"
        pressure = "\(data.main.pressure)hPa"
        humidity = "\(data.main.humidity)%"
        
        windSpeed = "\(Int(data.wind.speed)) m/s"
        windDeg = "\(data.wind.deg)°"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        sunrise = "\(dateFormatter.string(from: Date(timeIntervalSince1970: data.sys.sunrise)))"
        sunset = "\(dateFormatter.string(from: Date(timeIntervalSince1970: data.sys.sunset)))"
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

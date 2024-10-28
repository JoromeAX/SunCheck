//
//  WeatherService.swift
//  SunCheck
//
//  Created by Roman Khancha on 12.10.2024.
//

import Foundation
import Alamofire

class WeatherService {
    private let apiKey = "YOUR API KEY"
    
    func fetchWeather(for city: String, completion: @escaping (WeatherDataModel?) -> Void) {
        let url = "https://api.openweathermap.org/data/2.5/weather"
        let parameters: [String: String] = [
            "q": city,
            "appid": apiKey,
            "units": "metric"
        ]
        
        AF.request(url, parameters: parameters)
            .validate()
            .responseDecodable(of: WeatherDataModel.self) { response in
                switch response.result {
                case .success(let weatherData):
                    completion(weatherData)
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                    completion(nil)
                }
            }
    }
    
    func fetchWeather(forLatitude latitude: Double, longitude: Double, completion: @escaping (WeatherDataModel?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        AF.request(urlString).responseDecodable(of: WeatherDataModel.self) { response in
            completion(response.value)
        }
    }
}

//
//  CoreDataManager.swift
//  SunCheck
//
//  Created by Roman Khancha on 14.10.2024.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "SunCheckModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading CoreData: \(error)")
            }
        }
    }
    
    func saveWeather(cityName: String?, temperature: Double?, description: String?) {
        guard let cityName = cityName, !cityName.isEmpty else {
            print("Invalid city name. Weather data not saved.")
            return
        }
        
        let context = persistentContainer.viewContext
        let weatherEntity = NSEntityDescription.insertNewObject(forEntityName: "WeatherEntity", into: context) as! WeatherEntity
        
        weatherEntity.cityName = cityName
        weatherEntity.temperature = temperature ?? 0.0
        weatherEntity.weatherDescription = description ?? "N/A"
        
        do {
            try context.save()
            print("Weather data saved successfully.")
        } catch {
            print("Failed to save weather data: \(error.localizedDescription)")
        }
    }
    
    func fetchWeather(for city: String) -> WeatherEntity? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WeatherEntity> = WeatherEntity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "cityName == %@", city)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let weatherData = results.first {
                print("Weather data found for city: \(city)")
                return weatherData
            } else {
                print("No cached data found for city: \(city)")
                return nil
            }
        } catch {
            print("Failed to fetch weather data: \(error.localizedDescription)")
            return nil
        }
    }
}

//
//  Created by Jake Lin on 8/26/15.
//  Copyright © 2015 Jake Lin. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class WeatherViewModel {
    // MARK: - Constants
    private let EmptyString = ""
  
    // MARK: - Properties
    let hasError = Variable(false)
    let errorMessage: Variable<String?> = Variable(nil)
  
  
    let location = Variable("")
    let iconText = Variable("")
    let temperature = Variable("")
    let forecasts: Variable<[Forecast]> = Variable([])
  
    // MARK: - Services
    private var locationService: LocationService
    private var weatherService: WeatherServiceProtocol
  
    // MARK: - init
    init() {
      // Can put Dependency Injection here
      locationService = LocationService()
      weatherService = OpenWeatherMapService()
    }
  
    // MARK: - public
    func startLocationService() {
        locationService.delegate = self
        locationService.requestLocation()
    }
  
    // MARK: - private
    private func update(weather: Weather) {
        hasError.value = false
        errorMessage.value = nil
      
        location.value = weather.location
        iconText.value = weather.iconText
        temperature.value = weather.temperature

        forecasts.value = weather.forecasts
    }
  
    private func update(error: Error) {
        hasError.value = true
      
        switch error.errorCode {
        case .URLError:
          errorMessage.value = "The weather service is not working."
        case .NetworkRequestFailed:
          errorMessage.value = "The network appears to be down."
        case .JSONSerializationFailed:
          errorMessage.value = "We're having trouble processing weather data."
        case .JSONParsingFailed:
          errorMessage.value = "We're having trouble parsing weather data."
        }
      
        location.value = EmptyString
        iconText.value = EmptyString
        temperature.value = EmptyString
        self.forecasts.value = []
    }
}

// MARK: LocationServiceDelegate
extension WeatherViewModel: LocationServiceDelegate {
    func locationDidUpdate(service: LocationService, location: CLLocation) {
      weatherService.retrieveWeatherInfo(location) { weather, error in
        dispatch_async(dispatch_get_main_queue()) {
          if let unwrappedError = error {
            print(unwrappedError)
            self.update(unwrappedError)
            return
          }
        
          guard let unwrappedWeather = weather else {
            return
          }
          self.update(unwrappedWeather)
        }
      }
    }
}

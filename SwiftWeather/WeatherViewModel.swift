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
    let forecasts: Variable < [Forecast] > = Variable([])

    // MARK: - Services
    private var locationService: kLocationService
    private var weatherService: OpenWeatherMapService

    private let locationManager = CLLocationManager()

    private let disposeBag = DisposeBag()

    // MARK: - init
    init() {
        locationService = kLocationService()
        weatherService = OpenWeatherMapService()

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        /// 位置更新事件
        locationManager.rx_didUpdateLocations
          /**
          *  For more, see
          *  https://github.com/RxSwiftCommunity/RxOptional
          */
            .flatMap { locations -> Observable<CLLocation> in
                if let location = locations.first {
                    return Observable.just(location)
                } else {
                    return Observable.empty()
                }
            }
            .flatMap { OpenWeatherMapService.rx_retrieveWeatherInfo($0) }
            .observeOn(MainScheduler.instance)
            .bindNext { [unowned self] weather in
                self.hasError.value = false
                self.errorMessage.value = nil

                self.location.value = weather.location
                self.iconText.value = weather.iconText
                self.temperature.value = weather.temperature

                self.forecasts.value = weather.forecasts
            }
            .addDisposableTo(disposeBag)
    }

    // MARK: - public
    func startLocationService() {
        locationService.delegate = self // 这是什么鬼畜的问题！！！
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
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
extension WeatherViewModel: kLocationServiceDelegate { }

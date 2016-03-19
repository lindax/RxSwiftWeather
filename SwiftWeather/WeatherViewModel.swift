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
    private var locationService: kLocationService

    private let locationManager = CLLocationManager()

    private let disposeBag = DisposeBag()

    // MARK: - init
    init() {
        locationService = kLocationService()

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
            .doOnError { print($0) }
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
}

// MARK: LocationServiceDelegate
extension WeatherViewModel: kLocationServiceDelegate { }

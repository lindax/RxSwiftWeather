//
//  WeatherServiceProtocol.swift
//  SwiftWeather
//
//  Created by 宋宋 on 16/3/20.
//  Copyright © 2016年 Jake Lin. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

typealias WeatherCompletionHandler = (Weather?, Error?) -> Void

protocol RxWeatherServiceProtocol {
    func rx_retrieveWeatherInfo(location: CLLocation) -> Observable<Weather>
}

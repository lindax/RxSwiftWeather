//
// Created by Jake Lin on 9/2/15.
// Copyright (c) 2015 Jake Lin. All rights reserved.
//

import Foundation
import CoreLocation

import SwiftyJSON
import RxSwift
import RxCocoa

struct OpenWeatherMapService {
    private static let urlPath = "http://api.openweathermap.org/data/2.5/forecast"

    static func rx_retrieveWeatherInfo(location: CLLocation) -> Observable<Weather> {

        guard let url = generateRequestURL(location) else {
            return Observable.error(Error(errorCode: .URLError))
        }

        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()

        return session.rx_response(request).map { (data, _) -> Weather in
            let json = JSON(data: data)
            guard let tempDegrees = json["list"][0]["main"]["temp"].double,
                country = json["city"]["country"].string,
                city = json["city"]["name"].string,
                weatherCondition = json["list"][0]["weather"][0]["id"].int,
                iconString = json["list"][0]["weather"][0]["icon"].string else {
                    throw Error(errorCode: .JSONParsingFailed)
            }

            var weatherBuilder = WeatherBuilder()
            let temperature = Temperature(country: country, openWeatherMapDegrees: tempDegrees)
            weatherBuilder.temperature = temperature.degrees
            weatherBuilder.location = city

            let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
            weatherBuilder.iconText = weatherIcon.iconText

            var forecasts: [Forecast] = []
            // Get the first four forecasts
            for index in 0 ... 3 {
                guard let forecastTempDegrees = json["list"][index]["main"]["temp"].double,
                    rawDateTime = json["list"][index]["dt"].double,
                    forecastCondition = json["list"][index]["weather"][0]["id"].int,
                    forecastIcon = json["list"][index]["weather"][0]["icon"].string else {
                        break
                }

                let forecastTemperature = Temperature(country: country, openWeatherMapDegrees: forecastTempDegrees)
                let forecastTimeString = ForecastDateTime(rawDateTime).shortTime
                let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
                let forcastIconText = weatherIcon.iconText

                let forecast = Forecast(time: forecastTimeString,
                    iconText: forcastIconText,
                    temperature: forecastTemperature.degrees)

                forecasts.append(forecast)
            }

            weatherBuilder.forecasts = forecasts

            return weatherBuilder.build()
        }
    }

    private static func generateRequestURL(location: CLLocation) -> NSURL? {
        guard let components = NSURLComponents(string: urlPath) else {
            return nil
        }

        // get appId from Info.plist
        let filePath = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")!
        let parameters = NSDictionary(contentsOfFile: filePath)
        let appId = parameters!["OWMAccessToken"]!.description

        components.queryItems = [NSURLQueryItem(name: "lat", value: String(location.coordinate.latitude)),
            NSURLQueryItem(name: "lon", value: String(location.coordinate.longitude)),
            NSURLQueryItem(name: "appid", value: String(appId))]

        return components.URL
    }
}

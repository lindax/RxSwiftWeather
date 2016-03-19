//
//  Created by Jake Lin on 8/18/15.
//  Copyright © 2015 Jake Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet var forecastViews: [ForecastView]!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = WeatherViewModel()

        viewModel.location.asObservable()
            .bindTo(locationLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.iconText.asObservable()
            .bindTo(iconLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.temperature.asObservable()
            .bindTo(temperatureLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.forecasts.asObservable() // For more you can use `of` & `merge`
            .filter { $0.count >= 4 }
            .bindNext { forecastModels in
                for (index, forecastView) in self.forecastViews.enumerate() {
                    forecastView.timeLabel.text = forecastModels[index].time
                    forecastView.iconLabel.text = forecastModels[index].iconText
                    forecastView.temperatureLabel.text = forecastModels[index].temperature
                }
            }
            .addDisposableTo(disposeBag)

        viewModel.startLocationService()
    }

    // MARK: - Status Bar Style

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

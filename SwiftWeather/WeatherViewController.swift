//
//  Created by Jake Lin on 8/18/15.
//  Copyright © 2015 Jake Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
  
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet var forecastViews: [ForecastView]!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = WeatherViewModel()
        
        viewModel.startLocationService()
        
        viewModel.location.asObservable()
            .bindTo(locationLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.iconText.asObservable()
            .bindTo(iconLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.temperature.asObservable()
            .bindTo(temperatureLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.forecasts.asObservable()
            .bindNext { forecastModels in
                if forecastModels.count >= 4 {
                    for (index, forecastView) in self.forecastViews.enumerate() {
                        forecastView.timeLabel.text = forecastModels[index].time
                        forecastView.iconLabel.text = forecastModels[index].iconText
                        forecastView.temperatureLabel.text = forecastModels[index].temperature
                    }
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

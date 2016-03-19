//
//  Created by Jake Lin on 9/2/15.
//  Copyright © 2015 Jake Lin. All rights reserved.
//

import Foundation
import CoreLocation
/**
 *  我丧失了理智
 */
protocol kLocationServiceDelegate {
	func locationDidUpdate(service: kLocationService, location: CLLocation)
}

extension kLocationServiceDelegate {
	func locationDidUpdate(service: kLocationService, location: CLLocation) { }
}

class kLocationService {
	var delegate: kLocationServiceDelegate?
}
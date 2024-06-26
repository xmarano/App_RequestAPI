//
//  RequestFunc.swift
//  RequestAPI
//
//  Created by Léo Grégori on 25/06/2024.
//

import Foundation
import CoreLocation

class SunriseSunset: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var city: String = ""
    @Published var status: String = ""
    @Published var sunrise: String = ""
    @Published var sunset: String = ""
    @Published var day_length: String = ""
    @Published var map_latitude: Double = 0
    @Published var map_longitude: Double = 0

    private var locationManager: CLLocationManager?
    private var geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }

    func fetchData() {
        locationManager?.startUpdatingLocation()
    }

    private func getData(from url: String) {
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }

            var result: Response?
            do {
                result = try JSONDecoder().decode(Response.self, from: data)
            } catch {
                print("failed to convert \(error.localizedDescription)")
            }

            guard let json = result else {
                return
            }

            DispatchQueue.main.async {
                self.status = json.status
                self.sunrise = json.results.sunrise
                self.sunset = json.results.sunset
                self.day_length = json.results.day_length
            }
        })
        task.resume()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        map_latitude = latitude
        map_longitude = longitude
        let url = "https://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&date=today"
        getData(from: url)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Failed to get city name: \(error.localizedDescription)")
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                DispatchQueue.main.async {
                    self.city = placemark.locality ?? "Unknown City"
                }
            }
        }
        locationManager?.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}

struct Response: Codable {
    let results: MyResult
    let status: String
}

struct MyResult: Codable {
    let sunrise: String
    let sunset: String
    let solar_noon: String
    let day_length: String
    let civil_twilight_begin: String
    let civil_twilight_end: String
    let nautical_twilight_begin: String
    let nautical_twilight_end: String
    let astronomical_twilight_begin: String
    let astronomical_twilight_end: String
}


// API JSON SUNRISE SUNSET
/*
{
  "results":
  {
    "sunrise":"7:27:02 AM",
    "sunset":"5:05:55 PM",
    "solar_noon":"12:16:28 PM",
    "day_length":"9:38:53",
    "civil_twilight_begin":"6:58:14 AM",
    "civil_twilight_end":"5:34:43 PM",
    "nautical_twilight_begin":"6:25:47 AM",
    "nautical_twilight_end":"6:07:10 PM",
    "astronomical_twilight_begin":"5:54:14 AM",
    "astronomical_twilight_end":"6:38:43 PM"
  },
   "status":"OK",
   "tzid": "UTC"
}
*/

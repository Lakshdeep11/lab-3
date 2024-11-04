//
//  ViewController.swift
//  lab 3
//
//  Created by Laksh Sandhu on 2024-11-02.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationText: UITextField!
    
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    
    var isCelsius = true
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        weatherCondition.isHidden = true
        temperature.isHidden = true
        location.isHidden = true
        toggle.isHidden = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
    }
    

    
    @IBAction func selfLocation(_ sender: UIButton) {
        weatherCondition.isHidden = false
        temperature.isHidden = false
        location.isHidden = false
        toggle.isHidden = false
        locationManager.requestLocation()
    }
    
    
    
    
    @IBAction func toggleChange(_ sender: UISwitch) {
        isCelsius = sender.isOn
        if let location = locationText.text {
                    fetchWeather(for: location)
                }
    }
    
    @IBAction func searchButton(_ sender: Any) {
        weatherCondition.isHidden = false
        temperature.isHidden = false
        location.isHidden = false
        toggle.isHidden = false
        if let location = locationText.text {
                    fetchWeather(for: location)
                }
    }
    
    func fetchWeather(for location: String) {
            let units = isCelsius ? "metric" : "imperial"
            let urlString = "https://api.weatherapi.com/v1/current.json?key=e0198de466064e7988523757240311&q=\(location)&units=\(units)"
            
            guard let url = URL(string: urlString) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching weather data: \(error)")
                    return
                }
                
                if let data = data {
                    self.parseWeatherData(data)
                }
            }
            
            task.resume()
        }

    func parseWeatherData(_ data: Data) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let location1 = json["location"] as? [String: Any],
                   let current = json["current"] as? [String: Any] {
                    
                    let locationName = location1["name"] as? String ?? ""
                    let temp = self.isCelsius ? current["temp_c"] as? Double ?? 0.0 : current["temp_f"] as? Double ?? 0.0
                    let condition = current["condition"] as? [String: Any]
                    let conditionText = condition?["text"] as? String ?? ""
                    let iconCode = condition?["code"] as? Int ?? 1003
                    
                    
                    DispatchQueue.main.async {
                        self.location.text = locationName
                        self.temperature.text = "\(temp)° \(self.isCelsius ? "C" : "F" )"
                        self.weatherCondition.text = conditionText
                        self.updateWeatherIcon(iconCode)
                    }
                }
            } catch {
                print("Error parsing weather data: \(error)")
            }
        }

    func updateWeatherIcon(_ code: Int) {
            switch code {
            case 1003: // Partly Cloudy
                weatherImage.image = UIImage(systemName: "cloud.sun.fill") // SF Symbol example
            case 1006: // Cloudy
                weatherImage.image = UIImage(systemName: "cloud.fill")
            case 1072, 1150, 1153, 1180: // Drizzle
                    weatherImage.image = UIImage(systemName: "cloud.drizzle.fill")
                    
                case 1087: // Thunderstorm
                    weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                    
                case 1114, 1216, 1219: // Blowing Snow
                    weatherImage.image = UIImage(systemName: "wind.snow")
                    
                case 1135, 1147: // Foggy
                    weatherImage.image = UIImage(systemName: "cloud.fog.fill")
                    
                case 1168, 1195, 1243: // Freezing Rain / Heavy Rain
                    weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                    
                case 1216, 1225: // Snow
                    weatherImage.image = UIImage(systemName: "snow")
                    
                case 1246, 1273, 1276: // Thunderstorms with Rain
                    weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                    
            default:
                weatherImage.image = UIImage(systemName: "cloud.fill")
            }
        weatherImage.tintColor = UIColor.systemBlue
        }
    
    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                fetchWeather(for: "\(lat),\(lon)")
            }
        }
        
    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get location: \(error)")
        }
}


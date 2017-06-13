//
//  Weather.swift
//  Weather Test
//
//  Created by Beecher Adams on 6/8/17.
//  Copyright © 2017 Beecher Adams. All rights reserved.
//

import UIKit
import CoreLocation

class Weather: UIViewController, CLLocationManagerDelegate
{
    // ui elements
    @IBOutlet var background:UIImageView?;
    @IBOutlet var currentTemp:UILabel?;
    @IBOutlet var lowTemp:UILabel?;
    @IBOutlet var highTemp:UILabel?;
    @IBOutlet var unitButton:UIButton?;
    @IBOutlet var zipCodeField:UITextField?;
    
    // data
    var zipCode:String = "94588"; // if location services are disabled
    var unit:Int = 0;
    
    // location manager to get current zip 
    let locationMng = CLLocationManager()
    
    // when go is pressed
    @IBAction func zipChanged(sender: AnyObject) {
        // get input from zipCodeField
        if(zipCodeField?.text?.characters.count == 5)
        {
            zipCode = (zipCodeField?.text!)!
            loadWeather(zip: zipCode, unit: unit)
        }
        else
        {
            // tell user they need to input valid zip
            let alert = UIAlertController(title: "Invalid Zip", message: "Please enter valid zipcode", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // refresh 
    @IBAction func refreshPressed(sender: AnyObject)
    {
        loadWeather(zip: zipCode, unit: unit)
    }
    
    // toggle f/c
    @IBAction func toggleUnit(sender: AnyObject)
    {
        if(unit == 0)
        {
            unit = 1
            self.unitButton?.setTitle("C", for: .normal)
        }
        else
        {
            unit = 0
            self.unitButton?.setTitle("F", for: .normal)
        }
        
        loadWeather(zip: zipCode, unit: unit)
    }
    
    // function to convert kevlin to fahrenheit
    func toFahrenheit(temp: Double) -> Double
    {
        return temp * (9/5) - 459.67
    }
    
    // function to convert kevlin to celcius
    func toCelcius(temp: Double) -> Double
    {
        return temp - 273.15
    }
    
    // load function
    func loadWeather(zip: String, unit: Int)
    {
        let weatherAPI:String = NSString.init(format: "http://api.openweathermap.org/data/2.5/weather?zip=%@&APPID=5a3918785d73f21fe53702080fbfaaa6", zip) as String
        
        // init URL Session
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask: URLSessionDataTask?
        
        // set network indicator to true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // create URL 
        let url = NSURL(string: weatherAPI)
        
        // now start data task 
        dataTask = defaultSession.dataTask(with: url! as URL)
        {
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    if let dictionary = json as? [String: Any] {
                        // set temp
                        if let temperatureDict = dictionary["main"] as? [String: Any]
                        {
                            // set current temp
                            if let currentTempDouble = temperatureDict["temp"] as? Double
                            {
                                DispatchQueue.main.async()
                                {
                                    if(unit == 0)
                                    {
                                        self.currentTemp?.text = String(self.toFahrenheit(temp: currentTempDouble))
                                    }
                                    else
                                    {
                                        self.currentTemp?.text = String(self.toCelcius(temp: currentTempDouble))
                                    }
                                }
                            }
                            
                            // set min temp
                            if let minTempDouble = temperatureDict["temp_min"] as? Double
                            {
                                DispatchQueue.main.async()
                                {
                                    if(unit == 0)
                                    {
                                        self.lowTemp?.text = String(format: "Low: %.2f", self.toFahrenheit(temp: minTempDouble))
                                    }
                                    else
                                    {
                                        self.lowTemp?.text = String(format: "Low: %.2f", self.toCelcius(temp: minTempDouble))
                                    }
                                }
                            }
                            
                            // set max temp
                            if let maxTempDouble = temperatureDict["temp_max"] as? Double
                            {
                                DispatchQueue.main.async()
                                {
                                    if(unit == 0)
                                    {
                                        self.highTemp?.text = String(format: "High: %.2f", self.toFahrenheit(temp: maxTempDouble))
                                    }
                                    else
                                    {
                                        self.highTemp?.text = String(format: "High: %.2f", self.toCelcius(temp: maxTempDouble))
                                    }
                                }
                            }
                        }
                        
                        if let weatherDict = dictionary["weather"] as? [[String: Any]] {
                            for(temp) in weatherDict
                            {
                                // set image based on forcast
                                if let mainWeather = temp["main"] as? String {
                                    DispatchQueue.main.async()
                                    {
                                        if(mainWeather == "Atmosphere")
                                        {
                                            self.background?.image = UIImage(named: "Atmosphere")
                                        }
                                        else if(mainWeather == "Clear")
                                        {
                                            self.background?.image = UIImage(named: "Clear")
                                        }
                                        else if(mainWeather == "Clouds")
                                        {
                                            self.background?.image = UIImage(named: "Clouds")
                                        }
                                        else if(mainWeather == "Drizzle")
                                        {
                                            self.background?.image = UIImage(named: "Drizzle")
                                        }
                                        else if(mainWeather == "Rain")
                                        {
                                            self.background?.image = UIImage(named: "Rain")
                                        }
                                        else if(mainWeather == "Snow")
                                        {
                                            self.background?.image = UIImage(named: "Snow")
                                        }
                                        else if(mainWeather == "Thunderstorm")
                                        {
                                            self.background?.image = UIImage(named: "Thunderstorm")
                                        }
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.async()
                        {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                }
            }
        }
        dataTask?.resume()
    }
    
    // get current location
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        // get zip code
        CLGeocoder().reverseGeocodeLocation(locations[0], completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                // set zip code and load weather 
                self.zipCode = pm.postalCode!
                self.zipCodeField?.text = pm.postalCode!
                self.loadWeather(zip: self.zipCode, unit: self.unit)
                
                // stop updating location 
                self.locationMng.stopUpdatingLocation()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init location manager and search for zip code
        self.locationMng.delegate = self
        self.locationMng.requestWhenInUseAuthorization()
        self.locationMng.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

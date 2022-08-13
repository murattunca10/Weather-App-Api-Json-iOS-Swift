//
//  ViewController.swift
//  Weather App
//
//  Created by Murat Tunca on 11.08.2022.
//

import UIKit

class ViewController: UIViewController {
    
    // Labels
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    // Views
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    // Get Button
    @IBOutlet weak var getButton: UIButton!
    
    // Clicked Animation
    func clickedAnimation(){
        UIView.animate(withDuration: 0.6,
            animations: {
                self.getButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6) {
                    self.getButton.transform = CGAffineTransform.identity
                }
            })
    }
    
    // Center Animation
    func pulseAnimation(){
            
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 0.5
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 0.25
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 1
        self.view1.layer.add(pulseAnimation, forKey: nil)
        self.view2.layer.add(pulseAnimation, forKey: nil)
        self.view3.layer.add(pulseAnimation, forKey: nil)
        self.view4.layer.add(pulseAnimation, forKey: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view1.layer.masksToBounds = true
        view2.layer.masksToBounds = true
        view3.layer.masksToBounds = true
        view4.layer.masksToBounds = true
        
        view1.layer.cornerRadius = 10
        view2.layer.cornerRadius = 10
        view3.layer.cornerRadius = 10
        view4.layer.cornerRadius = 10
        getButton.layer.cornerRadius = 10
    }
    
    var lat : String = "41" // -> latitude
    var lon : String = "29" // -> longitude

    @IBAction func getButton(_ sender: Any) {
        
        clickedAnimation() // -> Clicked Animaton
        pulseAnimation() // -> Pulse Animation
        api() // API & JSON call function
    }
    
    @IBAction func enterNewLocation(_ sender: Any) {
        let locationAlert = UIAlertController(title: "New Location", message: "Please enter latitude and longitude", preferredStyle: .alert)
        
        locationAlert.addTextField{ textField in
            textField.placeholder = "Enter Latitude"
            textField.keyboardType = .numberPad
        }
        
        locationAlert.addTextField{ textField2 in
            textField2.placeholder = "Enter Longitude"
            textField2.keyboardType = .numberPad
        }
        
        let showButton = UIAlertAction(title: "Show Results", style: .cancel) { [self] action in
            let textfield = locationAlert.textFields?[0]
            let textfield2 = locationAlert.textFields?[1]
            lat = (textfield?.text)!
            lon = (textfield2?.text)!
            
            pulseAnimation() // -> Pulse Animation
            api() // API & JSON call function
        }
        
        locationAlert.addAction(showButton)
        self.present(locationAlert, animated:  true)
    }
    
    // MARK: API & JSON
    
    func api(){
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon).18848118045779&appid=c22fed5b03526a3258d6ebf9d305090c")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!) {(data, response, error) in
            if error != nil{
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                if data != nil{
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
                        
                        DispatchQueue.main.async {
                            if let main = jsonResponse["main"] as? [String : Any]{
                                if let temp = main["temp"] as? Double{
                                    let tempInt = Int(temp)
                                    self.tempLabel.text = "\(tempInt - 273) C°" // KELVIN -> CELCIUS
                                }
                                if let humidity = main["humidity"] as? Int{
                                    self.humidityLabel.text = "% \(humidity)"
                                }
                            }
                            if let wind = jsonResponse["wind"] as? [String : Any]{
                                if let speed = wind["speed"] as? Double{
                                    let speedInt = Int(speed*1.6) // MPH -> KMH
                                    self.speedLabel.text = "\(speedInt) km/h"
                                }
                            }
                            if let location = jsonResponse["name"]{
                                self.locationLabel.text = location as? String
                            }
                            
                        }
                    }
                    
                    catch{
                        print("error")
                    }
                }
                
            }

        }
        task.resume()
    }
    
    
    
}


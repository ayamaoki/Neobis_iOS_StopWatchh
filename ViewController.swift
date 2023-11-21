//
//  StopwatchViewController.swift
//  Neobiss_iOS_StopWatch
//
//  Created by Yo on 5/11/23.
//

import UIKit

class StopwatchViewController: UIViewController {
    
    enum TimerMode {
        case timer , stopwatch
    }
    enum TimerStatus {
        case started, paused, stopped
    }
    
    @IBOutlet weak var timerImage: UIImageView!
    
    @IBOutlet weak var switchSegmentedControl: UISegmentedControl!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timePicker: UIPickerView!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var currentMode: TimerMode = .timer
    var currentStatus: TimerStatus = .stopped
    
    var timer = Timer()
    var timeIsStarted = Date()
    var timeIsPassed = DateComponents()
    var timerDuration: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker.delegate = self
        timePicker.dataSource = self
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if currentStatus != .started {
            timeIsStarted = Calendar.current.date(byAdding: timeIsPassed, to: Date()) ?? Date()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            currentStatus = .started
            
            if currentMode == .stopwatch {
                timePicker.isHidden = true
            }
        }
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        if currentStatus == .started {
            currentStatus = .paused
            timeIsPassed = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: (timeIsStarted))
            timer.invalidate()
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        timeIsPassed = DateComponents()
        timerLabel.text = String.toTimeString(0, 0, 0)
        currentStatus = .stopped

        if currentMode == .stopwatch {
            timePicker.isHidden = false
        }
    }
    
    @objc func updateTime() {
        let userCalendar = Calendar.current
        let currentTime = Date()
        let timeLeft = userCalendar.dateComponents([.hour, .minute, .second], from: (currentMode == .timer ? timeIsStarted : currentTime), to: currentMode == .timer ? currentTime : timeIsStarted + timerDuration)
        
        timerLabel.text = String.toTimeString(timeLeft.hour ?? 0, timeLeft.minute ?? 0, timeLeft.second ?? 0)
        if currentMode == .stopwatch && timeLeft.hour == 0 && timeLeft.minute == 0 && timeLeft.second == 0 {
            stopButtonTapped(stopButton)
            
        }
    }
    
    @IBAction func switchMode(_ sender: Any) {
        
        if  currentMode == TimerMode.timer {
            stopButtonTapped(stopButton)
            currentMode = TimerMode.stopwatch
            timePicker.isHidden = false
            timerImage.image = UIImage(systemName: "stopwatch")
        } else {
            stopButtonTapped(stopButton)
            currentMode = TimerMode.timer
            timePicker.isHidden = true
            timerImage.image = UIImage(systemName: "timer")
        }
    }
}
    
extension StopwatchViewController: UIPickerViewDataSource, UIPickerViewDelegate {
   public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
   public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       if component == 0 {
           return 100
       } else {
           return 60
       }
    }
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let hour = Int(pickerView.selectedRow(inComponent: 0))
        let minute = Int(pickerView.selectedRow(inComponent: 1))
        let second = Int(pickerView.selectedRow(inComponent: 2))
        
        timerLabel.text = String.toTimeString(hour, minute, second)
        timerDuration = TimeInterval(hour * 3600 + minute * 60 + second)
    }
}

extension String {
        static func toTimeString(_ hour: Int, _ minute: Int, _ second: Int) -> String {
            return "\(String(format: "%02d", hour)) : \(String(format: "%02d", minute)) : \(String(format: "%02d", second))"
        }
    }



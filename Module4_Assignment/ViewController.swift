//
//  ViewController.swift
//  Module4_Assignment
//
//  Created by Michael Medlin on 11/1/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController 
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        systemTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDateBackground()
        }
        //Default time is 60 seconds if user does not change time.
        timerPicker.countDownDuration = 60.0
        timerlabel.text = "Time remaining: " + timeRemainingToString(timeRemaining)
    }
    
    //Outlet for the system time label
    @IBOutlet weak var currentDate: UILabel!
    //Outlets for the timer, timer button and timer label
    @IBOutlet weak var timerPicker: UIDatePicker!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerlabel: UILabel!
    
    //variable to keep track of system time
    var systemTime: Timer?
    //variables to support functionality of the countdown timer
    var timer: Timer?
    var timeRemaining: TimeInterval = 0
    var isTimerRunning = false
    //variables to support function of the alarm    var audioPlayer: AVAudioPlayer?  
    var isAlarmPlaying = false
    var audioPlayer: AVAudioPlayer?
    
    //Changes the button from Start Timer, End Timer & Stop Music depending on status of timer
    @IBAction func timerButtonTapped(_ sender: Any)
    {
        //"End Timer" is tapped
        if isTimerRunning
        {
            //Stop timer
            timer?.invalidate()
            isTimerRunning = false
            timerButton.setTitle("Start Timer", for: .normal)
        }
        //"Stop Music" is tapped
        else if isAlarmPlaying
        {
            //Stop Alarm
            audioPlayer!.stop()
            isAlarmPlaying = false
            timerButton.setTitle("Start Timer", for: .normal)
        }
        //"Start Timer" is tapped
        else
        {
            //Update initial countdown
            timeRemaining = timerPicker.countDownDuration
            timerlabel.text =  "Time remaining: " + timeRemainingToString(timeRemaining)
            //Update countdown every second until it reaches 0
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
            { [weak self] _ in
                self?.timeRemaining -= 1.0
                self?.timerlabel.text =  "Time remaining: " + self!.timeRemainingToString(self!.timeRemaining)
                //Once timer reaches 0, stop coundown and play alarm
                if self!.timeRemaining <= 0
                {
                    self?.timer?.invalidate()
                    self?.isTimerRunning = false
                    self?.timerButton.setTitle("Stop Music", for: .normal)
                    self?.playAlarmSound()
                    self?.isAlarmPlaying = true
                }
            }
            isTimerRunning = true
            timerButton.setTitle("End Timer", for: .normal)
        }
    }
    //Calculates the time remaining on the timer
    func timeRemainingToString(_ timeInterval: TimeInterval) -> String
    {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    //Will set background to white in AM, gray in PM
    func updateDateBackground()
    {
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        let stringDate = timeFormatter.string(from :time)
        currentDate.text = stringDate
        
        let calender = Calendar.current
        let hour = calender.component(.hour, from: time)
        
        if hour >= 12
        {
            view.backgroundColor = UIColor.gray
        }
        else
        {
            view.backgroundColor = UIColor.white
        }
    }
    //Plays the alarm audio and calls the delegate method to detect the end of the audio clip
    func playAlarmSound()
    {
        let path = Bundle.main.url(forResource: "alarm", withExtension:"wav")
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: path!)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isAlarmPlaying = true
        }
        catch
        {
            print("Error Playing Audio")
        }
    }
}
//Extension needed to detect when the end of audio event is triggered
extension ViewController: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if flag && isAlarmPlaying
        {
            isAlarmPlaying = false
            DispatchQueue.main.async
            {
                self.timerButton.setTitle("Start Timer", for: .normal)
            }
        }
    }
}


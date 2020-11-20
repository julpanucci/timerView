//
//  ViewController.swift
//  TimerView
//
//  Created by Julian Panucci on 11/17/20.
//

import UIKit

fileprivate enum TimerViewState {
    case paused, playing, none
}

class TimerView: UIView {
    
    
    
    private var startTimer: Timer?
    private var pauseTimer: Timer?
    private var runCount: Double = 0
    
    let timerFireInterval = 1.0
    
    var totalTime: Int = 0
    var actualTimerTime: Int = 0
    var timePaused: Int = 0
    
    private var timerStartTime: Date? = Date()
    private var timerPauseTime = Date()
    
    let playButtonImage = UIImage(named: "play_button")
    let pauseImage = UIImage(named: "pause_button")
    
    private var state: TimerViewState = .none {
        didSet {
            switch state {
            case .paused:
                self.playPauseButton.setImage(playButtonImage, for: .normal)
                self.descriptionLabel.text = "Resume workout"
            case .playing:
                self.playPauseButton.setImage(pauseImage, for: .normal)
                self.descriptionLabel.text = "In progress"
            case .none:
                self.playPauseButton.setImage(playButtonImage, for: .normal)
                self.descriptionLabel.text = "Start Workout"
            }
        }
    }
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.playButtonImage, for: .normal)
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 0.0
        return button
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.text = "Start Workout"
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.text = "00:00"
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(playPauseButton)
        self.addSubview(descriptionLabel)
        self.addSubview(timeLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)

        
        setConstraints()
    }
    
    func findDateDiff(time1Str: String, time2Str: String) -> String {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "hh:mm a"

        guard let time1 = timeformatter.date(from: time1Str),
            let time2 = timeformatter.date(from: time2Str) else { return "" }

        //You can directly use from here if you have two dates

        let interval = time2.timeIntervalSince(time1)
        let hour = interval / 3600;
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        let intervalInt = Int(interval)
        return "\(intervalInt < 0 ? "-" : "+") \(Int(hour)) Hours \(Int(minute)) Minutes"
    }

    
    private func updateTimeLabel() {
        var (hours, minutes, seconds) = secondsToHoursMinutesSeconds(seconds: runCount)
        let hoursString = hours == 0 ? "" : "\(String(format: "%02d", hours)):"
        let minutesString = "\(String(format: "%02d", minutes)):"
        let secondsString = String(format: "%02d", seconds)
    
        self.timeLabel.text = "\(hoursString)\(minutesString)\(secondsString)"
        
    }
    
    private func secondsToHoursMinutesSeconds(seconds: Double) -> (Int, Int, Int) {
        let secondsInt = Int(seconds)
      return (secondsInt / 3600, (secondsInt % 3600) / 60, (secondsInt % 3600) % 60)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 22),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 22),
            descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -20),
            
            timeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 22),
            timeLabel.heightAnchor.constraint(equalToConstant: 42),
            timeLabel.topAnchor.constraint(equalTo: self.descriptionLabel.topAnchor, constant: 25),
            timeLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -20),
            
            playPauseButton.heightAnchor.constraint(equalToConstant: 55),
            playPauseButton.widthAnchor.constraint(equalToConstant: 55),
            playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playPauseButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupGradientLayer()
        
        self.bringSubviewToFront(playPauseButton)
        self.bringSubviewToFront(descriptionLabel)
        self.bringSubviewToFront(timeLabel)
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
          UIColor(red: 1, green: 0.668, blue: 0.025, alpha: 1).cgColor,
          UIColor(red: 0.963, green: 0.869, blue: 0.028, alpha: 0.9).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.48, b: 1.12, c: -1.12, d: 1.33, tx: 0.94, ty: -0.36))
        gradientLayer.bounds = self.bounds.insetBy(dx: -0.75 * self.bounds.size.width, dy: -1 * self.bounds.size.height)
        gradientLayer.position = self.center
        self.clipsToBounds = true
        
        self.layer.cornerRadius = 40
        
        
        let shadowLayer = CALayer()
        shadowLayer.shadowPath =  UIBezierPath(roundedRect: self.frame, cornerRadius: self.layer.cornerRadius).cgPath
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowOffset = CGSize(width: 4, height: 7)
        shadowLayer.shadowRadius = 4
        
        self.superview?.layer.insertSublayer(shadowLayer, at: 0)


      
        self.layer.addSublayer(gradientLayer)
    }
    
    @objc func fireStartTimer() {
        
        guard state == .playing else { return }
        
        runCount += 1

        
        print("Total time: \(self.runCount)")
        print("Actual time: \(self.actualTimerTime)\n")
        print("Paused time: \(self.timePaused)\n")
        
        
        
        updateTimeLabel()
    }
    
    private func startTime() {
        startTimer = Timer.scheduledTimer(timeInterval: timerFireInterval, target: self, selector: #selector(fireStartTimer), userInfo: nil, repeats: true)
        if timerStartTime == nil {
            timerStartTime = Date()
        }
        state = .playing
        
        RunLoop.main.add(startTimer!, forMode: .common)
    }
    
    private func stopTime() {
        startTimer?.invalidate()
        state = .paused
    }
    
    @objc private func playPauseButtonTapped() {
        if self.state == .paused || state == .none {
            self.startTime()
        } else if state == .playing {
            self.stopTime()
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rect = CGRect(x: 16, y: 100, width: view.bounds.width - 32.0, height: 93)
        
        let timerView = TimerView(frame: rect)
        self.view.addSubview(timerView)
        
        self.view.backgroundColor = .white
    }

}



extension TimerView {
    
    private func setTotalCountedTime(timeInterval: TimeInterval) {
        self.runCount = timeInterval
    }
    
    @objc private func willEnterForegroundNotification() {
        /// Check if background mode is activated
//        guard isActiveBackgroundMode else { return }
        
        if  state == .playing {
            if let timeInterval = calculateDateDiffrence() {
                self.setTotalCountedTime(timeInterval: timeInterval)
            }
        }
    }

    /// Calculate time diffrence between two date
    public func calculateDateDiffrence() -> TimeInterval? {
        guard let startTime = timerStartTime  else { return nil }
        let validTimeSubtraction = abs(startTime - Date())
        return validTimeSubtraction.convertToTimeInterval()
    }
}

extension TimeInterval {
    /// Cast TimeInterval to Int.
    func convertToInteger() -> Int {
        return Int(self)
    }
    /// Cast TimeInterval to String.
    func convertToString() -> String {
        return String(self)
    }
}

extension Int {
    /// Cast Int to TimeInterval
    func convertToTimeInterval() -> TimeInterval {
        return TimeInterval(self)
    }
    /// Cast Int to String
    func convertToString() -> String {
        return String(self)
    }
  
}

extension Double {
    /// Check the number is positive(bigger than zero)
    var isPositive: Bool {
        get {
            return self>0
        }
    }
    /// Cast Double to TimeInterval
    func convertToTimeInterval() -> TimeInterval {
        
        return TimeInterval(self)
    }
}

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    

}


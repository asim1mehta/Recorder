# Recorder

[![CI Status](http://img.shields.io/travis/Johannes Gorset/Recorder.svg?style=flat)](https://travis-ci.org/Johannes Gorset/Recorder)
[![Version](https://img.shields.io/cocoapods/v/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)
[![License](https://img.shields.io/cocoapods/l/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)
[![Platform](https://img.shields.io/cocoapods/p/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)

## Usage

```swift
class ViewController: UIViewController, AVAudioRecorderDelegate {
    var recording: Recording!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.recording = Recording(to: "recording.m4a", on: self)
    }

    func start()
    {
        self.recording.record()
    }

    func stop()
    {
        self.recording.stop()
    }

    func play()
    {
        self.recording.play()
    }

}
```

## Requirements

* Balls of steel (it's my first pod, and it's really bad).

## Installation

Recorder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Recorder"
```

## Author

Johannes Gorset, jgorset@gmail.com

## License

Recorder is available under the MIT license. See the LICENSE file for more info.

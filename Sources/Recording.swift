import AVFoundation
import QuartzCore

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
    @objc optional func audioMeterDidUpdate(dB: Float)
}

public class Recording : NSObject {

  public enum State: Int {
    case none, record, play
  }

  static var searchPathDirectory = FileManager.SearchPathDirectory.cachesDirectory
  static var directory: URL {
    return FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask)[0]
  }

  public weak var delegate: RecorderDelegate?
  public private(set) var url: URL
  public private(set) var state: State = .none

  public var bitRate = 192000
  public var sampleRate = 44100.0
  public var channels = 1

  private let session = AVAudioSession.sharedInstance()
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer?
  private var link: CADisplayLink?

  var metering: Bool {
    return delegate?.audioMeterDidUpdate != nil
  }

  // MARK: - Initializers

  public init(toFile file: String) {
    url = Recording.directory.appendingPathComponent(file)
    super.init()
  }

  // MARK: - Record

  public func prepare() throws {
    let settings: [String: Any] = [
        AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
      AVEncoderBitRateKey: bitRate,
      AVNumberOfChannelsKey: channels,
      AVSampleRateKey: sampleRate
    ]

    recorder = try AVAudioRecorder(url: url, settings: settings)
    recorder?.prepareToRecord()
    recorder?.delegate = delegate
    recorder?.isMeteringEnabled = metering
  }

  public func record() throws {
    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
    
    if recorder == nil {
      try prepare()
    }

    recorder?.record()
    state = .record

    if metering {
      startMetering()
    }
  }
    
    public func cancelRecording() throws {
        switch state {
        case .record:
            stop()
            try FileManager.default.removeItem(at: url)
        default:
            break
        }
    }

  // MARK: - Playback

  public func play() throws {
    try session.setCategory(AVAudioSessionCategoryPlayback)

    player = try AVAudioPlayer(contentsOf: url)
    player?.play()
    state = .play
  }

  public func stop() {
    switch state {
    case .play:
      player?.stop()
      player = nil
    case .record:
      recorder?.stop()
      recorder = nil
      stopMetering()
    default:
      break
    }

    state = .none
  }

  // MARK: - Metering

  @objc func updateMeter() {
    guard let recorder = recorder else { return }

    recorder.updateMeters()

    let dB = recorder.averagePower(forChannel: 0)

    delegate?.audioMeterDidUpdate?(dB: dB)
  }

  private func startMetering() {
    link = CADisplayLink(target: self, selector: #selector(updateMeter))
    link?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
  }

  private func stopMetering() {
    link?.invalidate()
    link = nil
  }
}

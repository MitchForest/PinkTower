import Foundation
import AVFoundation

protocol AudioRecorderServiceProtocol {
    var isRecording: Bool { get }
    func start() throws
    func stop() -> URL?
}

final class AudioRecorderService: NSObject, AudioRecorderServiceProtocol, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    private(set) var isRecording: Bool = false
    private var outputURL: URL?

    func start() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("observation-\(UUID().uuidString).m4a")
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.delegate = self
        recorder?.prepareToRecord()
        recorder?.record()
        outputURL = url
        isRecording = true
    }

    func stop() -> URL? {
        recorder?.stop()
        isRecording = false
        let url = outputURL
        outputURL = nil
        return url
    }
}



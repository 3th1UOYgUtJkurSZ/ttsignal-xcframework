///////////////////////////////////////////////////////////////////////////////
// file : TTSignalLog.swift
// author : anto
//
// Swift access to the bridge's logger. By default every log line goes to
// OSLog under subsystem "org.difft.ttsignal" / category "core" — this file
// only exists for clients that want a callback to surface logs in their UI
// (e.g. QUICTest). Mirrors the Config.LogHandler functional interface in
// src/java/.../Config.java.
///////////////////////////////////////////////////////////////////////////////

import Foundation
import TTSignalC

public enum TTSignalLog {

    public typealias LogSink = (TTSignalConfig.LogLevel, String) -> Void

    /// Last installed sink. Held here so we can keep the closure alive for
    /// the lifetime of its registration.
    private static var sinkBox: SinkBox?

    /// Install a Swift log sink. Pass nil to remove. The sink may fire
    /// from any thread — implementers are responsible for thread-hopping
    /// before touching UI.
    public static func setSink(_ sink: LogSink?) {
        if let sink {
            let box = SinkBox(sink: sink)
            sinkBox = box
            let ud = Unmanaged.passUnretained(box).toOpaque()
            tt_logger_set_callback(log_trampoline, ud)
        } else {
            tt_logger_set_callback(nil, nil)
            sinkBox = nil
        }
    }
}

private final class SinkBox {
    let sink: TTSignalLog.LogSink
    init(sink: @escaping TTSignalLog.LogSink) { self.sink = sink }
}

/// Map a BCLog level (the integer the C bridge passes to TTLogCallback,
/// deps/env/src/BC/BCLog.h: _FATAL_=0, _ERROR_=1, _WARN_=2, _INFO_=3,
/// _DEBUG_=4, _FINEST_=6) into the user-facing `TTSignalConfig.LogLevel`
/// enum (whose raw values are the Const.LOG_* filter numbers, NOT BCLog
/// levels). Without this map a BC ERROR (1) would be misread as DEBUG (1
/// in TTSignalConfig.LogLevel), etc.
private func mapBCLevelToLogLevel(_ bc: Int32) -> TTSignalConfig.LogLevel {
    switch bc {
    case 0: return .fatal   // _FATAL_
    case 1: return .error   // _ERROR_
    case 2: return .warn    // _WARN_
    case 3: return .info    // _INFO_
    case 4: return .debug   // _DEBUG_
    case 6: return .debug   // _FINEST_  (no separate enum case; treat as debug)
    default: return .info
    }
}

private func log_trampoline(userdata: UnsafeMutableRawPointer?,
                            level: Int32,
                            msg: UnsafePointer<CChar>?)
{
    guard let userdata = userdata else { return }
    let box = Unmanaged<SinkBox>.fromOpaque(userdata).takeUnretainedValue()
    let lvl = mapBCLevelToLogLevel(level)
    let s = msg.flatMap { String(cString: $0) } ?? ""
    box.sink(lvl, s)
}

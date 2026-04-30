# TTSignal — iOS binary distribution

This repository hosts the Swift Package Manager / CocoaPods distribution
channel for [`ttsignal`](https://github.com/3th1UOYgUtJkurSZ/ttsignal),
a high-performance QUIC signaling SDK built on top of xquic.

> **Read-only mirror.** All code under `Sources/` is auto-generated from
> the upstream repo by `ios/scripts/publish-to-release-repo.sh`. Open
> issues and PRs against `3th1UOYgUtJkurSZ/ttsignal`, not here.

## Current release

| | Value |
|---|---|
| Version | `1.0.20260430-1` |
| xcframework | [`ttsignal-swift.zip`](https://github.com/3th1UOYgUtJkurSZ/ttsignal-xcframework/releases/download/1.0.20260430-1/ttsignal-swift.zip) |
| SPM checksum | `9e203f7e2fc34d88e05961f05f9a21bbad77343deffba0f21e681875964a26bb` |
| SHA-256 | `9e203f7e2fc34d88e05961f05f9a21bbad77343deffba0f21e681875964a26bb` |
| Min iOS | 13.0 |
| Architectures | `ios-arm64`, `ios-arm64_x86_64-simulator` |

## Swift Package Manager

In Xcode → File → Add Packages, paste:

```
https://github.com/3th1UOYgUtJkurSZ/ttsignal-xcframework.git
```

Pin to the version above (or `from: "1.0.20260430-1"`). Or in
`Package.swift`:

```swift
.package(
    url: "https://github.com/3th1UOYgUtJkurSZ/ttsignal-xcframework.git",
    from: "1.0.20260430-1"
)
```

then

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "TTSignal", package: "ttsignal-xcframework")
    ]
)
```

`import TTSignal` exposes `TTSignalConnector`, `TTSignalConnection`,
`TTSignalStream`, `TTSignalConfig`, `TTSignalHandler`, `TTSignalLog` —
the full Swift API mirrors the Java/Android binding one-for-one.

## CocoaPods

```ruby
pod 'TTSignal', :git => 'https://github.com/3th1UOYgUtJkurSZ/ttsignal-xcframework.git', :tag => '1.0.20260430-1'
```

`pod install` runs `prepare_command` to fetch the xcframework from the
GitHub Release linked above and verifies its SHA-256 before installing.

## Layout

```
Package.swift                       SPM manifest (binaryTarget + source target)
TTSignal.podspec                    CocoaPods manifest
Sources/TTSignal/*.swift            Swift wrapper around the C++ core
LICENSE                             Distribution license
```

The native xcframework is **not** committed; it is fetched from the
matching GitHub Release tag at install time.

## Versioning

`1.0.20260430-1` follows `1.0.YYYYMMDD`, where the patch component
is the build day of the C++ SDK (mirrors the `__DATE__` macro baked into
`Utils.cpp`). All four platform artifacts produced on the same day —
iOS xcframework, Linux/macOS Node addons, Windows Node addon — share the
same release tag. The 3-segment shape is intentional: SwiftPM and
CocoaPods both reject 4-segment versions like `1.0.0.YYYYMMDD`.

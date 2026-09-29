# ADR-001 — Flutter for the mobile client

- Status: Accepted · Date: 2026-09-28

## Context
Android-first Indonesian market with iOS required. Heavy Arabic RTL text, audio playback in background, sensors
(compass), exact-time local notifications, and a possible on-device ASR (FFI to whisper.cpp) later.

## Decision
Flutter 3 (Dart 3) with Riverpod, go_router, drift, just_audio/audio_service, record, flutter_local_notifications.

## Consequences
+ Single codebase, consistent Arabic text rendering via bundled fonts, good FFI story for whisper.cpp / sherpa-onnx.
− Some platform work still native (share extension, exact alarms, boot receiver).
Alternative considered: React Native/Expo (viable; rejected for weaker Mushaf text layout control and FFI ergonomics).

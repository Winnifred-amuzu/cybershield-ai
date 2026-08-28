# Sprint 10 Release Candidate

This sprint focuses on real-device validation rather than adding another ML feature.

### Changes
- Hardened mobile authentication networking with timeout and controlled error handling.
- Added physical-device API configuration via `CYBERSHIELD_API_URL`.
- Added automated mobile release validation script.
- Added physical-device launch helper.
- Added Flutter unit tests for URL extraction.
- Improved share-service lifecycle handling to avoid duplicate subscriptions and callbacks after disposal.
- Added a complete end-to-end QA matrix and release evidence checklist.

### Important limitation
The repository does not include a generated Android SDK/platform directory because those files are environment-specific. Run the provided release script on a Windows machine with Flutter and Android tooling installed.

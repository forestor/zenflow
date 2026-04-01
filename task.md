# ZenFlow 명상 앱 개발

## 계획
- [x] 프로젝트 리서치 (명상 앱 기능 조사)
- [x] Flutter 프로젝트 생성 (`zen_flow`)
- [x] 구현 계획서 작성 및 사용자 승인

## 구현 - 핵심 기능 (MVP)
- [x] 앱 테마 및 디자인 시스템 ([lib/theme/app_theme.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/theme/app_theme.dart))
- [x] 데이터 모델 ([lib/models/meditation_record.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/models/meditation_record.dart))
- [x] 저장 서비스 ([lib/services/storage_service.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/services/storage_service.dart))
- [x] 오디오 서비스 ([lib/services/audio_service.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/services/audio_service.dart)) ✨ 추가됨
- [x] 호흡 원형 애니메이션 위젯 ([lib/widgets/animated_circle.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/widgets/animated_circle.dart))
- [x] 사운드 선택 위젯 ([lib/widgets/sound_selector.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/widgets/sound_selector.dart))
- [x] 홈 화면 ([lib/screens/home_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/home_screen.dart))
- [x] 명상 타이머 화면 + 오디오 연동 ([lib/screens/timer_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/timer_screen.dart))
- [x] 호흡 가이드 화면 ([lib/screens/breathing_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/breathing_screen.dart))
- [x] 통계 화면 ([lib/screens/stats_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/stats_screen.dart))
- [x] main.dart 진입점

## 검증
- [/] 사용자 확인 대기 (flutter pub get → flutter run -d chrome)

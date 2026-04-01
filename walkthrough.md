# ZenFlow 명상 앱 — 완료 Walkthrough

## 생성/수정된 파일 (13개)

| 파일 | 역할 |
|------|------|
| [pubspec.yaml](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/pubspec.yaml) | 패키지 의존성 추가 (shared_preferences, google_fonts, audioplayers) |
| [lib/main.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/main.dart) | 앱 진입점 |
| [lib/theme/app_theme.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/theme/app_theme.dart) | 다크 테마, 그라디언트, 색상 시스템 |
| [lib/models/meditation_record.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/models/meditation_record.dart) | 명상 기록 데이터 모델 |
| [lib/services/storage_service.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/services/storage_service.dart) | SharedPreferences 기반 로컬 저장 |
| [lib/services/audio_service.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/services/audio_service.dart) | 배경 사운드 재생 (audioplayers) |
| [lib/widgets/animated_circle.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/widgets/animated_circle.dart) | 호흡 원형 글로우 위젯 |
| [lib/widgets/sound_selector.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/widgets/sound_selector.dart) | 사운드 선택 UI |
| [lib/screens/home_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/home_screen.dart) | 홈 (요약 카드 + 퀵 액션 + 네비게이션) |
| [lib/screens/timer_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/timer_screen.dart) | 명상 타이머 + 사운드 재생 |
| [lib/screens/breathing_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/breathing_screen.dart) | 4-7-8 호흡 가이드 |
| [lib/screens/stats_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/stats_screen.dart) | 통계 (스트릭, 주간 차트, 기록 리스트) |
| [test/widget_test.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/test/widget_test.dart) | 기본 위젯 테스트 |

## 🎵 사운드 재생 기능

타이머 화면에서 사운드 선택 후 시작하면 **Pixabay 무료 사운드가 루프 재생**됩니다:
- 🌧️ 빗소리 — `rain`
- 🌊 파도소리 — `wave`
- 🐦 새소리(숲) — `bird`
- 🔇 고요함 — 무음

> 인터넷 연결이 필요합니다 (URL 기반 스트리밍)

## 🚀 실행 방법

```cmd
cd C:\Users\USER\.gemini\antigravity\playground\exo-observatory
flutter pub get
flutter run -d chrome
```

## 확인 포인트

1. ✅ 홈 화면 — 시간대별 인사말, 오늘 명상 시간, 스트릭
2. ✅ 타이머 — 시간 선택, 사운드 선택, 시작/멈춤/리셋
3. ✅ 사운드 — 빗소리/파도/새소리 실제 재생
4. ✅ 호흡 — 원형 애니메이션, 4-7-8 카운트다운
5. ✅ 통계 — 기록 저장, 주간 차트

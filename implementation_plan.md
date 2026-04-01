# ZenFlow 명상 앱 — 구현 계획서

## 🔴 멈춘 원인 설명

> [!NOTE]
> Antigravity의 터미널에서 `flutter create` 명령이 멈춘 것은 **명령 실행 타임아웃** 때문입니다.
> Flutter SDK 첫 실행 시 Dart 분석 서버, 컴파일 아티팩트 등을 생성하는 데 시간이 걸리며,
> Antigravity 터미널은 일정 시간 내에 완료되지 않으면 취소 상태로 처리합니다.
> 이는 Antigravity 제품의 제한사항이지 Flutter나 PC 문제가 아닙니다.
> **앞으로는 오래 걸리는 Flutter 명령은 외부 CMD에서 실행하시는 것을 권장합니다.**

---

## 목표

**ZenFlow** — 마음을 다스리는 명상 도우미 앱 MVP를 Flutter로 구현합니다.

### MVP 핵심 기능 4가지
1. **명상 타이머** — 5/10/15/20분 선택, 시작·멈춤·리셋
2. **호흡 가이드** — 4-7-8 호흡법 애니메이션 (들숨-참기-날숨)
3. **배경 사운드** — 빗소리, 파도, 새소리, 백색소음 (내장 아이콘으로 표현, 사운드 파일은 추후 추가)
4. **명상 기록** — 날짜, 시간, 타입 저장 및 간단한 통계

---

## 프로젝트 구조

```
lib/
├── main.dart                    ← 앱 진입점
├── theme/
│   └── app_theme.dart           ← [NEW] 다크 테마, 색상, 폰트
├── models/
│   └── meditation_record.dart   ← [NEW] 명상 기록 데이터 모델
├── services/
│   └── storage_service.dart     ← [NEW] SharedPreferences 기반 저장
├── screens/
│   ├── home_screen.dart         ← [NEW] 홈 화면 (네비게이션)
│   ├── timer_screen.dart        ← [NEW] 명상 타이머
│   ├── breathing_screen.dart    ← [NEW] 호흡 가이드
│   └── stats_screen.dart        ← [NEW] 통계 화면
└── widgets/
    ├── animated_circle.dart     ← [NEW] 호흡 원형 애니메이션
    └── sound_selector.dart      ← [NEW] 사운드 선택 위젯
```

---

## Proposed Changes

### 패키지 의존성

#### [MODIFY] [pubspec.yaml](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/pubspec.yaml)
- `shared_preferences` 추가 (명상 기록 로컬 저장)
- `google_fonts` 추가 (프리미엄 타이포그래피)

---

### 테마 & 디자인

#### [NEW] [app_theme.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/theme/app_theme.dart)
- 다크 모드 기반 (명상에 어울리는 어두운 테마)
- 보라/인디고 그라디언트 색상 팔레트
- Google Fonts 적용 (Outfit)

---

### 홈 화면

#### [NEW] [home_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/home_screen.dart)
- BottomNavigationBar로 3개 탭: 홈, 호흡, 통계
- 홈 탭: 오늘의 명상 요약 카드 + 타이머 시작 버튼
- 그라디언트 배경, 부드러운 전환 애니메이션

---

### 명상 타이머

#### [NEW] [timer_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/timer_screen.dart)
- 원형 프로그레스 타이머 (CustomPaint)
- 5/10/15/20분 선택 칩
- 시작/멈춤/리셋 버튼
- 완료 시 기록 자동 저장
- 배경 사운드 선택 통합

---

### 호흡 가이드

#### [NEW] [breathing_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/breathing_screen.dart)
- 4-7-8 호흡법: 들숨(4초) → 참기(7초) → 날숨(8초)
- 원형 확대·축소 애니메이션 (AnimationController)
- "들이쉬세요"/"참으세요"/"내쉬세요" 텍스트 가이드
- 사이클 카운터

#### [NEW] [animated_circle.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/widgets/animated_circle.dart)
- 호흡 단계에 따라 크기·색상이 변하는 원형 위젯

---

### 사운드 & 기록

#### [NEW] [sound_selector.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/widgets/sound_selector.dart)
- 4가지 사운드 아이콘 (빗소리🌧️, 파도🌊, 새소리🐦, 고요함🔇)
- 선택 시 하이라이트 효과 (실제 오디오 재생은 2단계에서)

#### [NEW] [meditation_record.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/models/meditation_record.dart)
- `date`, `durationMinutes`, `type` (타이머/호흡) 필드

#### [NEW] [storage_service.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/services/storage_service.dart)
- SharedPreferences 기반 CRUD
- JSON 직렬화/역직렬화

---

### 통계 화면

#### [NEW] [stats_screen.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/screens/stats_screen.dart)
- 총 명상 시간, 연속 일수 (스트릭)
- 최근 7일 명상 기록 리스트
- 간단한 바 차트 (직접 CustomPaint로 구현)

---

### 진입점

#### [MODIFY] [main.dart](file:///C:/Users/USER/.gemini/antigravity/playground/exo-observatory/lib/main.dart)
- 기존 카운터 코드 전체 대체
- `ZenFlowApp` 위젯으로 시작
- `HomeScreen`으로 라우팅

---

## Verification Plan

### Automated Tests
- `flutter analyze` 실행하여 정적 분석 오류 없음 확인
- 기존 `test/widget_test.dart`는 카운터 앱용이므로 새 테스트로 교체

### Manual Verification (사용자 직접 확인)
1. **외부 CMD**에서 아래 명령 실행:
   ```cmd
   cd C:\Users\USER\.gemini\antigravity\playground\exo-observatory
   flutter run -d chrome
   ```
2. 브라우저에서 확인할 것:
   - 홈 화면이 다크 테마로 표시되는지
   - 타이머 시작 → 카운트다운 → 완료 시 기록 저장
   - 호흡 가이드 원형 애니메이션 동작 확인
   - 통계 탭에서 기록 표시 확인

> [!IMPORTANT]
> Flutter 명령(`flutter run`, `flutter pub get` 등)은 **외부 CMD**에서 실행을 권장합니다.

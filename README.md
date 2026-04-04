# zen_flow

A mindfulness meditation app

## 핵심 기능 4가지
1. **명상 타이머** — 5/10/15/20분 선택, 시작·멈춤·리셋
2. **호흡 가이드** — 4-7-8 호흡법 애니메이션 (들숨-참기-날숨)
3. **배경 사운드** — 빗소리, 파도, 새소리, 백색소음 (내장 아이콘으로 표현, 사운드 파일은 추후 추가)
4. **명상 기록** — 날짜, 시간, 타입 저장 및 간단한 통계

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


## 기능 포인트

---

### 패키지 의존성
- `shared_preferences` 추가 (명상 기록 로컬 저장)
- `google_fonts` 추가 (프리미엄 타이포그래피)

---

### 테마 & 디자인
- 다크 모드 기반 (명상에 어울리는 어두운 테마)
- 보라/인디고 그라디언트 색상 팔레트
- Google Fonts 적용 (Outfit)

---

### 홈 화면
- BottomNavigationBar로 3개 탭: 홈, 호흡, 통계
- 홈 탭: 오늘의 명상 요약 카드 + 타이머 시작 버튼
- 그라디언트 배경, 부드러운 전환 애니메이션

---

### 명상 타이머
- 원형 프로그레스 타이머 (CustomPaint)
- 5/10/15/20분 선택 칩
- 시작/멈춤/리셋 버튼
- 완료 시 기록 자동 저장
- 배경 사운드 선택 통합

---

### 호흡 가이드
- 4-7-8 호흡법: 들숨(4초) → 참기(7초) → 날숨(8초)
- 원형 확대·축소 애니메이션 (AnimationController)
- "들이쉬세요"/"참으세요"/"내쉬세요" 텍스트 가이드
- 사이클 카운터
- 호흡 단계에 따라 크기·색상이 변하는 원형 위젯

---

### 사운드 & 기록
- 4가지 사운드 아이콘 (빗소리🌧️, 파도🌊, 새소리🐦, 고요함🔇)
- 선택 시 하이라이트 효과 (실제 오디오 재생은 2단계에서)
- SharedPreferences 기반 CRUD
- JSON 직렬화/역직렬화
---

### 통계 화면
- 총 명상 시간, 연속 일수 (스트릭)
- 최근 7일 명상 기록 리스트
- 간단한 바 차트 (직접 CustomPaint로 구현)

---



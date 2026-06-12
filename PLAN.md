# 하트시그널 개발 계획

> 현재 UI는 상당 부분 완성되었으나, **실제 기능(백엔드 연동, 데이터 동기화, 페어링 등)은 대부분 미구현** 상태입니다.

---

## 현재 상태 분석

### 완료된 것 ✅
- SwiftUI 기반 UI 레이아웃 (홈, 기록, 마이페이지, 알림)
- DesignSystem (Colors, Typography, Icons)
- 재사용 Components (TabBar, Card, Button 등)
- WatchOS 타겟 기본 구조
- HealthKit 심박수 읽기 (로컬)
- WatchConnectivity 기본 연결

### 미구현 / 하드코딩된 것 🔴

| 영역 | 현재 상태 | 문제 |
|------|----------|------|
| **페어링** | `CodeInputField` UI만 존재 | 실제 코드 생성/매칭 로직 없음 |
| **심박수 표시** | `"123"` bpm 고정 | 상대방 실시간 데이터 수신 안 됨 |
| **시그널(메시지)** | FAB 누륾 → `"병내기"` 시트만 뜸 | 전송/수신/푸시 알림 없음 |
| **기록** | `sampleEvents` 하드코딩 | Firestore 연동 없음 |
| **분석 탭** | `placeholderView("분석")` | 아예 기능 없음 |
| **알림** | `NotifItem.samples` | 실시간 푸시/읽음 처리 없음 |
| **위치** | `"대구광역시"` 고정 | CoreLocation 미연동 |
| **온보이딩** | 없음 | 앱 켜자마자 메인 화면 |
| **백엔드** | 없음 | Firebase/서버 전무 |

---

## 기술 스택

| 영역 | 선택 |
|------|------|
| 백엔드 | **Firebase** (Firestore + Auth + FCM + Functions) |
| 데이터베이스 | Firestore (실시간 동기화에 최적) |
| 푸시 알림 | Firebase Cloud Messaging |
| 차트 | Swift Charts (iOS 16+) |
| 위치 | CoreLocation |
| CI/CD | Xcode Cloud 또는 GitHub Actions |

---

## 개발 로드맵 (총 9주)

---

## Phase 1: 인프라 & 페어링 시스템 (2주)

**🎯 두 사람이 앱으로 연결될 수 있는 기반을 만든다.**

### Week 1-1: Firebase 설정 & 데이터 모델
- [ ] Firebase 프로젝트 생성
  - Firestore Database
  - Firebase Authentication (Anonymous)
  - Firebase Cloud Messaging
  - Firebase Storage (프로필 이미지 대비)
- [ ] `GoogleService-Info.plist` 프로젝트 연동 (iOS + WatchOS)
- [ ] Firestore 보안 규칙 초기 설정
- [ ] 데이터 모델 설계
  ```
  users/{uid}
    ├── nickname: String
    ├── code: String        // 6자리 페어링 코드
    ├── coupleId: String?
    ├── partnerId: String?
    ├── fcmToken: String
    ├── createdAt: Timestamp
    └── lastActiveAt: Timestamp

  couples/{coupleId}
    ├── userA: String       // uid
    ├── userB: String       // uid
    ├── createdAt: Timestamp
    └── status: String      // "active" | "disconnected"
  ```

### Week 1-2: 온볼딩 & 페어링
- [ ] **온볼딩 플로우** 구현
  - 최초 실행 시 닉네임 입력 화면
  - 6자리 랜덤 코드 자동 생성 (ex: `A3B9K2`)
  - "내 코드 공유하기" (ShareSheet)
  - "상대 코드 입력하기" (CodeInputField 연동)
- [ ] **페어링 로직**
  - 코드 입력 → `users` 컬렉션에서 `code` 필드 검색
  - 매칭 성공 시 `couples` 문서 생성
  - 양쪽 `user` 문서에 `coupleId`, `partnerId` 업데이트
  - 매칭 완료 화면 ("연결되었습니다 💓")
- [ ] **UserDefaults**에 온볼딩 완료 여부 저장 (`@AppStorage`)
- [ ] `Auth.auth().signInAnonymously()`로 익명 로그인 구현

---

## Phase 2: 실시간 심박수 연동 (2주)

**🎯 상대방의 심장 박동을 진짜로 볼 수 있게 한다.**

### Week 2-1: HealthKit → Firestore 업로드
- [ ] **WatchOS**: 심박수 측정 시 Firestore에 업로드
  - 컬렉션: `couples/{coupleId}/heartRates`
  - 문서: `{ userId, bpm, timestamp, source: "watch" }`
  - 백그라운드에서도 업로드되도록 `WKExtendedRuntimeSession` 유지
- [ ] **iOS**: 폰에서도 HealthKit 심박수 읽어서 업로드 (워치 없을 때 대비)
- [ ] `PhoneConnectivityManager` 개선
  - 워치가 데이터 본인도 Firestore에 직접 쓰도록 변경 (중계 구조 개선)

### Week 2-2: 실시간 수신 & 홈뷰 연동
- [ ] HomeView 하드코딩 제거
  - `"123"` → `partnerHeartRate` 실시간 바인딩
  - Firestore snapshot listener로 `couples/{id}/heartRates` 구독
  - 상대방 최신 데이터 1~3초 내 반영
- [ ] **심박수 이벤트 자동 감지** (Cloud Functions)
  - 평균 대비 +20% 상승 시 → `"heartRateRise"` 이벤트 자동 생성
  - 양쪽이 5분 내 동시 상승 시 → `"bothHeartRateRise"` 이벤트
  - 수면 감지 (50bpm 이하 지속) → `"sleep"` 이벤트
- [ ] 이벤트 자동 저장 → `couples/{id}/events` 컬렉션

---

## Phase 3: 시그널 & 상태 메시지 (2주)

**🎯 커플 간 감정을 교환할 수 있게 한다.**

### Week 3-1: 메시지 전송
- [ ] **FAB "병내기" 시트** 실제 구현
  - 템플릿 메시지 선택 UI
    - `"보고 싶어 💓"`
    - `"너에게 가는 중"`
    - `"잘 자 🌙"`
    - `"심장이 너 때문에 뛰어"`
  - 커스텀 텍스트 직접 입력
- [ ] **시그널 전송 파이프라인**
  - `couples/{id}/signals` 에 메시지 저장
  - FCM으로 상대방에게 푸시 알림 발송
  - 발송 성공 시 토스트 메시지
- [ ] **수신 처리**
  - 앱 foreground: 실시간 리스너로 홈/알림 탭 업데이트
  - 앱 background: FCM → 뱃지 + 알림센터 표시

### Week 3-2: 상태 메시지 & 알림
- [ ] **"나는 지금..." 상태 메시지 CRUD**
  - "추가하기" 버튼 실제 동작
  - emoji + 텍스트 입력 폼
  - 활성화된 상태 하나만 유지 (토글)
  - Firestore `users/{uid}/statusMessage` 동기화
- [ ] **알림 화면** 실제 데이터 연동
  - `NotifItem.samples` 제거
  - `couples/{id}/notifications` 구독
  - 읽음 처리: `isRead` 필드 업데이트
  - 삭제: 문서 삭제 + 애니메이션
  - 7일 후 자동 삭제: Firebase Cloud Functions 스케줄러

---

## Phase 4: 분석 탭 & 리포트 (1.5주)

**🎯 placeholder였던 분석 탭을 실제 기능으로 채운다.**

### Week 4-1: 심박수 리포트
- [ ] **분석 탭** 실제 화면 구현 (placeholder 제거)
- [ ] 주간 심박수 추이 차트 (Swift Charts)
  - 7일 평균 bpm 라인 그래프
  - 나 vs 상대 비교
- [ ] **하이라이트 카드**
  - "이번 주 가장 심장이 뛴 순간"
  - "우리가 가장 가까웠던 날"
- [ ] 월간 캘린더 연동
  - 기록뷰 `sampleEvents` 완전 제거
  - `couples/{id}/events` 실제 데이터 연동
  - 날짜별 도트 색상: 심박수 상승(핑크) / 시그널(브라운) / 수면(그레이)

### Week 4-2: 커플 통계
- [ ] 통계 카드
  - "이번 주 ○번 동시에 텐션이 올랐어요"
  - "평균 심박수: 나 ○○bpm / 상대 ○○bpm"
  - "가장 많이 심장이 뛴 요일"
- [ ] 기록 필터링
  - 전체 / 심박수 / 시그널 / 수면

---

## Phase 5: 마이페이지 & 설정 (1주)

**🎯 프로필과 앱 설정을 완성한다.**

- [ ] **프로필 수정**
  - 닉네임 변경
  - 프로필 이미지 (Firebase Storage 업로드)
  - 커플 연결 끊기 → `couples` status `"disconnected"`
- [ ] **알림 설정**
  - 푸시 알림 on/off
  - 심박수 알림 임계값 조절 (80bpm / 100bpm / 120bpm)
  - 시그널 수신 알림 on/off
- [ ] **위치 정보** (선택 기능)
  - `CoreLocation` 권한 요청
  - 실시간 거리 계산 → `"우리는 지금 ○○km 떨어져 있어요"`
  - Firestore `users/{uid}/location` 업데이트
- [ ] **앱 정보**
  - 버전 정보 (`ListItem` `.info(value:)` 연동)
  - 문의하기 (이메일 링크 또는 웹뷰)
  - 이용약관 / 개인정보처리방침 웹뷰

---

## Phase 6: Polish & 출시 준비 (1.5주)

**🎯 실제 사용자에게 배포할 수 있는 품질을 만든다.**

### Week 6-1: 상태 처리 & 피드백
- [ ] **Empty State**
  - 기록 없을 때: "이날은 기록이 없어요"
  - 시그널 없을 때: "아직 주고받은 시그널이 없어요"
  - 상대방 미연결: "상대방과 연결해주세요"
- [ ] **Error State**
  - 네트워크 끊김: "연결을 확인해주세요" + 재시도 버튼
  - 페어링 실패: 에러 메시지 + 코드 재입력 유도
- [ ] **Skeleton Loading**
  - 홈 심박수 카드 로딩 중 스켈레톤
  - 기록 목록 로딩 중 shimmer 효과
- [ ] **Haptic Feedback**
  - 시그널 받았을 때 (heavy)
  - 심박수 상승 감지 시 (light)
  - 페어링 성공 시 (success)

### Week 6-2: 오프라인 & 성능
- [ ] **오프라인 대응**
  - Firestore offline persistence 활성화
  - `@AppStorage`로 마지막 데이터 캐싱
  - 네트워크 복구 시 자동 동기화
- [ ] **메모리 누수 점검**
  - `[weak self]` 누락 부분 확인
  - snapshot listener 해제 (`onDisappear`)
- [ ] **배터리 최적화**
  - WatchOS 백그라운드 세션 주기 조정
  - Firestore 리스너 최적화 (필요한 필드만 구독)

### Week 6-3: 출시 준비
- [ ] **스플래시 화면** 최종 점검
- [ ] **앱 아이콘** 모든 사이즈 대응
- [ ] **TestFlight 배포**
  - 내부 테스터: 본인 + 파트너
  - 외부 테스터: 친구 커플 2~3팀
- [ ] **App Store Connect 설정**
  - 앱 이름, 설명, 키워드
  - 스크린샷 5장 (iPhone 6.7", 6.5", 5.5")
  - 프리뷰 영상 (선택)
- [ ] **심사 제출**

---

## 우선순위 요약

```
Phase 1 (인프라)     ████████████████████ MUST
Phase 2 (심박수)     ████████████████████ MUST
Phase 3 (시그널)     █████████████████░░░ SHOULD
Phase 4 (분석)       ██████████████░░░░░░ SHOULD
Phase 5 (설정)       ██████████░░░░░░░░░░ COULD
Phase 6 (출시)       ████████████████████ MUST
```

---

## 개발 팁

### WatchOS + iOS 데이터 흐름
```
[Apple Watch] → HealthKit → WatchConnectivity
                                    ↓
[Firestore] ←────── [iPhone] ←──────┘
   ↑                                    
   └───────── 상대방 iPhone ←─── 실시간 리스너
```

### 커밋 전략
- 기능 단위로 브랜치 생성: `feature/firebase-setup`
- PR 리뷰는 본인이지만, 커밋 메시지는 명확하게
- Phase 완료 시마다 `main`에 머지 후 GitHub 태그 생성 (`v0.1.0-alpha`)

---

> 마지막 업데이트: 2026-04-28

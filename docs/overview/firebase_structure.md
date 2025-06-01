# 🗄️ Firebase 데이터베이스 구조 문서 (토도독)

## ✅ 개요

> 본 문서는 Firebase Firestore 기반으로 설계된 토도독(Tododok) 타자 연습 앱의 데이터 구조를 설명합니다.
>
> 로그인은 **이메일/비밀번호 방식**을 사용하며, 사용자별 연습 결과, 도전장, 문장 정보 등을 저장합니다.

---

## 📦 Firestore 컬렉션 구조

### 1. `users` – 사용자 정보

| 필드명 | 타입 | 설명 |
| --- | --- | --- |
| `email` | string | 사용자 이메일 |
| `displayName` | string | 사용자 표시 이름 |
| `createdAt` | timestamp | 계정 생성 시각 |
| `fcmToken` | string | 푸시 알림 토큰 |
| `platform` | string | "ios" 또는 "android" |
| `keyboardPreference` | string | 자판 기본 설정값 (`"ko"` 또는 `"en"`) |
| `allowNotification`  | boolean | 알림 수신 여부  |

> 🔐 문서 ID: Firebase Auth UID 사용

---

### 2. `typing_results` – 연습 결과 기록

| 필드명 | 타입 | 설명 |
| --- | --- | --- |
| `userId` | string | 작성자 UID |
| `type` | string | `"practice"` or `"challenge"` |
| `mode` | string | `"word"` or `"paragraph"` |
| `wpm` | number | 타자 속도 (WPM) |
| `accuracy` | number | 정확도 (%) |
| `typoCount` | number | 오타 수 |
| `duration` | number | 입력 시간 (초) |
| `sentenceId` | string | 사용한 문장 ID |
| `createdAt` | timestamp | 작성 시각 |

---

### 3. `challenges` – 도전장

| 필드명 | 타입 | 설명 |
| --- | --- | --- |
| `fromUserId` | string | 도전 보낸 사람 UID |
| `toUserId` | string | 도전 받은 사람 UID |
| `sentenceId` | string | 문장 ID |
| `mode` | string | 연습 모드 |
| `resultFrom` | map | 도전자 결과 (wpm, accuracy 등) |
| `resultTo` | map | 응답자 결과 |
| `status` | string | `"waiting"` / `"completed"` / `"expired"` |
| `createdAt` | timestamp | 생성 시각 |
| `expiresAt` | timestamp | 만료 시각 |

---

### 4. `sentences` – 연습 문장

| 필드명 | 타입 | 설명 |
| --- | --- | --- |
| `type` | string | `"word"` or `"paragraph"` |
| `language` | string | `"ko"` or `"en"` |
| `content` | string | 문장 본문 |
| `createdAt` | timestamp | 등록 시각 |

---

### 5. `notifications`– 알림 로그

| 필드명 | 타입 | 설명 |
| --- | --- | --- |
| `userId` | string | 알림 대상 UID |
| `type` | string | `"challenge_invite"` / `"challenge_result"` |
| `challengeId` | string | 관련 도전장 ID |
| `createdAt` | timestamp | 전송 시각 |
| `toUserId`  | string |  알림 수신 대상 사용자 ID  |
| `read` | boolean |  읽음 여부 (기본값 false)  |

---

## 🔒 Firestore 보안 규칙 예시

```java
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /typing_results/{resultId} {
      allow read, write: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }

    match /challenges/{challengeId} {
      allow read, write: if request.auth != null;
    }

    match /sentences/{sentenceId} {
      allow read: if true;
      allow write: if false; // 관리자만 등록
    }
  }
}
```

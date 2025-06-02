# 🗄️ Firebase 데이터베이스 구조 문서 (토도독) - 업데이트

## ✅ 개요

> 본 문서는 Firebase Firestore 기반으로 설계된 토도독(Tododok) 타자 연습 앱의 데이터 구조를 설명합니다.
>
> 로그인은 **이메일/비밀번호 방식**을 사용하며, **6자리 코드 기반 도전장 시스템**을 적용합니다.

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

### 3. `challenges` – 도전장 (업데이트)

| 필드명 | 타입 | 설명 |
| --- | --- | --- |
| `fromUserId` | string | 도전 보낸 사람 UID |
| `toUserId` | string | 도전 받은 사람 UID |
| `challengeCode` | **string** | **6자리 고유 코드 (예: ABC123)** |
| `sentenceId` | string | 문장 ID |
| `mode` | string | 연습 모드 |
| `resultFrom` | map | 도전자 결과 (wpm, accuracy 등) |
| `resultTo` | map | 응답자 결과 |
| `status` | string | `"waiting"` / `"completed"` / `"expired"` |
| `createdAt` | timestamp | 생성 시각 |
| `expiresAt` | timestamp | 만료 시각 |

#### 🆕 새로운 필드: `challengeCode`
- **6자리 영숫자 조합** (예: ABC123, XYZ789)
- **고유성 보장**: Firestore에서 중복 검사 필요
- **대소문자 구분 없음**: 사용자 입력 시 자동으로 대문자 변환
- **유효기간**: 도전장과 동일한 만료 시간 적용

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
| `challengeCode` | **string** | **관련 도전장 코드** |
| `createdAt` | timestamp | 전송 시각 |
| `toUserId`  | string |  알림 수신 대상 사용자 ID  |
| `read` | boolean |  읽음 여부 (기본값 false)  |

---

## 🔍 코드 기반 도전장 시스템

### 코드 생성 로직
```javascript
// 6자리 영숫자 조합 생성 예시
function generateChallengeCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}
```

### 코드 중복 검사
```javascript
// Firestore에서 코드 중복 확인
async function isCodeUnique(code) {
  const query = await db.collection('challenges')
    .where('challengeCode', '==', code)
    .where('status', '!=', 'expired')
    .get();
  return query.empty;
}
```

### 코드로 도전장 조회
```javascript
// 코드로 도전장 찾기
async function findChallengeByCode(code) {
  const query = await db.collection('challenges')
    .where('challengeCode', '==', code.toUpperCase())
    .where('status', '==', 'waiting')
    .get();
  return query.docs[0];
}
```

---

## 🔒 Firestore 보안 규칙 예시

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /typing_results/{resultId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    match /challenges/{challengeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.fromUserId || 
         request.auth.uid == resource.data.toUserId);
    }

    match /sentences/{sentenceId} {
      allow read: if true;
      allow write: if false; // 관리자만 등록
    }

    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 🔄 변경사항 요약

### 추가된 필드
- `challenges.challengeCode`: 6자리 고유 코드
- `notifications.challengeCode`: 알림에서 코드 참조

### 제거된 기능
- Firebase Dynamic Links 관련 필드 없음

### 새로운 쿼리 패턴
- 코드 기반 도전장 조회
- 코드 중복 검사
- 만료되지 않은 코드만 유효성 검사

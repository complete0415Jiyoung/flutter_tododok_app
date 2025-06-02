import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 성공');
  } catch (e) {
    print('❌ Firebase 초기화 실패: $e');
  }

  runApp(const ProviderScope(child: TododokApp()));
}

class TododokApp extends StatelessWidget {
  const TododokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tododok',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _testResult = '📱 Firebase 연결 테스트를 시작하세요';
  bool _isLoading = false;

  Future<void> _testFirebaseStep1() async {
    setState(() {
      _isLoading = true;
      _testResult = '🔄 1단계: Firebase 초기화 확인 중...';
    });

    try {
      // Firebase 앱이 초기화되었는지 확인
      final app = Firebase.app();
      setState(() {
        _testResult = '✅ 1단계: Firebase 초기화 완료\n앱 이름: ${app.name}';
      });

      await Future.delayed(const Duration(seconds: 1));
      await _testFirebaseStep2();
    } catch (e) {
      setState(() {
        _testResult = '❌ 1단계 실패: Firebase 초기화 오류\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseStep2() async {
    setState(() {
      _testResult = '$_testResult\n\n🔄 2단계: Authentication 테스트 중...';
    });

    try {
      // 현재 사용자 확인
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          _testResult = '$_testResult\n✅ 이미 로그인됨: ${currentUser.uid}';
        });
      } else {
        // 익명 로그인 시도
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        final user = userCredential.user;

        if (user != null) {
          setState(() {
            _testResult = '$_testResult\n✅ 익명 로그인 성공\nUID: ${user.uid}';
          });
        }
      }

      await Future.delayed(const Duration(seconds: 1));
      await _testFirebaseStep3();
    } catch (e) {
      setState(() {
        _testResult =
            '$_testResult\n❌ 2단계 실패: Authentication 오류\n$e\n\n해결방법: Firebase Console > Authentication > 익명 로그인 활성화';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseStep3() async {
    setState(() {
      _testResult = '$_testResult\n\n🔄 3단계: Firestore 쓰기 테스트 중...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되지 않음');
      }

      // Firestore에 테스트 데이터 쓰기
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test_${DateTime.now().millisecondsSinceEpoch}')
          .set({
            'timestamp': FieldValue.serverTimestamp(),
            'message': 'Firebase 연결 테스트',
            'userId': user.uid,
            'testTime': DateTime.now().toIso8601String(),
          });

      setState(() {
        _testResult = '$_testResult\n✅ Firestore 쓰기 성공';
      });

      await Future.delayed(const Duration(seconds: 1));
      await _testFirebaseStep4();
    } catch (e) {
      setState(() {
        _testResult =
            '$_testResult\n❌ 3단계 실패: Firestore 쓰기 오류\n$e\n\n해결방법: Firebase Console > Firestore Database 생성';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseStep4() async {
    setState(() {
      _testResult = '$_testResult\n\n🔄 4단계: Firestore 읽기 테스트 중...';
    });

    try {
      // Firestore에서 테스트 데이터 읽기
      final querySnapshot = await FirebaseFirestore.instance
          .collection('test')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _testResult =
              '$_testResult\n✅ Firestore 읽기 성공\n문서 수: ${querySnapshot.docs.length}';
        });
      } else {
        setState(() {
          _testResult = '$_testResult\n⚠️ Firestore 읽기 성공 (문서 없음)';
        });
      }

      setState(() {
        _testResult = '$_testResult\n\n🎉 모든 테스트 완료!\nFirebase 연동 성공!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '$_testResult\n❌ 4단계 실패: Firestore 읽기 오류\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resetTest() async {
    setState(() {
      _testResult = '📱 Firebase 연결 테스트를 시작하세요';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tododok - Firebase 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            const Text(
              '🎯 토도독 Firebase 연결 테스트',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 테스트 결과 표시
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testFirebaseStep1,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text('Firebase 테스트 시작'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetTest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  child: const Text('초기화'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

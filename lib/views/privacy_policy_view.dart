import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool _isAgreed1 = false;
  bool _isAgreed2 = false;
  bool _isAgreed3 = false;
  bool _isAgreed4 = false;
  bool _isAllAgreed = false;

  bool get _isNextEnabled {
    return _isAgreed1 &&
        _isAgreed2 &&
        _isAgreed3; // 1, 2, 3이 모두 선택되어야 다음 버튼 활성화
  }

  void _onAllAgreedChanged(bool? value) {
    setState(() {
      _isAllAgreed = value ?? false;
      _isAgreed1 = _isAllAgreed;
      _isAgreed2 = _isAllAgreed;
      _isAgreed3 = _isAllAgreed;
      _isAgreed4 = _isAllAgreed; // 4번도 함께 선택
    });
  }

  void _onNextPressed() {
    if (_isNextEnabled) {
      // 동의한 경우 다음 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NextPage()),
      );
    } else {
      // 필수 약관에 동의하지 않은 경우 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('필수 약관에 동의해야 합니다.')),
      );
    }
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 약관 동의'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '회원가입 약관',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _showPrivacyPolicy,
              child: Text('개인정보 처리방침 보기',
                  style: TextStyle(fontSize: 17, color: Colors.blue)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text('1. 개인정보 보호 (필수)'),
                      value: _isAgreed1,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed1 = value ?? false;
                          _isAllAgreed = _isAgreed1 &&
                              _isAgreed2 &&
                              _isAgreed3 &&
                              _isAgreed4;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('2. 서비스 이용 (필수)'),
                      value: _isAgreed2,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed2 = value ?? false;
                          _isAllAgreed = _isAgreed1 &&
                              _isAgreed2 &&
                              _isAgreed3 &&
                              _isAgreed4;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('3. 약관의 변경 (필수)'),
                      value: _isAgreed3,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed3 = value ?? false;
                          _isAllAgreed = _isAgreed1 &&
                              _isAgreed2 &&
                              _isAgreed3 &&
                              _isAgreed4;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('4. 기타 사항 (선택)'),
                      value: _isAgreed4,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed4 = value ?? false;
                          _isAllAgreed = _isAgreed1 &&
                              _isAgreed2 &&
                              _isAgreed3 &&
                              _isAgreed4;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '모두 동의',
                          style: TextStyle(fontSize: 16),
                        ),
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: _isAllAgreed,
                            onChanged: _onAllAgreedChanged,
                            activeColor: Colors.blue,
                            // 체크 시 색상
                            checkColor: Colors.white,
                            // 체크 표시 색상
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4), // 모서리 둥글기
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isNextEnabled ? _onNextPressed : null, // 버튼 활성화 여부 설정
              child: Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다음 페이지'),
      ),
      body: Center(
        child: Text(
          '회원가입 완료!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '개인정보 처리방침',
          style: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '개인정보 처리방침',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '최종 업데이트: 2024년 12월 16일\n\n'
                '본 개인정보 처리방침(이하 "방침")은 [앱 이름] (이하 "당사")가 수집하는 개인정보의 이용 및 보호에 대한 내용을 설명합니다. 당사는 사용자 여러분의 개인정보를 소중하게 생각하며, 이를 안전하게 관리하기 위해 최선을 다하고 있습니다.\n\n'
                '1. 수집하는 개인정보의 항목\n'
                '당사는 다음과 같은 개인정보를 수집합니다:\n'
                '- 회원가입 정보: 이름, 이메일 주소, 비밀번호\n'
                '- 사용자 프로필 정보: 프로필 사진, 생년월일, 성별\n'
                '- 이용 기록: 서비스 이용 기록, 로그 데이터\n'
                '- 기타 정보: 사용자 피드백, 고객 서비스 요청\n\n'
                '2. 개인정보의 수집 및 이용 목적\n'
                '당사는 수집한 개인정보를 다음과 같은 목적으로 이용합니다:\n'
                '- 서비스 제공 및 운영\n'
                '- 회원 관리 및 인증\n'
                '- 맞춤형 서비스 제공\n'
                '- 고객 지원 및 서비스 개선\n'
                '- 법적 의무 이행 및 분쟁 해결\n\n'
                '3. 개인정보의 보유 및 이용기간\n'
                '당사는 개인정보를 수집 목적이 달성될 때까지 보유하며, 관련 법령에 따라 보관해야 하는 경우에는 해당 기간 동안 보유합니다.\n\n'
                '4. 개인정보의 제3자 제공\n'
                '당사는 사용자의 개인정보를 제3자에게 제공하지 않습니다. 단, 다음과 같은 경우에는 예외로 합니다:\n'
                '- 사용자의 사전 동의가 있는 경우\n'
                '- 법령에 의하여 요구되는 경우\n'
                '- 서비스 제공을 위해 필요한 경우 (예: 결제 처리 업체)\n\n'
                '5. 개인정보의 안전성 확보 조치\n'
                '당사는 사용자의 개인정보를 안전하게 보호하기 위해 다음과 같은 조치를 취하고 있습니다:\n'
                '- 개인정보 암호화\n'
                '- 접근 권한 관리\n'
                '- 보안 프로그램을 통한 보호\n\n'
                '6. 사용자 권리\n'
                '사용자는 언제든지 자신의 개인정보에 대한 열람, 수정, 삭제를 요청할 수 있습니다. 요청은 [이메일 주소]로 하실 수 있습니다.\n\n'
                '7. 개인정보 처리방침의 변경\n'
                '본 방침은 법령, 정책 또는 서비스 변경에 따라 수정될 수 있으며, 변경 시에는 앱 내 공지사항을 통해 안내합니다.\n\n'
                '8. 문의처\n'
                '본 방침에 대한 문의는 아래의 연락처로 주시기 바랍니다:\n'
                '- 이메일: [이메일 주소]\n'
                '- 전화: [전화번호]',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

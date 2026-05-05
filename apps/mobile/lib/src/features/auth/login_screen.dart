import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../state/app_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'demo@cmstudy.app');
  final passwordController = TextEditingController(text: 'password123');
  final nicknameController = TextEditingController(text: '민서');
  bool isRegister = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                if (widget.controller.showImages) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      AppAssets.loginHero,
                      height: 178,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else
                  const SizedBox(height: 32),
                Text(
                  'CMStudy',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '스탑워치 기록, 과목 밸런스, 공부 분석을 한 흐름으로 관리하세요.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.blueGrey),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: false, label: Text('로그인')),
                              ButtonSegment(value: true, label: Text('가입')),
                            ],
                            selected: {isRegister},
                            onSelectionChanged: (value) {
                              setState(() => isRegister = value.first);
                            },
                          ),
                          const SizedBox(height: 16),
                          if (isRegister)
                            TextFormField(
                              controller: nicknameController,
                              decoration: const InputDecoration(
                                labelText: '닉네임',
                              ),
                              validator: (value) =>
                                  value == null || value.trim().length < 2
                                  ? '닉네임을 2자 이상 입력하세요'
                                  : null,
                            ),
                          if (isRegister) const SizedBox(height: 12),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: '이메일'),
                            validator: (value) =>
                                value == null || !value.contains('@')
                                ? '이메일을 입력하세요'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '비밀번호',
                            ),
                            validator: (value) =>
                                value == null || value.length < 8
                                ? '비밀번호는 8자 이상이어야 합니다'
                                : null,
                          ),
                          if (widget.controller.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.controller.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: widget.controller.isBusy ? null : submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: widget.controller.isBusy
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(isRegister ? '계정 만들기' : '로그인'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '공부량만 세는 앱이 아니라 다음 행동을 정해주는 앱으로 설계했습니다.',
                  style: TextStyle(color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (isRegister) {
      await widget.controller.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        nickname: nicknameController.text.trim(),
      );
      return;
    }

    await widget.controller.login(
      emailController.text.trim(),
      passwordController.text,
    );
  }
}

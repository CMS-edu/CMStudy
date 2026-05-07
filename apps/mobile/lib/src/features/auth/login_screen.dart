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
  final emailController = TextEditingController(text: 'demo@cmstudy.app');
  final passwordController = TextEditingController(text: 'password123');
  final nicknameController = TextEditingController(text: '민서');
  bool isRegister = false;
  String? formError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.controller.themeProfile;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(profile.seedColor.withAlpha(18), scheme.surface),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: ListView(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                children: [
                  if (widget.controller.showImages) ...[
                    Container(
                      height: 196,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(AppAssets.loginHero, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withAlpha(12),
                                  Colors.black.withAlpha(96),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white.withAlpha(230),
                                  ),
                                  child: Icon(
                                    Icons.bolt_outlined,
                                    color: profile.seedColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'CMStudy',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 18),
                    Text(
                      'CMStudy',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    '스탑워치 기록, 과목 밸런스, 공부 분석을 한 흐름으로 관리하세요.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('로그인'),
                                icon: Icon(Icons.login),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('가입'),
                                icon: Icon(Icons.person_add_alt_1_outlined),
                              ),
                            ],
                            selected: {isRegister},
                            onSelectionChanged: (value) {
                              setState(() {
                                isRegister = value.first;
                                formError = null;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          if (isRegister)
                            TextField(
                              controller: nicknameController,
                              decoration: const InputDecoration(
                                labelText: '닉네임',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                          if (isRegister) const SizedBox(height: 12),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '비밀번호',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          if (formError != null ||
                              widget.controller.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              formError ?? widget.controller.errorMessage!,
                              style: TextStyle(color: scheme.error),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: widget.controller.isBusy ? null : submit,
                            icon: widget.controller.isBusy
                                ? const SizedBox.shrink()
                                : Icon(
                                    isRegister
                                        ? Icons.person_add_alt_1_outlined
                                        : Icons.arrow_forward_rounded,
                                  ),
                            label: Padding(
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
                  const SizedBox(height: 14),
                  Text(
                    '공부량만 세는 앱이 아니라 다음 행동을 정해주는 앱으로 설계했습니다.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final nickname = nicknameController.text.trim();
    if (!email.contains('@')) {
      setState(() => formError = '이메일을 입력하세요');
      return;
    }
    if (password.length < 8) {
      setState(() => formError = '비밀번호는 8자 이상이어야 합니다');
      return;
    }
    if (isRegister && nickname.length < 2) {
      setState(() => formError = '닉네임을 2자 이상 입력하세요');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => formError = null);
    if (isRegister) {
      await widget.controller.register(
        email: email,
        password: password,
        nickname: nickname,
      );
      return;
    }

    await widget.controller.login(email, password);
  }
}

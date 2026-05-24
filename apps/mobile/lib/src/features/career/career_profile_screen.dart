import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/inseoul_major_service.dart';

const _careerProfileKey = 'cmstudy_career_profile_ids';
const _myGradeKey = 'cmstudy_my_grade';

class CareerPath {
  const CareerPath({
    required this.id,
    required this.category,
    required this.keywords,
    required this.majors,
    required this.subjects,
    required this.activities,
    required this.advice,
    required this.roles,
    required this.competencies,
    required this.projects,
  });

  final String id;
  final String category;
  final List<String> keywords;
  final List<String> majors;
  final List<String> subjects;
  final List<String> activities;
  final String advice;
  final List<String> roles;
  final List<String> competencies;
  final List<String> projects;
}

const careerPaths = [
  CareerPath(
    id: 'life_science',
    category: '생명과학/바이오',
    keywords: ['생명', '바이오', '생물', '유전', '미생물', '생화학', '분자생물'],
    majors: ['생명과학과', '생명공학과', '바이오학과', '의생명과학과'],
    subjects: ['생명과학I', '생명과학II', '화학I', '화학II', '미적분', '확률과통계'],
    activities: [
      '생명과학 R&E 탐구',
      '병원·연구소 견학',
      '유전자 관련 실험 보고서 작성',
      '생명윤리 독서 및 토론',
    ],
    roles: ['생명공학연구원', '의생명과학자', '바이오인포매틱스전문가', '제약연구원', '환경생태연구원'],
    competencies: ['과학적 사고력', '실험 설계 능력', '데이터 해석 능력', '생명윤리 의식'],
    projects: ['CRISPR 유전자 편집 기술 조사 보고서', '미생물 배양 실험 설계', '생태계 변화 데이터 분석'],
    advice: '생명과학과 화학을 심화 이수하고 R&E나 소논문에서 생명 관련 주제를 탐구하세요.',
  ),
  CareerPath(
    id: 'medicine',
    category: '의약/보건',
    keywords: ['의학', '의대', '간호', '약학', '보건', '임상', '치의학', '한의학', '물리치료'],
    majors: ['의예과', '의학과', '간호학과', '약학과', '치의예과', '한의예과', '물리치료학과'],
    subjects: ['생명과학I', '생명과학II', '화학I', '화학II', '미적분', '확률과통계'],
    activities: ['병원 봉사활동', '의학 관련 논문 읽기', '응급처치 교육 이수', '보건 관련 탐구 보고서'],
    roles: ['의사', '약사', '간호사', '한의사', '치과의사', '보건연구원', '임상병리사'],
    competencies: ['생명과학 지식', '꼼꼼함과 정확성', '공감 능력', '위기 대처 능력'],
    projects: ['특정 질병의 원인과 치료법 조사', '의약품 작용 원리 탐구', '지역사회 건강 실태 조사'],
    advice: '생명과학과 화학을 모두 심화로 이수하고, 봉사활동과 의료 관련 탐구 활동을 꾸준히 쌓으세요.',
  ),
  CareerPath(
    id: 'computer_ai',
    category: '컴퓨터공학/인공지능',
    keywords: ['컴퓨터', '소프트웨어', '인공지능', '정보', '데이터', '사이버', '게임'],
    majors: ['컴퓨터공학과', '소프트웨어학과', '인공지능학과', '데이터사이언스학과'],
    subjects: ['정보', '인공지능 수학', '미적분', '확률과통계', '물리학I'],
    activities: ['프로그래밍 프로젝트', '알고리즘 대회 참가', 'AI 관련 논문 읽기', '앱·웹 개발 포트폴리오'],
    roles: ['소프트웨어엔지니어', 'AI연구원', '데이터사이언티스트', '사이버보안전문가', '게임개발자'],
    competencies: ['논리적 사고력', '문제 해결 능력', '수학적 모델링', '프로그래밍 역량'],
    projects: ['머신러닝 모델 구현', '웹·앱 서비스 개발', '데이터 분석 프로젝트'],
    advice: '정보 과목과 수학을 심화 이수하고, 개인 프로젝트나 공모전 참가 이력을 만드세요.',
  ),
  CareerPath(
    id: 'mechanical',
    category: '기계/전기전자/로봇공학',
    keywords: ['기계', '전기', '전자', '로봇', '자동화', '반도체', '항공', '자동차'],
    majors: ['기계공학과', '전기공학과', '전자공학과', '로봇공학과', '반도체공학과'],
    subjects: ['물리학I', '물리학II', '미적분', '정보', '화학I'],
    activities: ['아두이노·로봇 제작 프로젝트', '물리 실험 보고서', '공학 관련 탐구 활동'],
    roles: ['기계공학자', '전자공학자', '로봇공학자', '반도체엔지니어', '항공우주엔지니어'],
    competencies: ['공학적 사고력', '물리 이해력', '설계 능력', '수학적 분석력'],
    projects: ['간단한 로봇 설계 및 제작', '전기회로 탐구', '자동차 구조 분석 보고서'],
    advice: '물리학과 수학을 심화 이수하고, 공학 관련 R&E나 메이커 활동을 통해 실제 제작 경험을 쌓으세요.',
  ),
  CareerPath(
    id: 'chemistry',
    category: '화학/화학공학/신소재',
    keywords: ['화학', '신소재', '재료', '고분자', '섬유', '에너지'],
    majors: ['화학과', '화학공학과', '신소재공학과', '재료공학과', '고분자공학과'],
    subjects: ['화학I', '화학II', '물리학I', '미적분', '생명과학I'],
    activities: ['화학 실험 설계 및 보고서', '신소재 관련 논문 읽기', '환경 화학 탐구'],
    roles: ['화학공학자', '신소재연구원', '환경공학자', '석유화학전문가', '제약연구원'],
    competencies: ['화학적 사고력', '실험 설계 능력', '분석력', '안전 의식'],
    projects: ['생활 속 화학반응 탐구', '친환경 소재 연구', '화학공정 설계 보고서'],
    advice: '화학I·II를 모두 이수하고, 실험 활동과 화학 관련 소논문을 적극적으로 작성하세요.',
  ),
  CareerPath(
    id: 'math_stats',
    category: '수학/통계/데이터',
    keywords: ['수학', '통계', '데이터', '수리', '금융수학'],
    majors: ['수학과', '통계학과', '데이터사이언스학과', '금융수학과'],
    subjects: ['미적분', '확률과통계', '정보', '인공지능 수학', '물리학I'],
    activities: ['수학 경시대회 참가', '통계 분석 프로젝트', '데이터 시각화 탐구'],
    roles: ['통계학자', '데이터사이언티스트', '계리사', '금융공학전문가', '수학교사'],
    competencies: ['수리적 사고력', '논리력', '데이터 해석 능력', '추상적 사고력'],
    projects: ['공공데이터 분석 프로젝트', '확률 모델 설계', '금융 데이터 예측 보고서'],
    advice: '미적분과 확률과통계를 모두 이수하고, 데이터 분석이나 수학 관련 탐구 활동을 꾸준히 하세요.',
  ),
  CareerPath(
    id: 'environment',
    category: '환경/지구과학',
    keywords: ['환경', '지구', '해양', '기상', '생태', '조경', '산림'],
    majors: ['환경공학과', '지구환경과학과', '해양학과', '기상학과', '산림과학과'],
    subjects: ['지구과학I', '지구과학II', '생명과학I', '화학I', '확률과통계'],
    activities: ['환경 탐사 보고서', '기후 변화 관련 독서 및 토론', '생태계 조사 활동'],
    roles: ['환경공학자', '기상연구원', '해양과학자', '생태연구원', '환경컨설턴트'],
    competencies: ['환경 감수성', '과학적 탐구력', '데이터 분석력', '지속가능성 이해'],
    projects: ['지역 생태계 변화 분석', '기후 데이터 시각화', '환경 정책 제안 보고서'],
    advice: '지구과학과 생명과학을 이수하고, 환경 관련 탐구나 캠페인 활동을 통해 관심을 보여주세요.',
  ),
  CareerPath(
    id: 'education',
    category: '교육',
    keywords: ['교육', '사범', '교직', '유아', '초등', '특수교육'],
    majors: ['교육학과', '국어교육과', '영어교육과', '수학교육과', '유아교육과', '특수교육과'],
    subjects: ['국어', '영어', '확률과통계', '생명과학I', '사회'],
    activities: ['교육 봉사활동', '멘토링 프로그램 참여', '교육학 관련 독서'],
    roles: ['교사', '교육연구원', '교육행정가', '상담교사', '교육콘텐츠개발자'],
    competencies: ['소통 능력', '인내심', '교육적 열정', '창의적 수업 설계력'],
    projects: ['교육 사각지대 실태 조사', '효과적인 학습법 연구', '교육 콘텐츠 제작'],
    advice: '다양한 교육 봉사와 멘토링 활동을 통해 교육에 대한 열정을 보여주세요.',
  ),
  CareerPath(
    id: 'psychology',
    category: '심리/사회/복지',
    keywords: ['심리', '상담', '사회복지', '복지', '사회학'],
    majors: ['심리학과', '상담학과', '사회복지학과', '사회학과'],
    subjects: ['사회', '생명과학I', '확률과통계', '국어', '윤리'],
    activities: ['심리 관련 독서 및 독후감', '사회복지 봉사활동', '상담 관련 탐구'],
    roles: ['심리상담사', '사회복지사', '사회학자', '복지정책연구원', '임상심리사'],
    competencies: ['공감 능력', '경청 능력', '분석적 사고', '윤리적 판단력'],
    projects: ['청소년 정신건강 실태 조사', '사회 불평등 관련 탐구', '심리 이론 적용 사례 분석'],
    advice: '사회 관련 과목을 이수하고, 봉사와 상담 관련 활동으로 관심을 드러내세요.',
  ),
  CareerPath(
    id: 'business',
    category: '경영/경제/금융',
    keywords: ['경영', '경제', '무역', '회계', '마케팅', '금융', '세무'],
    majors: ['경영학과', '경제학과', '무역학과', '회계학과', '금융학과', '세무학과'],
    subjects: ['경제', '미적분', '확률과통계', '영어', '정보'],
    activities: ['모의 주식 투자 탐구', '창업 아이디어 발표', '경제 신문 스크랩 및 분석'],
    roles: ['경영컨설턴트', '금융분석가', '회계사', '마케터', '창업가'],
    competencies: ['전략적 사고력', '수리 능력', '리더십', '경제적 판단력'],
    projects: ['기업 경영 전략 분석', '소비자 행동 조사', '스타트업 사업계획서 작성'],
    advice: '경제 과목을 이수하고, 경제·경영 관련 탐구나 모의 창업 활동을 적극적으로 하세요.',
  ),
  CareerPath(
    id: 'humanities',
    category: '언어/인문/역사/문화',
    keywords: ['국어', '영어', '문학', '역사', '철학', '문화', '언어', '한국어'],
    majors: ['국어국문학과', '영어영문학과', '사학과', '철학과', '문화콘텐츠학과', '언어학과'],
    subjects: ['국어', '영어', '사회', '윤리', '확률과통계'],
    activities: ['독서 및 독후감', '역사 탐방 보고서', '글쓰기 대회 참가'],
    roles: ['작가', '언론인', '역사학자', '철학자', '문화기획자', '번역가'],
    competencies: ['언어 능력', '비판적 사고력', '문화적 감수성', '글쓰기 역량'],
    projects: ['지역 역사 탐구 보고서', '문학 작품 비평', '다문화 사회 관련 탐구'],
    advice: '국어와 영어를 심화 이수하고, 독서와 글쓰기 활동을 꾸준히 기록으로 남기세요.',
  ),
  CareerPath(
    id: 'media_design',
    category: '미디어/디자인/예술',
    keywords: ['디자인', '미디어', '영상', '언론', '광고', '사진', '애니메이션', '미술'],
    majors: ['시각디자인학과', '영상학과', '미디어학과', '광고홍보학과', '애니메이션학과'],
    subjects: ['미술', '정보', '국어', '영어', '확률과통계'],
    activities: ['포트폴리오 제작', '영상 콘텐츠 제작', '디자인 공모전 참가'],
    roles: ['그래픽디자이너', '영상PD', '광고기획자', '미디어아티스트', 'UX디자이너'],
    competencies: ['창의력', '시각적 표현력', '스토리텔링', '트렌드 감각'],
    projects: ['단편 영상 제작', '브랜드 아이덴티티 디자인', 'SNS 콘텐츠 기획'],
    advice: '미술·미디어 관련 과목을 이수하고, 개인 포트폴리오를 꾸준히 쌓으세요.',
  ),
  CareerPath(
    id: 'sports',
    category: '체육/스포츠',
    keywords: ['체육', '스포츠', '무용', '레저', '태권도', '골프'],
    majors: ['체육학과', '스포츠과학과', '스포츠산업학과', '무용학과', '레저스포츠학과'],
    subjects: ['체육', '생명과학I', '확률과통계', '물리학I'],
    activities: ['체육 대회 참가', '스포츠 지도 봉사', '운동 생리학 탐구'],
    roles: ['스포츠트레이너', '체육교사', '스포츠마케터', '운동처방사', '스포츠분석가'],
    competencies: ['체력과 지구력', '리더십', '팀워크', '과학적 트레이닝 이해'],
    projects: ['운동 수행 능력 분석', '스포츠 부상 예방 탐구', '트레이닝 프로그램 설계'],
    advice: '체육 활동과 함께 운동 생리학이나 스포츠 과학 관련 탐구 활동을 병행하세요.',
  ),
  CareerPath(
    id: 'architecture',
    category: '건축/도시/토목',
    keywords: ['건축', '도시', '토목', '인테리어', '실내'],
    majors: ['건축학과', '건축공학과', '도시공학과', '토목공학과', '실내디자인학과'],
    subjects: ['물리학I', '미적분', '미술', '정보', '확률과통계'],
    activities: ['건축 답사 및 보고서', '모형 제작', '도시 설계 탐구'],
    roles: ['건축사', '도시계획가', '토목공학자', '인테리어디자이너', '스마트시티전문가'],
    competencies: ['공간 감각', '설계 능력', '창의력', '구조적 사고력'],
    projects: ['지역 건축물 분석 보고서', '친환경 건축 설계 탐구', '도시 문제 해결 방안 제안'],
    advice: '물리학과 수학을 이수하고, 건축 답사나 모형 제작 등 실제 설계 활동을 경험하세요.',
  ),
  CareerPath(
    id: 'agriculture',
    category: '농림/식품/동물',
    keywords: ['농업', '식품', '동물', '수의', '원예', '축산', '식품영양'],
    majors: ['식품공학과', '동물자원학과', '원예학과', '산림과학과', '식품영양학과'],
    subjects: ['생명과학I', '화학I', '지구과학I', '확률과통계'],
    activities: ['농업 현장 탐방', '식품 관련 실험', '동물 생태 관찰 보고서'],
    roles: ['수의사', '식품공학자', '농업연구원', '원예치료사', '동물행동전문가'],
    competencies: ['생명 존중 의식', '과학적 탐구력', '환경 감수성', '실험 능력'],
    projects: ['식품 안전성 탐구', '동물 복지 관련 보고서', '스마트팜 기술 조사'],
    advice: '생명과학과 화학을 이수하고, 농업·식품·동물 관련 탐방이나 실험 활동을 경험하세요.',
  ),
  CareerPath(
    id: 'law',
    category: '법/행정/정치',
    keywords: ['법학', '행정', '정치', '공공', '경찰', '법무'],
    majors: ['법학과', '행정학과', '정치외교학과', '경찰행정학과', '공공인재학과'],
    subjects: ['사회', '국어', '영어', '윤리', '확률과통계'],
    activities: ['모의재판 참가', '시사 논술 작성', '법률 관련 독서 및 토론'],
    roles: ['변호사', '판사', '검사', '행정공무원', '정치인', '정책연구원'],
    competencies: ['논리적 사고력', '언어 능력', '비판적 분석력', '공공 의식'],
    projects: ['법률 사례 분석 보고서', '정책 제안서 작성', '지역 사회 문제 탐구'],
    advice: '사회·윤리 과목을 이수하고, 시사 토론과 논술 활동을 꾸준히 기록으로 남기세요.',
  ),
];

Future<List<CareerPath>> loadCareerProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final ids = prefs.getStringList(_careerProfileKey) ?? const [];
  return careerPaths.where((path) => ids.contains(path.id)).toList();
}

Future<void> saveCareerProfile(List<CareerPath> paths) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _careerProfileKey,
    paths.map((path) => path.id).toList(),
  );
}

Future<void> clearCareerProfile() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_careerProfileKey);
}

List<CareerPath> findCareerPaths(String keyword) {
  final query = keyword.trim().toLowerCase();
  if (query.isEmpty) return const [];
  return careerPaths
      .where(
        (path) =>
            path.category.toLowerCase().contains(query) ||
            path.keywords.any(
              (item) =>
                  item.toLowerCase().contains(query) ||
                  query.contains(item.toLowerCase()),
            ) ||
            path.majors.any(
              (item) =>
                  item.toLowerCase().contains(query) ||
                  query.contains(item.toLowerCase()),
            ),
      )
      .take(3)
      .toList();
}

class CareerProfileScreen extends StatefulWidget {
  const CareerProfileScreen({super.key});

  @override
  State<CareerProfileScreen> createState() => _CareerProfileScreenState();
}

class _CareerProfileScreenState extends State<CareerProfileScreen> {
  final keywordController = TextEditingController();
  final gradeController = TextEditingController();
  List<CareerPath> selected = [];
  List<CareerPath> surveyCandidates = [];
  List<int> survey = List.filled(_surveyQuestions.length, 3);
  double? myGrade;

  @override
  void initState() {
    super.initState();
    loadCareerProfile().then((paths) {
      if (mounted) setState(() => selected = paths);
    });
    _loadMyGrade();
  }

  @override
  void dispose() {
    keywordController.dispose();
    gradeController.dispose();
    super.dispose();
  }

  Future<void> _loadMyGrade() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGrade = prefs.getDouble(_myGradeKey);
    if (!mounted) return;
    setState(() {
      myGrade = savedGrade;
      gradeController.text = savedGrade?.toStringAsFixed(1) ?? '';
    });
  }

  Future<void> _updateMyGrade(String value) async {
    final normalized = value.trim();
    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove(_myGradeKey);
      if (mounted) setState(() => myGrade = null);
      return;
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 1.0 || parsed > 9.0) {
      if (mounted) setState(() => myGrade = null);
      return;
    }
    final rounded = double.parse(parsed.toStringAsFixed(1));
    await prefs.setDouble(_myGradeKey, rounded);
    if (mounted) setState(() => myGrade = rounded);
  }

  void searchKeyword() {
    setState(() {
      selected = findCareerPaths(keywordController.text);
      surveyCandidates = [];
    });
  }

  void recommendBySurvey() {
    final scores = {
      for (final path in careerPaths) path: _surveyScore(path.id),
    }.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      surveyCandidates = scores.take(3).map((entry) => entry.key).toList();
      selected = [];
    });
  }

  int _surveyScore(String id) {
    final mapping = _surveyWeights[id] ?? const <int>[];
    return mapping.fold<int>(0, (sum, question) => sum + survey[question - 1]);
  }

  Future<void> save() async {
    if (selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장할 진로를 먼저 선택하세요.')));
      return;
    }
    await saveCareerProfile(selected);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('진로 프로필을 저장했습니다.')));
  }

  Future<void> clear() async {
    await clearCareerProfile();
    setState(() {
      selected = [];
      surveyCandidates = [];
    });
  }

  void toggleCandidate(CareerPath path) {
    setState(() {
      if (selected.any((item) => item.id == path.id)) {
        selected = selected.where((item) => item.id != path.id).toList();
      } else {
        selected = [...selected, path];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('진로 프로필')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          _CareerPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관심 진로 설정',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '공공데이터 기반 학과 분류와 고등학교 선택과목 자료를 바탕으로 추천합니다.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keywordController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => searchKeyword(),
                  decoration: InputDecoration(
                    hintText: '예: 생명, 컴퓨터, 경영, 건축, 디자인',
                    prefixIcon: const Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: searchKeyword,
                  icon: const Icon(Icons.manage_search_outlined),
                  label: const Text('키워드로 추천받기'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: gradeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: _updateMyGrade,
                  decoration: InputDecoration(
                    labelText: '내신 평균 등급',
                    hintText: '예: 2.4',
                    prefixIcon: const Icon(Icons.school_outlined),
                    suffixText: myGrade == null ? '1.0~9.0' : '저장됨',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CareerPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '진로 탐색 설문',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '1점은 전혀 아니다, 5점은 매우 그렇다에 가깝습니다. 흥미와 문제 해결 방식을 함께 봅니다.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                for (final item in _surveyQuestions.indexed) ...[
                  Text(
                    '${item.$1 + 1}. ${item.$2}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Slider(
                    value: survey[item.$1].toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '${survey[item.$1]}점',
                    onChanged: (value) =>
                        setState(() => survey[item.$1] = value.round()),
                  ),
                ],
                FilledButton.icon(
                  onPressed: recommendBySurvey,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('설문으로 추천받기'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (surveyCandidates.isNotEmpty) ...[
            _CareerPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '검사 결과 1~3순위',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '프로필로 저장할 계열을 선택하세요. 복수 선택도 가능합니다.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final entry in surveyCandidates.indexed) ...[
                    _RankedCareerOption(
                      rank: entry.$1 + 1,
                      path: entry.$2,
                      selected: selected.any((item) => item.id == entry.$2.id),
                      onTap: () => toggleCandidate(entry.$2),
                    ),
                    if (entry.$1 != surveyCandidates.length - 1)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (selected.isEmpty)
            _CareerPanel(
              child: Text(
                surveyCandidates.isEmpty
                    ? '아직 저장된 진로 프로필이 없습니다. 키워드 또는 설문으로 관심 계열을 찾아보세요.'
                    : '위의 1~3순위 결과 중 저장할 진로를 선택하면 자세한 추천 내용이 표시됩니다.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            )
          else ...[
            for (final path in selected) ...[
              _CareerResultCard(path: path, myGrade: myGrade),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('프로필 저장'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(
                  onPressed: clear,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '프로필 삭제',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

const _surveyQuestions = [
  '생물이나 생명 현상에 대해 궁금증을 자주 느낀다',
  '화학 반응이나 물질의 성질에 흥미가 있다',
  '수식이나 공식을 통해 자연 현상을 설명하는 것이 재미있다',
  '실험을 직접 설계하고 결과를 분석하는 것을 즐긴다',
  '환경 문제나 지구 변화에 관심이 많다',
  '기계나 전자기기가 작동하는 원리에 흥미가 있다',
  '코딩이나 프로그래밍을 배우는 것이 즐겁다',
  '문제를 해결할 때 체계적이고 논리적인 방법을 선호한다',
  '새로운 기술이나 AI 관련 뉴스에 관심이 많다',
  '무언가를 직접 만들거나 설계하는 것을 좋아한다',
  '사람의 몸이나 질병에 대해 관심이 많다',
  '아픈 사람을 돕거나 치료하는 일에 보람을 느낄 것 같다',
  '약의 작용이나 의학 정보를 찾아보는 것이 흥미롭다',
  '사람들의 건강과 생활 습관에 관심이 있다',
  '꼼꼼하고 정확하게 일을 처리하는 것을 선호한다',
  '역사적 사건이나 문화의 흐름에 흥미가 있다',
  '사람들의 심리나 행동 방식이 궁금하다',
  '사회 문제나 뉴스에 관심을 갖고 내 생각을 정리하는 편이다',
  '글쓰기나 언어로 생각을 표현하는 것을 즐긴다',
  '다양한 사람들과 소통하고 협력하는 것이 좋다',
  '경제 현상이나 시장 흐름에 관심이 있다',
  '어떤 일을 계획하고 전략적으로 실행하는 것을 즐긴다',
  '데이터를 보고 의사결정을 내리는 것이 흥미롭다',
  '창업이나 비즈니스 아이디어를 떠올리는 것을 좋아한다',
  '숫자나 통계를 다루는 것이 어렵지 않다',
  '그림, 디자인, 영상 등 시각적 표현에 관심이 있다',
  '음악, 무용, 공연 등 예술 활동을 즐긴다',
  '나만의 아이디어로 새로운 것을 창작하는 것을 좋아한다',
  '공간이나 건축물의 디자인에 관심이 있다',
  '미디어 콘텐츠를 기획하거나 제작하고 싶다',
];

const _surveyWeights = {
  'life_science': [1, 2, 4, 5, 11],
  'medicine': [11, 12, 13, 14, 15],
  'computer_ai': [7, 8, 9, 10, 23],
  'mechanical': [6, 8, 9, 10, 3],
  'chemistry': [2, 3, 4, 6, 10],
  'math_stats': [3, 8, 23, 25, 22],
  'environment': [1, 4, 5, 14, 18],
  'education': [15, 17, 19, 20, 12],
  'psychology': [17, 18, 20, 12, 14],
  'business': [21, 22, 23, 24, 25],
  'humanities': [16, 17, 18, 19, 20],
  'media_design': [26, 27, 28, 29, 30],
  'sports': [27, 20, 28, 14, 10],
  'architecture': [6, 8, 10, 29, 5],
  'agriculture': [1, 4, 5, 14, 2],
  'law': [18, 19, 20, 22, 16],
};

enum _MajorFitFilter { all, stable, match, reach }

class _CareerResultCard extends StatefulWidget {
  const _CareerResultCard({required this.path, required this.myGrade});

  final CareerPath path;
  final double? myGrade;

  @override
  State<_CareerResultCard> createState() => _CareerResultCardState();
}

class _CareerResultCardState extends State<_CareerResultCard> {
  late Future<List<Map<String, dynamic>>> majorsFuture;
  _MajorFitFilter filter = _MajorFitFilter.all;

  @override
  void initState() {
    super.initState();
    majorsFuture = InseoulMajorService.instance.getMajorsByCareerPath(
      widget.path.id,
    );
  }

  @override
  void didUpdateWidget(covariant _CareerResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path.id != widget.path.id) {
      majorsFuture = InseoulMajorService.instance.getMajorsByCareerPath(
        widget.path.id,
      );
      filter = _MajorFitFilter.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CareerPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.path.category,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _ChipSection(
            title: '관련 키워드',
            values: widget.path.keywords.take(10).toList(),
          ),
          _InseoulMajorSection(
            future: majorsFuture,
            myGrade: widget.myGrade,
            filter: filter,
            onFilterChanged: (value) => setState(() => filter = value),
          ),
          _ChipSection(title: '추천 선택과목', values: widget.path.subjects),
          _ChipSection(title: '진로 준비 활동', values: widget.path.activities),
          _ChipSection(title: '대표 진로', values: widget.path.roles),
          _ChipSection(title: '핵심 역량', values: widget.path.competencies),
          _ChipSection(title: '탐구 주제', values: widget.path.projects),
          const SizedBox(height: 6),
          Text(widget.path.advice, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}

class _InseoulMajorSection extends StatelessWidget {
  const _InseoulMajorSection({
    required this.future,
    required this.myGrade,
    required this.filter,
    required this.onFilterChanged,
  });

  final Future<List<Map<String, dynamic>>> future;
  final double? myGrade;
  final _MajorFitFilter filter;
  final ValueChanged<_MajorFitFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '인서울 관련 학과',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          if (myGrade != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _MajorFitFilter.values.map((value) {
                return ChoiceChip(
                  label: Text(_filterLabel(value)),
                  selected: filter == value,
                  onSelected: (_) => onFilterChanged(value),
                  showCheckmark: false,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 4),
                );
              }
              final majors = snapshot.data ?? const <Map<String, dynamic>>[];
              final filtered = _filterMajors(majors, myGrade, filter);
              if (filtered.isEmpty) {
                return Text(
                  '조건에 맞는 학과가 없습니다.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }

              final visible = filtered.take(10).toList();
              final rest = filtered.length - visible.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...visible.map(
                    (major) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _MajorLine(major: major, myGrade: myGrade),
                    ),
                  ),
                  if (rest > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '외 $rest개',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MajorLine extends StatelessWidget {
  const _MajorLine({required this.major, required this.myGrade});

  final Map<String, dynamic> major;
  final double? myGrade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final university = major['university']?.toString() ?? '';
    final name = major['name']?.toString() ?? '';
    final fit = myGrade == null ? null : _majorFit(myGrade!, major);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary.withAlpha(14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withAlpha(55)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$university · $name',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (fit != null) ...[
            const SizedBox(width: 8),
            Text(
              fit.label,
              style: TextStyle(color: fit.color, fontWeight: FontWeight.w900),
            ),
          ],
        ],
      ),
    );
  }
}

class _MajorFit {
  const _MajorFit(this.label, this.color, this.filter);

  final String label;
  final Color color;
  final _MajorFitFilter? filter;
}

List<Map<String, dynamic>> _filterMajors(
  List<Map<String, dynamic>> majors,
  double? grade,
  _MajorFitFilter filter,
) {
  if (grade == null || filter == _MajorFitFilter.all) return majors;
  return majors
      .where((major) => _majorFit(grade, major).filter == filter)
      .toList();
}

_MajorFit _majorFit(double grade, Map<String, dynamic> major) {
  final cutoff = _readCutoff(major['cutoff']);
  if (cutoff == null) {
    return const _MajorFit('정보 없음', Color(0xFF64748B), null);
  }
  if (grade <= cutoff - 0.5) {
    return const _MajorFit('✅ 안정권', Color(0xFF059669), _MajorFitFilter.stable);
  }
  if (grade <= cutoff) {
    return const _MajorFit('🟡 적정권', Color(0xFFB7791F), _MajorFitFilter.match);
  }
  if (grade <= cutoff + 0.5) {
    return const _MajorFit('🔶 소신지원', Color(0xFFEA580C), _MajorFitFilter.reach);
  }
  return const _MajorFit('❌ 어려움', Color(0xFFDC2626), null);
}

double? _readCutoff(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _filterLabel(_MajorFitFilter filter) {
  return switch (filter) {
    _MajorFitFilter.all => '전체',
    _MajorFitFilter.stable => '안정권',
    _MajorFitFilter.match => '적정권',
    _MajorFitFilter.reach => '소신지원',
  };
}

class _RankedCareerOption extends StatelessWidget {
  const _RankedCareerOption({
    required this.rank,
    required this.path,
    required this.selected,
    required this.onTap,
  });

  final int rank;
  final CareerPath path;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withAlpha(28)
              : scheme.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? scheme.primary : scheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    path.majors.take(3).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: values
                .map(
                  (value) => Chip(
                    backgroundColor: scheme.primary.withAlpha(22),
                    side: BorderSide(color: scheme.primary.withAlpha(80)),
                    labelStyle: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    label: Text(value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CareerPanel extends StatelessWidget {
  const _CareerPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

String encodeCareerProfile(List<CareerPath> paths) {
  return jsonEncode(paths.map((path) => path.id).toList());
}

import 'dart:convert';

import 'package:flutter/services.dart';

class InseoulMajorService {
  InseoulMajorService._();

  static final InseoulMajorService instance = InseoulMajorService._();

  Map<String, List<Map<String, dynamic>>>? _cache;

  static const Map<String, String> careerCategoryMap = {
    'life_science': '자연과학',
    'medicine': '의학',
    'computer_ai': '공학',
    'mechanical': '공학',
    'chemistry': '자연과학',
    'math_stats': '자연과학',
    'environment': '자연과학',
    'education': '인문사회',
    'psychology': '인문사회',
    'business': '인문사회',
    'humanities': '인문사회',
    'media_design': '예체능',
    'sports': '예체능',
    'architecture': '공학',
    'agriculture': '자연과학',
    'law': '인문사회',
  };

  Future<Map<String, List<Map<String, dynamic>>>> _load() async {
    if (_cache != null) return _cache!;

    final text = await rootBundle.loadString(
      'assets/data/inseoul_major_data.json',
    );
    final decoded = jsonDecode(text) as Map<String, dynamic>;
    _cache = decoded.map((university, majors) {
      final majorList = (majors as List<dynamic>)
          .map((major) => Map<String, dynamic>.from(major as Map))
          .toList();
      return MapEntry(university, majorList);
    });
    return _cache!;
  }

  Future<List<String>> getUniversityList() async {
    final data = await _load();
    final universities = data.keys.toList()..sort();
    return universities;
  }

  Future<List<Map<String, dynamic>>> getMajorsByUniversity(
    String universityName,
  ) async {
    final data = await _load();
    return List<Map<String, dynamic>>.from(data[universityName] ?? const []);
  }

  Future<List<Map<String, dynamic>>> getMajorsByCategory(
    String category,
  ) async {
    final data = await _load();
    final results = <Map<String, dynamic>>[];
    for (final entry in data.entries) {
      for (final major in entry.value) {
        if (major['category']?.toString() == category) {
          results.add({...major, 'university': entry.key});
        }
      }
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> searchMajors(String keyword) async {
    final data = await _load();
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final results = <Map<String, dynamic>>[];
    for (final entry in data.entries) {
      for (final major in entry.value) {
        final name = major['name']?.toString().toLowerCase() ?? '';
        if (name.contains(query)) {
          results.add({...major, 'university': entry.key});
        }
      }
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getMajorsByCareerPath(
    String careerPathId,
  ) async {
    final category = careerCategoryMap[careerPathId];
    if (category == null) return const [];
    return getMajorsByCategory(category);
  }
}

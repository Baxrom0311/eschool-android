import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/rating_provider.dart';
import 'package:parent_school_app/data/datasources/remote/rating_api.dart';
import 'package:parent_school_app/data/models/rating_model.dart';
import 'package:parent_school_app/core/error/exceptions.dart';

// Mock RatingApi
class MockRatingApi implements RatingApi {
  bool shouldThrowError = false;

  @override
  Future<List<RatingModel>> getClassRating(int classId) async {
    if (shouldThrowError) {
      throw const ServerException(message: 'Class rating failed');
    }
    return const [
      RatingModel(id: 1, studentName: 'Student 1', rank: 1, totalScore: 95.0),
      RatingModel(id: 2, studentName: 'Student 2', rank: 2, totalScore: 90.0),
    ];
  }

  @override
  Future<List<RatingModel>> getSchoolRating() async {
    if (shouldThrowError) {
      throw const ServerException(message: 'School rating failed');
    }
    return const [
      RatingModel(id: 1, studentName: 'Student 1', rank: 1, totalScore: 95.0),
      RatingModel(id: 3, studentName: 'Student 3', rank: 2, totalScore: 85.0),
    ];
  }

  @override
  Future<RatingModel> getChildRating(int childId) async {
    if (shouldThrowError) {
      throw const ServerException(message: 'Child rating failed');
    }
    return const RatingModel(
      id: 1, 
      studentName: 'My Child', 
      rank: 5, 
      totalScore: 80.0, 
      isCurrent: true
    );
  }
}

void main() {
  late MockRatingApi mockApi;
  late RatingNotifier ratingNotifier;

  setUp(() {
    mockApi = MockRatingApi();
    ratingNotifier = RatingNotifier(api: mockApi);
  });

  group('RatingNotifier Tests', () {
    test('Initial state correct', () {
      expect(ratingNotifier.state.isLoading, false);
      expect(ratingNotifier.state.classRating, isEmpty);
      expect(ratingNotifier.state.schoolRating, isEmpty);
      expect(ratingNotifier.state.childRating, null);
    });

    test('loadClassRating success', () async {
      await ratingNotifier.loadClassRating(1);
      
      expect(ratingNotifier.state.isLoading, false);
      expect(ratingNotifier.state.classRating.length, 2);
      expect(ratingNotifier.state.error, null);
    });

    test('loadClassRating failure', () async {
      mockApi.shouldThrowError = true;
      await ratingNotifier.loadClassRating(1);
      
      expect(ratingNotifier.state.isLoading, false);
      expect(ratingNotifier.state.error, 'Class rating failed');
    });

    test('loadSchoolRating success', () async {
      await ratingNotifier.loadSchoolRating();
      
      expect(ratingNotifier.state.isLoading, false);
      expect(ratingNotifier.state.schoolRating.length, 2);
    });

    test('loadChildRating success', () async {
      await ratingNotifier.loadChildRating(1);
      
      expect(ratingNotifier.state.childRating, isNotNull);
      expect(ratingNotifier.state.childRating?.rank, 5);
      expect(ratingNotifier.state.childRating?.isCurrent, true);
    });

    test('loadChildRating failure (silent)', () async {
      mockApi.shouldThrowError = true;
      await ratingNotifier.loadChildRating(1);
      
      // Should remain null or previous state (silent fail)
      expect(ratingNotifier.state.childRating, null);
    });
  });
}

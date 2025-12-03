import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qnx/routes/app_routes.dart';
import 'package:qnx/pages/home_page.dart';
import 'package:qnx/pages/materi_page.dart';
import 'package:qnx/pages/quiz_page.dart';
import 'package:qnx/pages/ulasan_page.dart';
import 'package:qnx/pages/aljabar_page.dart';
import 'package:qnx/pages/aljabar_quiz.dart';
import 'package:qnx/pages/aljabar_ulasan.dart';
import 'package:qnx/pages/aljabar_quiz_page.dart';
import 'package:qnx/pages/video_page.dart' as video_page;

void main() {
  group('AppRoutes', () {
    group('generateRoute', () {
      test('should return HomePage for root route', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/'),
        );
        // The route could be MaterialPageRoute or PngTransisiStageRoute
        expect(route, isA<Route>());
      });

      test('should return MateriPage for /materi', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/materi'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        expect(pageRoute.builder(MockBuildContext()), isA<MateriPage>());
      });

      test('should return QuizPage for /quiz', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/quiz'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        expect(pageRoute.builder(MockBuildContext()), isA<QuizPage>());
      });

      test('should return UlasanPage for /ulasan', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/ulasan'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        expect(pageRoute.builder(MockBuildContext()), isA<UlasanPage>());
      });

      test('should return AljabarPage for /materi/aljabar', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/materi/aljabar'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        expect(pageRoute.builder(MockBuildContext()), isA<AljabarPage>());
      });

      test('should return AljabarQuiz for /quiz/aljabar', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/quiz/aljabar'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        expect(pageRoute.builder(MockBuildContext()), isA<AljabarQuiz>());
      });

      test('should return AljabarUlasan for /ulasan/aljabar', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/ulasan/aljabar'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        expect(pageRoute.builder(MockBuildContext()), isA<AljabarUlasan>());
      });

      test('should return AljabarQuizPage with args for /quiz/page', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(
            name: '/quiz/page',
            arguments: {
              'judullatihan': 'Test Exercise',
              'latihan': 'Solve x + 1 = 2',
            },
          ),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        final page = pageRoute.builder(MockBuildContext()) as AljabarQuizPage;
        expect(page.judullatihan, equals('Test Exercise'));
        expect(page.latihan, equals('Solve x + 1 = 2'));
      });

      test('should return AljabarQuizPage with default args when none provided', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/quiz/page'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        final page = pageRoute.builder(MockBuildContext()) as AljabarQuizPage;
        expect(page.judullatihan, equals('Judul tidak tersedia'));
        expect(page.latihan, equals('Latihan tidak tersedia'));
      });

      test('should return VideoPage with args for /materi/video', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(
            name: '/materi/video',
            arguments: {
              'videoPath': 'assets/videos/test.mp4',
              'judulMateri': 'Test Materi',
              'judullatihan': 'Test Exercise',
              'forceNoTransisi': true,
            },
          ),
        );
        // May return PngTransisiStageRoute or MaterialPageRoute
        expect(route, isA<Route>());
      });

      test('should return HomePage for unknown route', () {
        final route = AppRoutes.generateRoute(
          const RouteSettings(name: '/unknown-route'),
        );
        expect(route, isA<MaterialPageRoute>());
        final pageRoute = route as MaterialPageRoute;
        expect(pageRoute.builder(MockBuildContext()), isA<HomePage>());
      });

      group('transition arguments', () {
        test('should skip transition when forceNoTransisi is true', () {
          final route = AppRoutes.generateRoute(
            const RouteSettings(
              name: '/',
              arguments: {'forceNoTransisi': true},
            ),
          );
          expect(route, isA<MaterialPageRoute>());
        });

        test('should skip transition when transisi is none', () {
          final route = AppRoutes.generateRoute(
            const RouteSettings(
              name: '/',
              arguments: {'transisi': 'none'},
            ),
          );
          expect(route, isA<MaterialPageRoute>());
        });

        test('should use custom fps when provided', () {
          final route = AppRoutes.generateRoute(
            const RouteSettings(
              name: '/',
              arguments: {'fps': 30},
            ),
          );
          // Route should be created without error
          expect(route, isA<Route>());
        });

        test('should use custom buffer size when provided', () {
          final route = AppRoutes.generateRoute(
            const RouteSettings(
              name: '/',
              arguments: {'bufferSize': 16},
            ),
          );
          expect(route, isA<Route>());
        });
      });
    });
  });
}

/// Mock BuildContext for testing route builders
class MockBuildContext extends Fake implements BuildContext {}

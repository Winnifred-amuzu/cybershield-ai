import 'package:flutter_test/flutter_test.dart';

import 'package:cybershield_ai/services/text_utils.dart';

void main() {
  group('TextUtils.cleanText', () {
    test('removes leading and trailing whitespace', () {
      expect(
        TextUtils.cleanText('   Hello World   '),
        'Hello World',
      );
    });

    test('collapses repeated whitespace', () {
      expect(
        TextUtils.cleanText(
          'Hello    World\nThis   is   a test',
        ),
        'Hello World This is a test',
      );
    });

    test('returns empty string for whitespace-only text', () {
      expect(
        TextUtils.cleanText('   \n\t  '),
        '',
      );
    });

    test('preserves normal text', () {
      expect(
        TextUtils.cleanText(
          'Congratulations! You won a prize.',
        ),
        'Congratulations! You won a prize.',
      );
    });
  });

  group('TextUtils.preview', () {
    test('returns original text when within max length', () {
      const text = 'This is a short message.';

      expect(
        TextUtils.preview(text, max: 100),
        text,
      );
    });

    test('truncates long text', () {
      const text =
          'This is a very long message that needs to be shortened for display.';

      final result = TextUtils.preview(
        text,
        max: 30,
      );

      expect(result.length, lessThanOrEqualTo(30));
      expect(result.endsWith('...'), isTrue);
    });

    test('supports maxLength for backward compatibility', () {
      const text =
          'This is a message that should be shortened.';

      final result = TextUtils.preview(
        text,
        maxLength: 20,
      );

      expect(result.length, lessThanOrEqualTo(20));
      expect(result.endsWith('...'), isTrue);
    });

    test('handles zero maximum length', () {
      expect(
        TextUtils.preview(
          'Hello World',
          max: 0,
        ),
        '',
      );
    });
  });

  group('TextUtils.extractUrls', () {
    test('extracts HTTPS URL', () {
      final urls = TextUtils.extractUrls(
        'Visit https://example.com now.',
      );

      expect(
        urls,
        contains('https://example.com'),
      );
    });

    test('extracts HTTP URL', () {
      final urls = TextUtils.extractUrls(
        'Visit http://example.com now.',
      );

      expect(
        urls,
        contains('http://example.com'),
      );
    });

    test('extracts www URL', () {
      final urls = TextUtils.extractUrls(
        'Visit www.example.com now.',
      );

      expect(
        urls,
        contains('www.example.com'),
      );
    });

    test('returns empty list when no URL exists', () {
      final urls = TextUtils.extractUrls(
        'This message contains no links.',
      );

      expect(urls, isEmpty);
    });

    test('removes punctuation following a URL', () {
      final urls = TextUtils.extractUrls(
        'Visit https://example.com.',
      );

      expect(
        urls,
        contains('https://example.com'),
      );
    });
  });

  group('TextUtils.containsUrl', () {
    test('returns true when URL exists', () {
      expect(
        TextUtils.containsUrl(
          'Click https://example.com',
        ),
        isTrue,
      );
    });

    test('returns false when URL does not exist', () {
      expect(
        TextUtils.containsUrl(
          'This message has no URL.',
        ),
        isFalse,
      );
    });
  });

  group('TextUtils.cleanError', () {
    test('removes Exception prefix', () {
      expect(
        TextUtils.cleanError(
          Exception('Something went wrong'),
        ),
        'Something went wrong',
      );
    });

    test('removes ApiException prefix', () {
      expect(
        TextUtils.cleanError(
          'ApiException: Request failed',
        ),
        'Request failed',
      );
    });

    test('returns fallback for empty errors', () {
      expect(
        TextUtils.cleanError(''),
        'Something went wrong. Please try again.',
      );
    });
  });

  group('TextUtils.formatPercent', () {
    test('formats decimal probability as percentage', () {
      expect(
        TextUtils.formatPercent(0.934),
        '93.4%',
      );
    });

    test('formats zero correctly', () {
      expect(
        TextUtils.formatPercent(0),
        '0.0%',
      );
    });

    test('formats one correctly', () {
      expect(
        TextUtils.formatPercent(1),
        '100.0%',
      );
    });
  });

  group('TextUtils.formatConfidence', () {
    test('formats confidence as percentage', () {
      expect(
        TextUtils.formatConfidence(0.875),
        '87.5%',
      );
    });
  });

  group('TextUtils.normalize', () {
    test('normalizes whitespace', () {
      expect(
        TextUtils.normalize(
          '  Hello    World  ',
        ),
        'Hello World',
      );
    });
  });
}
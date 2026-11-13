import 'package:flutter_test/flutter_test.dart';
import 'package:rahba_digital/domain/age_rules.dart';

void main() {
  group('canBeBreedingAdult', () {
    test('allows classification at exactly 13 months', () {
      expect(
        canBeBreedingAdult(DateTime(2025, 10, 13), DateTime(2026, 11, 13)),
        isTrue,
      );
    });

    test('blocks classification before 13 months', () {
      expect(
        canBeBreedingAdult(DateTime(2025, 10, 14), DateTime(2026, 11, 13)),
        isFalse,
      );
    });

    test('blocks when birth date is missing', () {
      expect(canBeBreedingAdult(null, DateTime(2026, 11, 13)), isFalse);
    });

    test('blocks a future birth date', () {
      expect(
        canBeBreedingAdult(DateTime(2026, 12, 1), DateTime(2026, 11, 13)),
        isFalse,
      );
    });
  });
}

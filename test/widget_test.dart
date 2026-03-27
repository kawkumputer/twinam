import 'package:flutter_test/flutter_test.dart';
import 'package:twinam/models/counter.dart';

void main() {
  test('Counter increment works', () {
    final counter = Counter(id: 'test', name: 'Test');
    expect(counter.value, 0);
    counter.increment();
    expect(counter.value, 1);
  });

  test('Counter decrement does not go below 0', () {
    final counter = Counter(id: 'test', name: 'Test', value: 0);
    counter.decrement();
    expect(counter.value, 0);
  });

  test('Counter goal progress works', () {
    final counter = Counter(id: 'test', name: 'Test', value: 5, goal: 10);
    expect(counter.progress, 0.5);
  });

  test('Counter goal reached works', () {
    final counter = Counter(id: 'test', name: 'Test', value: 10, goal: 10);
    expect(counter.goalReached, true);
  });
}

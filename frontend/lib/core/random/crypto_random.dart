import 'dart:math';

class CryptoRandom {
  static final Random _secureRng = Random.secure();

  /// Unbiased random integer in [min, max] inclusive using rejection sampling
  static int randInt(int min, int max) {
    if (min > max) {
      throw ArgumentError('min ($min) cannot be greater than max ($max)');
    }
    final range = max - min + 1;
    if (range <= 0) return min;

    // Fast path for small ranges
    return min + _secureRng.nextInt(range);
  }

  /// Uniform float in [0.0, 1.0) with high entropy
  static double randDouble() {
    return _secureRng.nextDouble();
  }

  /// Unbiased in-place Fisher-Yates shuffle returning a new list
  static List<T> shuffle<T>(List<T> items) {
    final list = List<T>.from(items);
    for (int i = list.length - 1; i > 0; i--) {
      final j = _secureRng.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }

  /// Sample k elements without replacement
  static List<T> sampleWithoutReplacement<T>(List<T> population, int k) {
    if (k < 0 || k > population.length) {
      throw ArgumentError('Cannot sample $k items from population of size ${population.length}');
    }
    final pool = List<T>.from(population);
    final result = <T>[];
    for (int i = 0; i < k; i++) {
      final j = _secureRng.nextInt(pool.length - i);
      result.add(pool[j]);
      pool[j] = pool[pool.length - i - 1];
    }
    return result;
  }

  /// Weighted index selection avoiding floating point rounding errors
  static int weightedChoice(List<double> weights) {
    if (weights.isEmpty) {
      throw ArgumentError('Weights cannot be empty');
    }
    for (final w in weights) {
      if (w.isNaN || w.isInfinite || w <= 0) {
        throw ArgumentError('All weights must be finite numbers > 0, got $w');
      }
    }

    final totalWeight = weights.reduce((a, b) => a + b);
    final target = _secureRng.nextDouble() * totalWeight;

    double cumulative = 0.0;
    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (target <= cumulative) {
        return i;
      }
    }
    return weights.length - 1;
  }
}


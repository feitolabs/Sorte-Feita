import os
import secrets
import math
from typing import List, TypeVar, Optional, Protocol

T = TypeVar("T")


class RandomSource(Protocol):
    """Protocol for random sources to allow deterministic mocking in tests."""
    def randbelow(self, n: int) -> int:
        ...

    def random(self) -> float:
        ...


class SecureRandomSource:
    """Production Cryptographically Secure Pseudo-Random Number Generator (CSPRNG)."""
    def randbelow(self, n: int) -> int:
        if n <= 0:
            raise ValueError("n must be positive")
        return secrets.randbelow(n)

    def random(self) -> float:
        """Generates a uniform float in [0.0, 1.0) using 53 bits of entropy."""
        return secrets.randbits(53) / (1 << 53)


class DeterministicRandomSource:
    """Mock random source for deterministic unit testing."""
    def __init__(self, sequence: Optional[List[int]] = None, float_sequence: Optional[List[float]] = None):
        self.sequence = sequence or []
        self.float_sequence = float_sequence or []
        self.seq_index = 0
        self.float_index = 0

    def randbelow(self, n: int) -> int:
        if not self.sequence:
            return 0
        val = self.sequence[self.seq_index % len(self.sequence)]
        self.seq_index += 1
        return val % n

    def random(self) -> float:
        if not self.float_sequence:
            return 0.0
        val = self.float_sequence[self.float_index % len(self.float_sequence)]
        self.float_index += 1
        return val


# Default production source
default_random_source = SecureRandomSource()


def unbiased_randint(min_val: int, max_val: int, rng: RandomSource = default_random_source) -> int:
    """Generates an unbiased random integer in [min_val, max_val] inclusive."""
    if min_val > max_val:
        raise ValueError(f"min_val ({min_val}) cannot be greater than max_val ({max_val})")
    span = max_val - min_val + 1
    return min_val + rng.randbelow(span)


def fisher_yates_shuffle(items: List[T], rng: RandomSource = default_random_source) -> List[T]:
    """In-place style Fisher-Yates unbiased shuffle, returning a new shuffled list."""
    shuffled = list(items)
    for i in range(len(shuffled) - 1, 0, -1):
        j = rng.randbelow(i + 1)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    return shuffled


def sample_without_replacement(population: List[T], k: int, rng: RandomSource = default_random_source) -> List[T]:
    """Samples k items from population without replacement using partial Fisher-Yates."""
    n = len(population)
    if k < 0 or k > n:
        raise ValueError(f"Cannot sample {k} elements from population of size {n}")
    pool = list(population)
    result = []
    for i in range(k):
        j = rng.randbelow(n - i)
        result.append(pool[j])
        pool[j] = pool[n - i - 1]
    return result


def weighted_choice_index(weights: List[float], rng: RandomSource = default_random_source) -> int:
    """Picks an index according to positive weights avoiding floating point skew."""
    if not weights:
        raise ValueError("Weights cannot be empty")
    for w in weights:
        if math.isnan(w) or math.isinf(w) or w <= 0:
            raise ValueError(f"All weights must be finite numbers > 0, got {w}")

    total_weight = sum(weights)
    r = rng.random() * total_weight
    cumulative = 0.0
    for idx, w in enumerate(weights):
        cumulative += w
        if r <= cumulative:
            return idx
    return len(weights) - 1


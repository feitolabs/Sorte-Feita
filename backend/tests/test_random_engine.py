import pytest
from app.core.security import (
    DeterministicRandomSource,
    unbiased_randint,
    fisher_yates_shuffle,
    weighted_choice_index
)
from app.services.random_engine import RandomEngineService
from app.models.schemas import (
    WheelModel,
    WheelOption,
    NameDrawRequest,
    NumberDrawRequest,
    TeamDrawRequest
)


def test_unbiased_randint():
    # Deterministic mock returns values
    mock_rng = DeterministicRandomSource(sequence=[0, 1, 9])
    val1 = unbiased_randint(1, 10, rng=mock_rng)
    assert 1 <= val1 <= 10


def test_fisher_yates_shuffle_preserves_elements():
    items = ["A", "B", "C", "D", "E"]
    shuffled = fisher_yates_shuffle(items)
    assert len(shuffled) == len(items)
    assert set(shuffled) == set(items)


def test_weighted_choice():
    # Weight of 0 should raise ValueError
    with pytest.raises(ValueError):
        weighted_choice_index([1.0, 0.0])

    # Weights [1.0, 3.0]
    # Float 0.1 out of 4.0 -> index 0
    # Float 0.5 out of 4.0 -> index 1
    mock_rng = DeterministicRandomSource(float_sequence=[0.1 / 4.0])
    idx = weighted_choice_index([1.0, 3.0], rng=mock_rng)
    assert idx == 0

    mock_rng = DeterministicRandomSource(float_sequence=[2.5 / 4.0])
    idx = weighted_choice_index([1.0, 3.0], rng=mock_rng)
    assert idx == 1


def test_spin_wheel_validations():
    service = RandomEngineService()
    # Less than 2 active options must fail
    wheel = WheelModel(
        name="Teste",
        options=[
            WheelOption(label="Op1", active=True),
            WheelOption(label="Op2", active=False)
        ]
    )
    with pytest.raises(ValueError):
        service.spin_wheel(wheel)


def test_draw_names_duplicate_removal_and_counts():
    service = RandomEngineService()
    req = NameDrawRequest(
        title="Turma",
        participants=["Ana", "Bruno", "Ana", "Carla", "Diego"],
        winners_count=2,
        alternates_count=1,
        allow_duplicates=False
    )
    res = service.draw_names(req)
    assert res.total_eligible == 4
    assert res.duplicates_removed_count == 1
    assert len(res.winners) == 2
    assert len(res.alternates) == 1
    # Winners and alternates cannot overlap
    assert not set(res.winners).intersection(set(res.alternates))


def test_draw_numbers_interval_and_exclusions():
    service = RandomEngineService()
    req = NumberDrawRequest(
        min_val=1,
        max_val=10,
        count=5,
        excluded=[2, 4, 6, 8, 10],
        allow_repeat=False,
        sort_result=True
    )
    res = service.draw_numbers(req)
    assert len(res.numbers) == 5
    assert set(res.numbers).issubset({1, 3, 5, 7, 9})
    assert res.numbers == sorted(res.numbers)


def test_draw_teams_balanced():
    service = RandomEngineService()
    participants = [f"Pessoa {i}" for i in range(13)]
    req = TeamDrawRequest(
        participants=participants,
        mode="teams_count",
        target_count=3,
        pick_captains=True
    )
    res = service.draw_teams(req)
    assert len(res.teams) == 3
    team_sizes = [len(t.members) for t in res.teams]
    # 13 divided by 3 should be 5, 4, 4 (difference max 1)
    assert sorted(team_sizes) == [4, 4, 5]
    for team in res.teams:
        assert team.captain is not None
        assert team.captain in team.members


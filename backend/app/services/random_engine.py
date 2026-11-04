from typing import List, Tuple, Dict, Any, Optional
import math
from app.core.security import (
    RandomSource,
    default_random_source,
    unbiased_randint,
    fisher_yates_shuffle,
    sample_without_replacement,
    weighted_choice_index
)
from app.models.schemas import (
    WheelModel,
    SpinResponse,
    NameDrawRequest,
    NameDrawResponse,
    NumberDrawRequest,
    NumberDrawResponse,
    TeamDrawRequest,
    TeamDrawResponse,
    Team,
    DecisionRequest,
    DecisionResponse
)

PRESET_TEAM_NAMES = [
    ("Equipe Rio", "#1F7A8C"),
    ("Equipe Mar", "#0E3B43"),
    ("Equipe Serra", "#5FB3C2"),
    ("Equipe Sol", "#F26B21"),
    ("Equipe Duna", "#8FC1C9"),
    ("Equipe Vento", "#A9D3DA"),
    ("Equipe Floresta", "#2D6A4F"),
    ("Equipe Estrela", "#E76F51")
]


class RandomEngineService:
    def __init__(self, rng: Optional[RandomSource] = None):
        self.rng = rng or default_random_source

    def spin_wheel(self, wheel: WheelModel) -> SpinResponse:
        active_options = [opt for opt in wheel.options if opt.active]
        if len(active_options) < 2:
            raise ValueError("A roleta deve ter pelo menos 2 opções ativas para girar.")

        weights = [opt.weight if wheel.different_weights else 1.0 for opt in active_options]
        total_weight = sum(weights)
        if total_weight <= 0:
            raise ValueError("A soma dos pesos deve ser maior que zero.")

        winner_idx = weighted_choice_index(weights, self.rng)
        winner_option = active_options[winner_idx]

        probability = (weights[winner_idx] / total_weight) * 100.0

        # Calculate exact geometric angular bounds on the wheel
        # Wheel segments are arranged sequentially. Top pointer is convention 0 or 270 deg.
        # Segment i occupies arc from start_angle to end_angle:
        cumulative_angle = 0.0
        start_angle = 0.0
        arc_length = 0.0
        for i, w in enumerate(weights):
            seg_arc = (w / total_weight) * 360.0
            if i == winner_idx:
                start_angle = cumulative_angle
                arc_length = seg_arc
                break
            cumulative_angle += seg_arc

        # Place landing angle inside segment, with 10% safety margin away from edges
        margin = max(1.0, arc_length * 0.1)
        safe_arc = max(0.5, arc_length - 2 * margin)
        offset = margin + (self.rng.random() * safe_arc)
        target_segment_angle = start_angle + offset

        return SpinResponse(
            winner_id=winner_option.id,
            winner_label=winner_option.label,
            winner_index=winner_idx,
            probability_percentage=round(probability, 1),
            total_active_options=len(active_options),
            landing_angle_degrees=round(target_segment_angle, 2)
        )

    def draw_names(self, request: NameDrawRequest) -> NameDrawResponse:
        # Strip whitespace, ignore empty lines
        cleaned = [p.strip() for p in request.participants if p.strip()]
        if not cleaned:
            raise ValueError("A lista de participantes não pode estar vazia.")

        initial_count = len(cleaned)
        if request.allow_duplicates:
            eligible = list(cleaned)
            duplicates_removed = 0
        else:
            # Preserve order while removing duplicates
            seen = set()
            eligible = []
            for name in cleaned:
                if name not in seen:
                    seen.add(name)
                    eligible.append(name)
            duplicates_removed = initial_count - len(eligible)

        total_eligible = len(eligible)
        if request.winners_count < 1:
            raise ValueError("A quantidade de ganhadores deve ser pelo menos 1.")

        if request.winners_count > total_eligible:
            raise ValueError(f"Quantidade de ganhadores ({request.winners_count}) excede o total elegível ({total_eligible}).")

        if (request.winners_count + request.alternates_count) > total_eligible:
            raise ValueError(
                f"Soma de ganhadores e suplentes ({request.winners_count + request.alternates_count}) "
                f"excede participantes elegíveis ({total_eligible})."
            )

        # Shuffle eligible participants with CSPRNG
        shuffled = fisher_yates_shuffle(eligible, self.rng)
        winners = shuffled[:request.winners_count]
        alternates = shuffled[request.winners_count: request.winners_count + request.alternates_count]

        return NameDrawResponse(
            title=request.title or "Sorteio de Nomes",
            winners=winners,
            alternates=alternates,
            total_eligible=total_eligible,
            duplicates_removed_count=duplicates_removed
        )

    def draw_numbers(self, request: NumberDrawRequest) -> NumberDrawResponse:
        if request.min_val > request.max_val:
            raise ValueError(f"Mínimo ({request.min_val}) não pode ser maior que o máximo ({request.max_val}).")

        excluded_set = set(request.excluded)
        full_pool = [n for n in range(request.min_val, request.max_val + 1) if n not in excluded_set]

        if not full_pool and not request.allow_repeat:
            raise ValueError("Não há números disponíveis no intervalo especificado após exclusões.")

        if not request.allow_repeat:
            if request.count > len(full_pool):
                raise ValueError(
                    f"Quantidade solicitada ({request.count}) excede números disponíveis no intervalo ({len(full_pool)})."
                )
            result = sample_without_replacement(full_pool, request.count, self.rng)
        else:
            if not full_pool:
                raise ValueError("Nenhum número elegível no intervalo.")
            result = [full_pool[self.rng.randbelow(len(full_pool))] for _ in range(request.count)]

        if request.sort_result:
            result.sort()

        return NumberDrawResponse(
            numbers=result,
            total_drawn=len(result)
        )

    def draw_teams(self, request: TeamDrawRequest) -> TeamDrawResponse:
        cleaned = [p.strip() for p in request.participants if p.strip()]
        if not cleaned:
            raise ValueError("A lista de participantes não pode estar vazia.")

        total = len(cleaned)
        if request.mode == "teams_count":
            num_teams = request.target_count
            if num_teams < 1:
                raise ValueError("Número de equipes deve ser pelo menos 1.")
            if num_teams > total:
                num_teams = total
        else:  # members_per_team
            members_per_team = request.target_count
            if members_per_team < 1:
                raise ValueError("Pessoas por equipe deve ser pelo menos 1.")
            num_teams = max(1, total // members_per_team)

        # Shuffle participants
        pool = fisher_yates_shuffle(cleaned, self.rng)

        # Distribute into balanced teams (difference in size at most 1)
        base_size = total // num_teams
        remainder = total % num_teams

        teams_list = []
        start_idx = 0
        for i in range(num_teams):
            size = base_size + (1 if i < remainder else 0)
            team_members = pool[start_idx: start_idx + size]
            start_idx += size

            preset_name, preset_color = PRESET_TEAM_NAMES[i % len(PRESET_TEAM_NAMES)]
            captain = team_members[0] if (request.pick_captains and team_members) else None

            teams_list.append(Team(
                name=preset_name if i < len(PRESET_TEAM_NAMES) else f"Equipe {i + 1}",
                color=preset_color,
                captain=captain,
                members=team_members
            ))

        return TeamDrawResponse(
            teams=teams_list,
            reserves=[],
            total_participants=total
        )

    def make_decision(self, request: DecisionRequest) -> DecisionResponse:
        options = [opt.strip() for opt in request.options if opt.strip()]
        if len(options) < 2:
            raise ValueError("Deve haver pelo menos 2 opções de decisão.")

        idx = self.rng.randbelow(len(options))
        return DecisionResponse(
            question=request.question,
            result=options[idx]
        )


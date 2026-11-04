from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
import uuid
from datetime import datetime, timezone


def get_utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


class WheelOption(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    label: str = Field(..., min_length=1, max_length=100)
    color: str = "#1F7A8C"
    icon: Optional[str] = None
    weight: float = Field(default=1.0, gt=0)
    active: bool = True
    order: int = 0


class WheelModel(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str = Field(..., min_length=1, max_length=80)
    options: List[WheelOption] = Field(..., min_length=2)
    different_weights: bool = False
    remove_on_win: bool = False
    created_at: str = Field(default_factory=get_utc_now_iso)
    updated_at: str = Field(default_factory=get_utc_now_iso)


class SpinRequest(BaseModel):
    wheel: WheelModel


class SpinResponse(BaseModel):
    winner_id: str
    winner_label: str
    winner_index: int
    probability_percentage: float
    total_active_options: int
    landing_angle_degrees: float
    timestamp: str = Field(default_factory=get_utc_now_iso)


class NameDrawRequest(BaseModel):
    title: Optional[str] = "Sorteio de Nomes"
    participants: List[str]
    winners_count: int = Field(default=1, ge=1)
    alternates_count: int = Field(default=0, ge=0)
    allow_duplicates: bool = False


class NameDrawResponse(BaseModel):
    title: str
    winners: List[str]
    alternates: List[str]
    total_eligible: int
    duplicates_removed_count: int
    timestamp: str = Field(default_factory=get_utc_now_iso)


class NumberDrawRequest(BaseModel):
    min_val: int = Field(default=1)
    max_val: int = Field(default=100)
    count: int = Field(default=1, ge=1)
    allow_repeat: bool = False
    excluded: List[int] = Field(default_factory=list)
    sort_result: bool = True


class NumberDrawResponse(BaseModel):
    numbers: List[int]
    total_drawn: int
    timestamp: str = Field(default_factory=get_utc_now_iso)


class Team(BaseModel):
    name: str
    color: str
    captain: Optional[str] = None
    members: List[str]


class TeamDrawRequest(BaseModel):
    participants: List[str]
    mode: str = Field(default="teams_count", pattern="^(teams_count|members_per_team)$")
    target_count: int = Field(..., ge=1)
    pick_captains: bool = True
    must_stay_together: List[List[str]] = Field(default_factory=list)
    cannot_stay_together: List[List[str]] = Field(default_factory=list)


class TeamDrawResponse(BaseModel):
    teams: List[Team]
    reserves: List[str]
    total_participants: int
    timestamp: str = Field(default_factory=get_utc_now_iso)


class DecisionRequest(BaseModel):
    question: Optional[str] = None
    options: List[str] = Field(default_factory=lambda: ["Sim", "Não"])


class DecisionResponse(BaseModel):
    question: Optional[str] = None
    result: str
    timestamp: str = Field(default_factory=get_utc_now_iso)


class HistoryItem(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    type: str  # wheel, name_draw, number_draw, teams, pairs, decision, tasks
    title: str
    created_at: str = Field(default_factory=get_utc_now_iso)
    config_snapshot: Dict[str, Any]
    result: Any
    is_favorite: bool = False


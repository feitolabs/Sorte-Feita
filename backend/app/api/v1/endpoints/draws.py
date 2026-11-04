from fastapi import APIRouter, HTTPException
from app.models.schemas import (
    NameDrawRequest,
    NameDrawResponse,
    NumberDrawRequest,
    NumberDrawResponse,
    DecisionRequest,
    DecisionResponse,
    HistoryItem
)
from app.services.random_engine import RandomEngineService
from app.services.storage_service import storage_service

router = APIRouter(prefix="/draws", tags=["Sorteios"])
engine = RandomEngineService()


@router.post("/names", response_model=NameDrawResponse)
def draw_names(request: NameDrawRequest):
    try:
        response = engine.draw_names(request)
        storage_service.save_activity(HistoryItem(
            type="name_draw",
            title=response.title,
            config_snapshot=request.model_dump(),
            result={"winners": response.winners, "alternates": response.alternates}
        ))
        return response
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/numbers", response_model=NumberDrawResponse)
def draw_numbers(request: NumberDrawRequest):
    try:
        response = engine.draw_numbers(request)
        storage_service.save_activity(HistoryItem(
            type="number_draw",
            title=f"Sorteio de Números ({request.min_val} a {request.max_val})",
            config_snapshot=request.model_dump(),
            result={"numbers": response.numbers}
        ))
        return response
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/decision", response_model=DecisionResponse)
def make_decision(request: DecisionRequest):
    try:
        response = engine.make_decision(request)
        storage_service.save_activity(HistoryItem(
            type="decision",
            title=request.question or "Sim ou Não",
            config_snapshot=request.model_dump(),
            result={"result": response.result}
        ))
        return response
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

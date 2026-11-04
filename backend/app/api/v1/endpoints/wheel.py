from fastapi import APIRouter, HTTPException
from typing import List, Dict, Any
from app.models.schemas import WheelModel, SpinRequest, SpinResponse, HistoryItem
from app.services.random_engine import RandomEngineService
from app.services.storage_service import storage_service

router = APIRouter(prefix="/wheel", tags=["Roleta"])
engine = RandomEngineService()


@router.post("/spin", response_model=SpinResponse)
def spin_wheel(request: SpinRequest):
    try:
        response = engine.spin_wheel(request.wheel)
        # Record into local history
        storage_service.save_activity(HistoryItem(
            type="wheel",
            title=request.wheel.name,
            config_snapshot=request.wheel.model_dump(),
            result={"winner_label": response.winner_label, "winner_index": response.winner_index}
        ))
        return response
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/saved", response_model=List[Dict[str, Any]])
def list_saved_wheels():
    return storage_service.list_wheels()


@router.post("/saved", response_model=Dict[str, Any])
def save_wheel(wheel: WheelModel):
    return storage_service.save_wheel(wheel)


@router.delete("/saved/{wheel_id}")
def delete_saved_wheel(wheel_id: str):
    success = storage_service.delete_wheel(wheel_id)
    if not success:
        raise HTTPException(status_code=404, detail="Roleta não encontrada")
    return {"message": "Roleta excluída com sucesso"}


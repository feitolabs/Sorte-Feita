from fastapi import APIRouter, HTTPException
from app.models.schemas import TeamDrawRequest, TeamDrawResponse, HistoryItem
from app.services.random_engine import RandomEngineService
from app.services.storage_service import storage_service

router = APIRouter(prefix="/teams", tags=["Equipes"])
engine = RandomEngineService()


@router.post("/generate", response_model=TeamDrawResponse)
def generate_teams(request: TeamDrawRequest):
    try:
        response = engine.draw_teams(request)
        storage_service.save_activity(HistoryItem(
            type="teams",
            title=f"Divisão em {len(response.teams)} Equipes",
            config_snapshot=request.model_dump(),
            result={"teams": [t.model_dump() for t in response.teams]}
        ))
        return response
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

from fastapi import APIRouter, HTTPException
from typing import List, Dict, Any
from app.models.schemas import HistoryItem
from app.services.storage_service import storage_service

router = APIRouter(prefix="/history", tags=["Histórico"])


@router.get("", response_model=List[Dict[str, Any]])
def get_history():
    return storage_service.list_activities()


@router.post("", response_model=Dict[str, Any])
def add_history(item: HistoryItem):
    return storage_service.save_activity(item)


@router.delete("/{activity_id}")
def delete_history_item(activity_id: str):
    success = storage_service.delete_activity(activity_id)
    if not success:
        raise HTTPException(status_code=404, detail="Atividade não encontrada")
    return {"message": "Atividade excluída com sucesso"}


@router.delete("")
def clear_all_history():
    storage_service.clear_activities()
    return {"message": "Histórico limpo com sucesso"}

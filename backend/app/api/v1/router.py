from fastapi import APIRouter
from app.api.v1.endpoints.wheel import router as wheel_router
from app.api.v1.endpoints.draws import router as draws_router
from app.api.v1.endpoints.teams import router as teams_router
from app.api.v1.endpoints.history import router as history_router
from app.api.v1.endpoints.templates import router as templates_router
from app.api.v1.endpoints.health import router as health_router

api_v1_router = APIRouter(prefix="/api/v1")
api_v1_router.include_router(health_router)
api_v1_router.include_router(wheel_router)
api_v1_router.include_router(draws_router)
api_v1_router.include_router(teams_router)
api_v1_router.include_router(history_router)
api_v1_router.include_router(templates_router)

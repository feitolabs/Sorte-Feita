from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.router import api_v1_router


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description="Sorte Feita API - Plataforma gratuita de roletas, sorteios e equipes",
        docs_url="/docs" if settings.DEBUG else None,
        redoc_url="/redoc" if settings.DEBUG else None,
    )

    # CORS configuration
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=False,  # API sem cookies/sessão
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Include API Routers
    app.include_router(api_v1_router)

    return app


app = create_app()


@app.get("/")
def root():
    return {
        "app": "Sorte Feita",
        "description": "Roletas, sorteios e equipes. Tudo grátis, sem cadastro.",
        "creator": "Feito Labs",
        "docs": "/docs" if settings.DEBUG else None
    }

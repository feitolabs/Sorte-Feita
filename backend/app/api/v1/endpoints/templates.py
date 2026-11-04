from fastapi import APIRouter
from typing import List, Dict, Any

router = APIRouter(prefix="/templates", tags=["Modelos"])

TEMPLATES_DATA: List[Dict[str, Any]] = [
    {
        "id": "tpl-comida",
        "title": "O que comer hoje",
        "category": "Alimentação",
        "description": "Escolha rápida para refeições e restaurantes",
        "type": "wheel",
        "options": [
            {"label": "Pizza", "color": "#0E3B43", "weight": 1.0},
            {"label": "Japonês", "color": "#1F7A8C", "weight": 1.0},
            {"label": "Hambúrguer", "color": "#5FB3C2", "weight": 2.0},
            {"label": "Marmita", "color": "#0E3B43", "weight": 1.0},
            {"label": "Salada", "color": "#1F7A8C", "weight": 1.0},
            {"label": "Pastel", "color": "#8FC1C9", "weight": 1.0}
        ]
    },
    {
        "id": "tpl-sala-aula",
        "title": "Turma · Ordem de Apresentação",
        "category": "Educação",
        "description": "Sorteio de alunos para seminários e leituras",
        "type": "name_draw",
        "participants": [
            "Ana Beatriz", "Bruno", "Carla", "Diego", "Eduarda",
            "Felipe", "Gabriela", "Henrique", "Isabela", "Jonas"
        ]
    },
    {
        "id": "tpl-pelada",
        "title": "Pelada de Fim de Semana",
        "category": "Esportes",
        "description": "Equipes equilibradas com capitães",
        "type": "teams",
        "participants": [
            "Carlos", "Lucas", "Matheus", "Rafael", "Rodrigo",
            "Thiago", "Pedro", "Fábio", "Gustavo", "Leonardo",
            "Guilherme", "Gabriel"
        ],
        "teams_count": 2
    },
    {
        "id": "tpl-tarefas",
        "title": "Quem lava a louça",
        "category": "Casa",
        "description": "Decisão rápida de tarefas domésticas",
        "type": "decision",
        "options": ["Sim", "Não"]
    }
]


@router.get("", response_model=List[Dict[str, Any]])
def list_templates():
    return TEMPLATES_DATA

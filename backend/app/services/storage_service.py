import os
import json
from typing import List, Optional, Dict, Any
from app.core.config import settings
from app.models.schemas import HistoryItem, WheelModel


MAX_ACTIVITIES = 500


class LocalStorageService:
    def __init__(self, storage_dir: Optional[str] = None):
        self.storage_dir = storage_dir or settings.DATA_STORAGE_DIR
        os.makedirs(self.storage_dir, exist_ok=True)
        self.activities_file = os.path.join(self.storage_dir, "activities.json")
        self.wheels_file = os.path.join(self.storage_dir, "saved_wheels.json")
        self.preferences_file = os.path.join(self.storage_dir, "preferences.json")

    def _read_json_file(self, file_path: str, default_val: Any) -> Any:
        if not os.path.exists(file_path):
            return default_val
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return default_val

    def _write_json_file(self, file_path: str, data: Any):
        temp_path = f"{file_path}.tmp"
        with open(temp_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        # Atomic rename
        if os.path.exists(file_path):
            os.remove(file_path)
        os.rename(temp_path, file_path)

    # --- Activities / History ---
    def list_activities(self) -> List[Dict[str, Any]]:
        return self._read_json_file(self.activities_file, [])

    def save_activity(self, item: HistoryItem) -> Dict[str, Any]:
        activities = self.list_activities()
        item_dict = item.model_dump()
        # Add to head of list (descending chronological order)
        activities.insert(0, item_dict)
        del activities[MAX_ACTIVITIES:]  # histórico limitado
        self._write_json_file(self.activities_file, activities)
        return item_dict

    def delete_activity(self, activity_id: str) -> bool:
        activities = self.list_activities()
        new_activities = [a for a in activities if a.get("id") != activity_id]
        if len(new_activities) != len(activities):
            self._write_json_file(self.activities_file, new_activities)
            return True
        return False

    def clear_activities(self):
        self._write_json_file(self.activities_file, [])

    # --- Saved Wheels ---
    def list_wheels(self) -> List[Dict[str, Any]]:
        return self._read_json_file(self.wheels_file, [])

    def save_wheel(self, wheel: WheelModel) -> Dict[str, Any]:
        wheels = self.list_wheels()
        wheel_dict = wheel.model_dump()
        # Update if exists, else append
        idx = next((i for i, w in enumerate(wheels) if w.get("id") == wheel.id), -1)
        if idx >= 0:
            wheels[idx] = wheel_dict
        else:
            wheels.insert(0, wheel_dict)
        self._write_json_file(self.wheels_file, wheels)
        return wheel_dict

    def delete_wheel(self, wheel_id: str) -> bool:
        wheels = self.list_wheels()
        new_wheels = [w for w in wheels if w.get("id") != wheel_id]
        if len(new_wheels) != len(wheels):
            self._write_json_file(self.wheels_file, new_wheels)
            return True
        return False


storage_service = LocalStorageService()

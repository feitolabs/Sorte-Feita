import os
import pytest
from app.services.storage_service import storage_service


@pytest.fixture(autouse=True)
def isolated_storage(tmp_path):
    """Testes nunca tocam o armazenamento real (data_storage)."""
    old = (storage_service.storage_dir, storage_service.activities_file,
           storage_service.wheels_file, storage_service.preferences_file)
    storage_service.storage_dir = str(tmp_path)
    storage_service.activities_file = os.path.join(str(tmp_path), "activities.json")
    storage_service.wheels_file = os.path.join(str(tmp_path), "saved_wheels.json")
    storage_service.preferences_file = os.path.join(str(tmp_path), "preferences.json")
    yield
    (storage_service.storage_dir, storage_service.activities_file,
     storage_service.wheels_file, storage_service.preferences_file) = old

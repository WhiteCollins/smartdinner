"""
Configuración de fixtures para pytest.

Define fixtures reutilizables para todos los tests.
"""

import pytest
from datetime import datetime, timedelta
from typing import Dict, List
import sys
from pathlib import Path

# Agregar src al path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from fastapi.testclient import TestClient


@pytest.fixture
def test_client():
    """Cliente de prueba para FastAPI."""
    from src.main import app
    return TestClient(app)


@pytest.fixture
def sample_orders_data() -> List[Dict]:
    """Datos de órdenes de ejemplo para testing."""
    base_date = datetime.now() - timedelta(days=30)
    
    orders = []
    for i in range(100):
        order_date = base_date + timedelta(days=i % 30)
        orders.append({
            'id': f'order-{i}',
            'created_at': order_date.isoformat(),
            'item_id': f'item-{i % 10}',  # 10 items diferentes
            'quantity': (i % 5) + 1,
            'day_of_week': order_date.weekday(),
            'month': order_date.month,
            'is_weekend': 1 if order_date.weekday() >= 5 else 0
        })
    
    return orders


@pytest.fixture
def sample_menu_items() -> List[Dict]:
    """Items del menú de ejemplo."""
    return [
        {
            'id': 'item-1',
            'name': 'Pizza Margherita',
            'category': 'pizza',
            'price': 12.99
        },
        {
            'id': 'item-2',
            'name': 'Pasta Carbonara',
            'category': 'pasta',
            'price': 10.99
        },
        {
            'id': 'item-3',
            'name': 'Caesar Salad',
            'category': 'salad',
            'price': 8.99
        },
        {
            'id': 'item-4',
            'name': 'Hamburguesa Clásica',
            'category': 'burger',
            'price': 11.99
        },
        {
            'id': 'item-5',
            'name': 'Tacos al Pastor',
            'category': 'mexican',
            'price': 9.99
        }
    ]


@pytest.fixture
def sample_prediction_request() -> Dict:
    """Request de predicción de ejemplo."""
    return {
        'item_id': 'item-1',
        'item_name': 'Pizza Margherita',
        'date': datetime.now().isoformat()
    }


@pytest.fixture
def sample_batch_request() -> Dict:
    """Request de batch prediction de ejemplo."""
    return {
        'items': [
            {'item_id': 'item-1', 'item_name': 'Pizza Margherita'},
            {'item_id': 'item-2', 'item_name': 'Pasta Carbonara'},
            {'item_id': 'item-3', 'item_name': 'Caesar Salad'}
        ],
        'date': datetime.now().isoformat()
    }


@pytest.fixture
def mock_supabase_client(monkeypatch):
    """Mock del cliente Supabase para evitar llamadas reales."""
    class MockSupabaseClient:
        def __init__(self):
            self.table_data = {}
        
        def table(self, table_name: str):
            return MockTable(self.table_data.get(table_name, []))
    
    class MockTable:
        def __init__(self, data):
            self._data = data
        
        def select(self, *args):
            return self
        
        def gte(self, field, value):
            return self
        
        def order(self, field, **kwargs):
            return self
        
        def execute(self):
            class Response:
                def __init__(self, data):
                    self.data = data
            return Response(self._data)
    
    mock_client = MockSupabaseClient()
    
    def mock_get_client():
        return mock_client
    
    monkeypatch.setattr('src.config.database.get_supabase_client', mock_get_client)
    return mock_client

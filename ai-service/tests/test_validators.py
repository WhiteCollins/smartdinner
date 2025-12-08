"""
Tests para validadores y utilidades.

Verifica funciones de validación de datos.
"""

import pytest
from datetime import datetime, timedelta


class TestUUIDValidation:
    """Tests para validación de UUIDs."""
    
    def test_valid_uuid(self):
        """Test con UUID válido."""
        from src.utils.validators import is_valid_uuid
        
        valid_uuid = "123e4567-e89b-12d3-a456-426614174000"
        assert is_valid_uuid(valid_uuid) is True
    
    def test_invalid_uuid(self):
        """Test con UUID inválido."""
        from src.utils.validators import is_valid_uuid
        
        invalid_uuids = ["not-a-uuid", "123", "", "abc-def-ghi"]
        for invalid in invalid_uuids:
            assert is_valid_uuid(invalid) is False


class TestDateValidation:
    """Tests para validación de fechas."""
    
    def test_valid_date_range(self):
        """Test con rango de fechas válido."""
        from src.utils.validators import validate_date_range
        
        start = datetime.now()
        end = start + timedelta(days=10)
        
        start_dt, end_dt = validate_date_range(start, end)
        assert start_dt < end_dt
    
    def test_invalid_date_range(self):
        """Test con fechas invertidas."""
        from src.utils.validators import validate_date_range
        
        start = datetime.now()
        end = start - timedelta(days=10)
        
        with pytest.raises(ValueError, match="anterior a end_date"):
            validate_date_range(start, end)
    
    def test_max_days_validation(self):
        """Test con rango excedido."""
        from src.utils.validators import validate_date_range
        
        start = datetime.now()
        end = start + timedelta(days=100)
        
        with pytest.raises(ValueError, match="no puede exceder"):
            validate_date_range(start, end, max_days=30)


class TestConfidenceValidation:
    """Tests para validación de confianza."""
    
    def test_valid_confidence(self):
        """Test con valores válidos."""
        from src.utils.validators import validate_confidence
        
        valid_values = [0.0, 0.5, 0.85, 1.0]
        for val in valid_values:
            assert validate_confidence(val) == val
    
    def test_invalid_confidence(self):
        """Test con valores fuera de rango."""
        from src.utils.validators import validate_confidence
        
        invalid_values = [-0.1, 1.1, 2.0, -1.0]
        for val in invalid_values:
            with pytest.raises(ValueError, match="entre 0.0 y 1.0"):
                validate_confidence(val)


class TestDemandValidation:
    """Tests para validación de demanda."""
    
    def test_valid_demand(self):
        """Test con valores válidos."""
        from src.utils.validators import validate_demand_value
        
        assert validate_demand_value(10) == 10
        assert validate_demand_value(10.7) == 11  # Redondeo
        assert validate_demand_value(0) == 0
    
    def test_negative_demand(self):
        """Test con valores negativos."""
        from src.utils.validators import validate_demand_value
        
        with pytest.raises(ValueError, match="no puede ser negativo"):
            validate_demand_value(-5)


class TestItemNameSanitization:
    """Tests para sanitización de nombres."""
    
    def test_valid_name(self):
        """Test con nombre válido."""
        from src.utils.validators import sanitize_item_name
        
        name = "Pizza Margherita"
        assert sanitize_item_name(name) == name
    
    def test_dangerous_characters(self):
        """Test con caracteres peligrosos."""
        from src.utils.validators import sanitize_item_name
        
        dangerous = "Pizza<script>alert('xss')</script>"
        sanitized = sanitize_item_name(dangerous)
        assert "<script>" not in sanitized
        assert "Pizza" in sanitized
    
    def test_empty_name(self):
        """Test con nombre vacío."""
        from src.utils.validators import sanitize_item_name
        
        with pytest.raises(ValueError, match="no puede estar vacío"):
            sanitize_item_name("")
    
    def test_max_length(self):
        """Test con nombre muy largo."""
        from src.utils.validators import sanitize_item_name
        
        long_name = "A" * 200
        sanitized = sanitize_item_name(long_name, max_length=100)
        assert len(sanitized) <= 100


class TestDaysValidation:
    """Tests para validación de días de historia."""
    
    def test_valid_days(self):
        """Test con valores válidos."""
        from src.utils.validators import validate_days_of_history
        
        valid_days = [30, 90, 180, 365]
        for days in valid_days:
            assert validate_days_of_history(days) == days
    
    def test_invalid_days(self):
        """Test con valores fuera de rango."""
        from src.utils.validators import validate_days_of_history
        
        invalid_days = [10, 29, 366, 1000]
        for days in invalid_days:
            with pytest.raises(ValueError, match="entre 30 y 365"):
                validate_days_of_history(days)

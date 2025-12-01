"""
Validadores personalizados para datos de entrada.

Funciones auxiliares para validar UUIDs, fechas, rangos, etc.
"""

import re
from datetime import datetime, date
from typing import Union, Optional
from uuid import UUID


def is_valid_uuid(uuid_string: str) -> bool:
    """
    Valida si una cadena es un UUID válido.
    
    Args:
        uuid_string: Cadena a validar
        
    Returns:
        True si es UUID válido, False en caso contrario
    """
    try:
        UUID(uuid_string)
        return True
    except (ValueError, AttributeError):
        return False


def validate_date_range(
    start_date: Union[str, datetime, date],
    end_date: Union[str, datetime, date],
    max_days: Optional[int] = None
) -> tuple[datetime, datetime]:
    """
    Valida y convierte un rango de fechas.
    
    Args:
        start_date: Fecha de inicio
        end_date: Fecha de fin
        max_days: Máximo de días permitidos entre fechas
        
    Returns:
        Tupla con (start_datetime, end_datetime)
        
    Raises:
        ValueError: Si las fechas son inválidas
    """
    # Convertir a datetime
    if isinstance(start_date, str):
        start_dt = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
    elif isinstance(start_date, date):
        start_dt = datetime.combine(start_date, datetime.min.time())
    else:
        start_dt = start_date
    
    if isinstance(end_date, str):
        end_dt = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
    elif isinstance(end_date, date):
        end_dt = datetime.combine(end_date, datetime.max.time())
    else:
        end_dt = end_date
    
    # Validar orden
    if start_dt > end_dt:
        raise ValueError("start_date debe ser anterior a end_date")
    
    # Validar rango máximo
    if max_days:
        delta_days = (end_dt - start_dt).days
        if delta_days > max_days:
            raise ValueError(f"El rango no puede exceder {max_days} días")
    
    return start_dt, end_dt


def validate_confidence(confidence: float) -> float:
    """
    Valida que un valor de confianza esté en el rango válido.
    
    Args:
        confidence: Valor de confianza
        
    Returns:
        Confianza validada
        
    Raises:
        ValueError: Si está fuera del rango [0, 1]
    """
    if not 0.0 <= confidence <= 1.0:
        raise ValueError("Confidence debe estar entre 0.0 y 1.0")
    return confidence


def validate_demand_value(demand: Union[int, float]) -> int:
    """
    Valida y convierte un valor de demanda.
    
    Args:
        demand: Valor de demanda predicha
        
    Returns:
        Demanda como entero no negativo
        
    Raises:
        ValueError: Si es negativo
    """
    demand_int = int(round(demand))
    if demand_int < 0:
        raise ValueError("Demand no puede ser negativo")
    return demand_int


def sanitize_item_name(name: str, max_length: int = 100) -> str:
    """
    Limpia y valida el nombre de un item.
    
    Args:
        name: Nombre del item
        max_length: Longitud máxima permitida
        
    Returns:
        Nombre sanitizado
        
    Raises:
        ValueError: Si el nombre es inválido
    """
    if not name or not name.strip():
        raise ValueError("Item name no puede estar vacío")
    
    # Remover caracteres especiales peligrosos
    sanitized = re.sub(r'[<>\"\'%;()&+]', '', name.strip())
    
    if len(sanitized) > max_length:
        sanitized = sanitized[:max_length]
    
    if not sanitized:
        raise ValueError("Item name contiene solo caracteres inválidos")
    
    return sanitized


def validate_days_of_history(days: int) -> int:
    """
    Valida el parámetro de días de historia.
    
    Args:
        days: Número de días
        
    Returns:
        Días validado
        
    Raises:
        ValueError: Si está fuera del rango válido
    """
    if not 30 <= days <= 365:
        raise ValueError("days_of_history debe estar entre 30 y 365")
    return days

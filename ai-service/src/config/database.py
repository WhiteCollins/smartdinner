"""Cliente de Supabase para el servicio de IA"""
from supabase import create_client, Client
from .settings import get_settings
from functools import lru_cache
from typing import List, Dict, Optional
from datetime import datetime, timedelta

@lru_cache()
def get_supabase_client() -> Optional[Client]:
    """Obtiene cliente de Supabase (singleton)"""
    settings = get_settings()
    
    if not settings.supabase_url or not settings.supabase_service_key:
        print("⚠️ Credenciales de Supabase no configuradas")
        return None
    
    try:
        return create_client(settings.supabase_url, settings.supabase_service_key)
    except Exception as e:
        print(f"❌ Error al conectar con Supabase: {e}")
        return None

def get_historical_orders(days: int = 90) -> List[Dict]:
    """Obtiene órdenes históricas para entrenamiento"""
    client = get_supabase_client()
    
    if not client:
        return []
    
    try:
        # Calcular fecha límite
        date_limit = (datetime.now() - timedelta(days=days)).isoformat()
        
        response = client.table("orders") \
            .select("*, order_items(quantity, menu_item_id, menu_items(name, category))") \
            .gte("created_at", date_limit) \
            .order("created_at", desc=True) \
            .execute()
        
        return response.data if response.data else []
    except Exception as e:
        print(f"❌ Error al obtener órdenes históricas: {e}")
        return []

def get_menu_items() -> List[Dict]:
    """Obtiene todos los items del menú"""
    client = get_supabase_client()
    
    if not client:
        return []
    
    try:
        response = client.table("menu_items") \
            .select("*") \
            .eq("is_available", True) \
            .execute()
        
        return response.data if response.data else []
    except Exception as e:
        print(f"❌ Error al obtener items del menú: {e}")
        return []

def get_inventory_usage(days: int = 90) -> List[Dict]:
    """Obtiene histórico de uso de inventario"""
    client = get_supabase_client()
    
    if not client:
        return []
    
    try:
        date_limit = (datetime.now() - timedelta(days=days)).isoformat()
        
        response = client.table("inventory_usage") \
            .select("*") \
            .gte("date", date_limit) \
            .order("date", desc=True) \
            .execute()
        
        return response.data if response.data else []
    except Exception as e:
        print(f"⚠️ Tabla inventory_usage no existe o error: {e}")
        return []

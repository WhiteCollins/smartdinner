"""
Script para ejecutar el servicio de IA.

Útil para desarrollo y producción.
"""

import sys
import os
from pathlib import Path

# Agregar src al path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

import uvicorn
from src.config.settings import get_settings


def main():
    """Punto de entrada principal."""
    settings = get_settings()
    
    print(f"🚀 Iniciando {settings.app_name} v{settings.version}")
    print(f"🌐 Entorno: {settings.environment}")
    print(f"📍 Puerto: {settings.port}")
    print("-" * 50)
    
    # Configuración de uvicorn
    uvicorn_config = {
        "app": "src.main:app",
        "host": "0.0.0.0",
        "port": settings.port,
        "log_level": settings.log_level.lower(),
    }
    
    # En desarrollo, activar reload
    if settings.environment == "development":
        uvicorn_config["reload"] = True
        print("🔄 Hot reload activado")
    
    print(f"\n📖 Documentación: http://localhost:{settings.port}/docs")
    print(f"🏥 Health check: http://localhost:{settings.port}/health\n")
    
    # Iniciar servidor
    uvicorn.run(**uvicorn_config)


if __name__ == "__main__":
    main()

"""
Script para validar la instalación y configuración.

Verifica que todo esté correctamente configurado.
"""

import sys
from pathlib import Path

# Agregar src al path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))


def check_imports():
    """Verifica que todas las dependencias estén instaladas."""
    print("📦 Verificando dependencias...")
    
    required_packages = [
        ('fastapi', 'FastAPI'),
        ('uvicorn', 'Uvicorn'),
        ('pydantic', 'Pydantic'),
        ('sklearn', 'scikit-learn'),
        ('pandas', 'Pandas'),
        ('numpy', 'NumPy'),
        ('supabase', 'Supabase'),
    ]
    
    missing = []
    for module, name in required_packages:
        try:
            __import__(module)
            print(f"  ✅ {name}")
        except ImportError:
            print(f"  ❌ {name} - NO INSTALADO")
            missing.append(name)
    
    if missing:
        print(f"\n❌ Faltan paquetes: {', '.join(missing)}")
        print("💡 Instala con: pip install -r requirements.txt")
        return False
    
    print("✅ Todas las dependencias instaladas\n")
    return True


def check_config():
    """Verifica la configuración."""
    print("⚙️ Verificando configuración...")
    
    try:
        from src.config.settings import get_settings
        settings = get_settings()
        
        print(f"  ✅ App: {settings.app_name}")
        print(f"  ✅ Version: {settings.version}")
        print(f"  ✅ Environment: {settings.environment}")
        
        # Verificar variables críticas
        if not settings.supabase_url:
            print("  ⚠️ SUPABASE_URL no configurado")
            return False
        
        if not settings.supabase_service_key:
            print("  ⚠️ SUPABASE_SERVICE_KEY no configurado")
            return False
        
        print("  ✅ Supabase configurado")
        print("✅ Configuración válida\n")
        return True
        
    except Exception as e:
        print(f"  ❌ Error: {e}")
        print("💡 Crea un archivo .env con las variables necesarias")
        return False


def check_directories():
    """Verifica que existan los directorios necesarios."""
    print("📁 Verificando estructura de directorios...")
    
    base_path = Path(__file__).parent.parent
    required_dirs = [
        'src',
        'src/config',
        'src/models',
        'src/services',
        'src/utils',
        'scripts',
        'tests',
    ]
    
    all_exist = True
    for dir_name in required_dirs:
        dir_path = base_path / dir_name
        if dir_path.exists():
            print(f"  ✅ {dir_name}/")
        else:
            print(f"  ❌ {dir_name}/ - NO EXISTE")
            all_exist = False
    
    # Crear directorios opcionales si no existen
    optional_dirs = ['models', 'data', 'logs']
    for dir_name in optional_dirs:
        dir_path = base_path / dir_name
        if not dir_path.exists():
            dir_path.mkdir(parents=True, exist_ok=True)
            print(f"  ✨ {dir_name}/ - CREADO")
        else:
            print(f"  ✅ {dir_name}/")
    
    if all_exist:
        print("✅ Estructura de directorios correcta\n")
    else:
        print("❌ Faltan algunos directorios\n")
    
    return all_exist


def check_database_connection():
    """Verifica conexión a Supabase."""
    print("🔌 Verificando conexión a Supabase...")
    
    try:
        from src.config.database import get_supabase_client
        
        client = get_supabase_client()
        
        # Intentar una consulta simple
        result = client.table('menu_items').select('id').limit(1).execute()
        
        print("  ✅ Conexión exitosa")
        print("✅ Base de datos accesible\n")
        return True
        
    except Exception as e:
        print(f"  ❌ Error de conexión: {e}")
        print("💡 Verifica las credenciales de Supabase en .env")
        return False


def check_model():
    """Verifica si existe un modelo entrenado."""
    print("🤖 Verificando modelo de ML...")
    
    try:
        from src.services.prediction_service import DemandPredictionService
        
        service = DemandPredictionService()
        info = service.get_model_info()
        
        if info['model_loaded']:
            metadata = info.get('metadata', {})
            print(f"  ✅ Modelo cargado: {info['model_path']}")
            print(f"  📅 Entrenado: {metadata.get('trained_at', 'N/A')}")
            print(f"  📈 Muestras: {metadata.get('samples', 'N/A')}")
            print(f"  🎯 MAE: {metadata.get('mae', 'N/A')}")
            print(f"  📊 R²: {metadata.get('r2', 'N/A')}")
            print("✅ Modelo listo para predicciones\n")
            return True
        else:
            print("  ⚠️ No hay modelo entrenado")
            print("💡 Entrena el modelo con: python scripts/train.py")
            print("❌ Modelo no disponible\n")
            return False
            
    except Exception as e:
        print(f"  ❌ Error: {e}\n")
        return False


def main():
    """Ejecuta todas las verificaciones."""
    print("=" * 60)
    print("🔍 SmartDinner AI Service - Validación de Instalación")
    print("=" * 60)
    print()
    
    results = {
        'Dependencias': check_imports(),
        'Configuración': check_config(),
        'Directorios': check_directories(),
        'Base de datos': check_database_connection(),
        'Modelo ML': check_model(),
    }
    
    print("=" * 60)
    print("📊 RESUMEN")
    print("=" * 60)
    
    for check, passed in results.items():
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{check:.<40} {status}")
    
    print()
    
    all_passed = all(results.values())
    
    if all_passed:
        print("🎉 ¡Todo configurado correctamente!")
        print("\n🚀 Siguiente paso:")
        print("   python scripts/run.py")
    else:
        print("⚠️ Hay problemas que resolver")
        print("\n💡 Pasos sugeridos:")
        
        if not results['Dependencias']:
            print("   1. pip install -r requirements.txt")
        
        if not results['Configuración']:
            print("   2. cp env.example .env")
            print("   3. Editar .env con tus credenciales")
        
        if not results['Base de datos']:
            print("   4. Verificar credenciales de Supabase")
        
        if not results['Modelo ML']:
            print("   5. python scripts/train.py --days 90")
    
    print()
    
    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())

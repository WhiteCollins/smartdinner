"""
Script de entrenamiento manual para el modelo de predicción de demanda.

Uso:
    python scripts/train.py --days 90
    python scripts/train.py --days 180 --force
"""

import sys
import os
from pathlib import Path
import argparse
from datetime import datetime

# Agregar el directorio src al path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from src.services.prediction_service import DemandPredictionService
from src.config.settings import get_settings


def main():
    parser = argparse.ArgumentParser(
        description='Entrena el modelo de predicción de demanda de SmartDinner'
    )
    parser.add_argument(
        '--days',
        type=int,
        default=90,
        help='Número de días de historia a usar (30-365). Default: 90'
    )
    parser.add_argument(
        '--force',
        action='store_true',
        help='Forzar re-entrenamiento aunque ya exista un modelo'
    )
    parser.add_argument(
        '--info',
        action='store_true',
        help='Mostrar información del modelo actual sin entrenar'
    )
    
    args = parser.parse_args()
    
    settings = get_settings()
    print(f"🤖 {settings.app_name} v{settings.version}")
    print(f"📊 Servicio de entrenamiento de modelos ML\n")
    
    # Crear instancia del servicio
    service = DemandPredictionService()
    
    # Modo info
    if args.info:
        print("📋 Información del modelo actual:")
        print("-" * 50)
        info = service.get_model_info()
        
        if info['model_loaded']:
            metadata = info.get('metadata', {})
            print(f"✅ Modelo cargado: {info['model_path']}")
            print(f"📅 Entrenado: {metadata.get('trained_at', 'Desconocido')}")
            print(f"📈 Muestras: {metadata.get('samples', 'N/A')}")
            print(f"🎯 MAE: {metadata.get('mae', 'N/A'):.2f}" if metadata.get('mae') else "🎯 MAE: N/A")
            print(f"📊 R²: {metadata.get('r2', 'N/A'):.4f}" if metadata.get('r2') else "📊 R²: N/A")
            print(f"🔧 Features: {', '.join(info.get('feature_columns', []))}")
        else:
            print("❌ No hay modelo entrenado")
            print(f"📂 Ruta esperada: {info['model_path']}")
        
        return
    
    # Validar días
    if not 30 <= args.days <= 365:
        print("❌ Error: El número de días debe estar entre 30 y 365")
        return
    
    # Verificar modelo existente
    if not args.force:
        info = service.get_model_info()
        if info['model_loaded']:
            print("⚠️  Ya existe un modelo entrenado.")
            print("💡 Usa --force para re-entrenar o --info para ver detalles")
            return
    
    # Entrenar modelo
    print(f"🚀 Iniciando entrenamiento con {args.days} días de historia...")
    print("-" * 50)
    
    try:
        start_time = datetime.now()
        
        result = service.train_model(days_of_history=args.days)
        
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        
        print("\n✅ Entrenamiento completado exitosamente!")
        print("-" * 50)
        print(f"⏱️  Duración: {duration:.2f} segundos")
        print(f"📈 Muestras entrenadas: {result['samples']}")
        print(f"🎯 Error Absoluto Medio (MAE): {result['mae']:.2f} unidades")
        print(f"📊 Coeficiente de determinación (R²): {result['r2']:.4f}")
        print(f"📅 Fecha de entrenamiento: {result['trained_at']}")
        print(f"💾 Modelo guardado en: {result['model_path']}")
        
        # Interpretación de métricas
        print("\n📋 Interpretación:")
        if result['r2'] >= 0.7:
            print("   ✨ Excelente precisión - El modelo captura bien los patrones")
        elif result['r2'] >= 0.5:
            print("   👍 Buena precisión - El modelo es útil para predicciones")
        elif result['r2'] >= 0.3:
            print("   ⚠️  Precisión moderada - Considerar más datos o features")
        else:
            print("   ❌ Baja precisión - Se necesita mejorar el modelo")
        
        print(f"\n💡 El modelo predice con un error promedio de ±{result['mae']:.0f} unidades")
        
    except ValueError as e:
        print(f"\n❌ Error de validación: {e}")
        print("💡 Verifica que haya suficientes datos históricos en la base de datos")
    except Exception as e:
        print(f"\n❌ Error durante el entrenamiento: {e}")
        print("💡 Revisa los logs y la configuración de Supabase")


if __name__ == "__main__":
    main()

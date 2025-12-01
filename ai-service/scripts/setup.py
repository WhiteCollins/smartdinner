#!/usr/bin/env python
"""
Script de inicio rápido interactivo.

Guía paso a paso para configurar el servicio de IA.
"""

import sys
import os
from pathlib import Path
import subprocess
import time

# Colores para terminal
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


def print_header(text):
    """Imprime encabezado."""
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'=' * 60}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text:^60}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'=' * 60}{Colors.ENDC}\n")


def print_step(step, text):
    """Imprime paso."""
    print(f"{Colors.CYAN}{Colors.BOLD}[Paso {step}]{Colors.ENDC} {text}")


def print_success(text):
    """Imprime éxito."""
    print(f"{Colors.GREEN}✅ {text}{Colors.ENDC}")


def print_error(text):
    """Imprime error."""
    print(f"{Colors.FAIL}❌ {text}{Colors.ENDC}")


def print_warning(text):
    """Imprime advertencia."""
    print(f"{Colors.WARNING}⚠️  {text}{Colors.ENDC}")


def print_info(text):
    """Imprime información."""
    print(f"{Colors.BLUE}ℹ️  {text}{Colors.ENDC}")


def ask_yes_no(question, default=True):
    """Pregunta sí/no."""
    suffix = "[S/n]" if default else "[s/N]"
    response = input(f"{question} {suffix}: ").strip().lower()
    
    if not response:
        return default
    
    return response in ['s', 'si', 'y', 'yes', 'sí']


def check_python_version():
    """Verifica versión de Python."""
    print_step(1, "Verificando versión de Python...")
    
    version = sys.version_info
    if version.major >= 3 and version.minor >= 9:
        print_success(f"Python {version.major}.{version.minor}.{version.micro}")
        return True
    else:
        print_error(f"Python {version.major}.{version.minor} no es compatible")
        print_info("Se requiere Python 3.9 o superior")
        return False


def install_dependencies():
    """Instala dependencias."""
    print_step(2, "Instalando dependencias...")
    
    if not ask_yes_no("¿Instalar dependencias de requirements.txt?"):
        print_warning("Saltando instalación de dependencias")
        return True
    
    try:
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], check=True)
        print_success("Dependencias instaladas")
        return True
    except subprocess.CalledProcessError:
        print_error("Error instalando dependencias")
        return False


def setup_environment():
    """Configura variables de entorno."""
    print_step(3, "Configurando variables de entorno...")
    
    env_path = Path(".env")
    env_example = Path("env.example")
    
    if env_path.exists():
        print_warning(".env ya existe")
        if not ask_yes_no("¿Sobrescribir?", default=False):
            print_info("Usando .env existente")
            return True
    
    if not env_example.exists():
        print_error("env.example no encontrado")
        return False
    
    # Copiar template
    with open(env_example) as f:
        template = f.read()
    
    print_info("Ingresa tus credenciales de Supabase:")
    
    # Pedir URL
    supabase_url = input("  SUPABASE_URL: ").strip()
    if not supabase_url:
        print_error("URL requerida")
        return False
    
    # Pedir service key
    supabase_key = input("  SUPABASE_SERVICE_KEY: ").strip()
    if not supabase_key:
        print_error("Service key requerida")
        return False
    
    # Actualizar template
    template = template.replace("https://tu-proyecto.supabase.co", supabase_url)
    template = template.replace("tu_service_role_key_aqui", supabase_key)
    
    # Guardar
    with open(env_path, 'w') as f:
        f.write(template)
    
    print_success("Archivo .env creado")
    return True


def validate_installation():
    """Valida la instalación."""
    print_step(4, "Validando instalación...")
    
    try:
        result = subprocess.run([sys.executable, "scripts/validate_setup.py"], capture_output=True, text=True)
        print(result.stdout)
        
        if result.returncode == 0:
            print_success("Validación exitosa")
            return True
        else:
            print_warning("Validación con advertencias")
            return ask_yes_no("¿Continuar de todos modos?", default=False)
    except Exception as e:
        print_error(f"Error en validación: {e}")
        return False


def train_model():
    """Entrena el modelo."""
    print_step(5, "Entrenando modelo de ML...")
    
    if not ask_yes_no("¿Entrenar modelo ahora? (puede tomar unos minutos)"):
        print_warning("Saltando entrenamiento")
        print_info("Puedes entrenar después con: python scripts/train.py")
        return True
    
    days = input("  ¿Cuántos días de historia usar? [90]: ").strip()
    days = days if days else "90"
    
    try:
        print_info("Entrenando... (esto puede tomar unos minutos)")
        result = subprocess.run(
            [sys.executable, "scripts/train.py", "--days", days],
            check=True
        )
        print_success("Modelo entrenado")
        return True
    except subprocess.CalledProcessError:
        print_error("Error entrenando modelo")
        print_info("Puedes intentar de nuevo con: python scripts/train.py")
        return False


def start_service():
    """Inicia el servicio."""
    print_step(6, "Iniciando servicio...")
    
    if not ask_yes_no("¿Iniciar el servicio ahora?"):
        print_info("Puedes iniciarlo después con: python scripts/run.py")
        return True
    
    print_success("Iniciando servidor...")
    print_info("Documentación: http://localhost:8000/docs")
    print_info("Presiona Ctrl+C para detener\n")
    
    try:
        subprocess.run([sys.executable, "scripts/run.py"])
        return True
    except KeyboardInterrupt:
        print_warning("\n\nServicio detenido")
        return True
    except Exception as e:
        print_error(f"Error iniciando servicio: {e}")
        return False


def main():
    """Ejecuta el setup interactivo."""
    print_header("SmartDinner AI Service - Setup Interactivo")
    
    print("Este script te guiará para configurar el servicio de IA.\n")
    
    # Verificar que estamos en el directorio correcto
    if not Path("requirements.txt").exists():
        print_error("No se encontró requirements.txt")
        print_info("Asegúrate de ejecutar este script desde ai-service/")
        return 1
    
    steps = [
        ("Verificar Python", check_python_version),
        ("Instalar dependencias", install_dependencies),
        ("Configurar entorno", setup_environment),
        ("Validar instalación", validate_installation),
        ("Entrenar modelo", train_model),
        ("Iniciar servicio", start_service),
    ]
    
    for i, (name, func) in enumerate(steps, 1):
        try:
            if not func():
                print_error(f"Falló: {name}")
                if not ask_yes_no("¿Continuar?", default=False):
                    print_warning("Setup cancelado")
                    return 1
        except KeyboardInterrupt:
            print_warning("\n\nSetup interrumpido")
            return 1
        except Exception as e:
            print_error(f"Error inesperado en {name}: {e}")
            if not ask_yes_no("¿Continuar?", default=False):
                return 1
        
        if i < len(steps):
            time.sleep(0.5)
    
    print_header("¡Setup Completado!")
    print_success("El servicio de IA está listo para usar")
    print_info("\nComandos útiles:")
    print("  • Iniciar servicio: python scripts/run.py")
    print("  • Entrenar modelo: python scripts/train.py")
    print("  • Validar setup: python scripts/validate_setup.py")
    print("  • Ejecutar tests: pytest")
    print("\n💡 Consulta QUICKSTART.md para más información\n")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())

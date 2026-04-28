#!/usr/bin/env python3
"""
Script para verificar la conexión a la instancia RDS PostgreSQL
"""

import psycopg2
import sys
import time
import argparse
from getpass import getpass

def test_rds_connection(host, username, password, database, port=5432, max_retries=5, retry_interval=30):
    """
    Prueba la conexión a la base de datos RDS con reintentos
    """
    print(f"Intentando conectar a RDS en {host}:{port}...")
    print(f"Base de datos: {database}")
    print(f"Usuario: {username}")
    print("-" * 50)
    
    for attempt in range(1, max_retries + 1):
        try:
            print(f"Intento {attempt}/{max_retries}...")
            
            # Intentar conexión
            connection = psycopg2.connect(
                host=host,
                user=username,
                password=password,
                database=database,
                port=port,
                connect_timeout=10
            )
            
            print("✅ Conexión exitosa a RDS PostgreSQL!")
            
            # Ejecutar una consulta simple para verificar
            with connection.cursor() as cursor:
                cursor.execute("SELECT version()")
                version = cursor.fetchone()
                print(f"Versión de PostgreSQL: {version[0]}")
                
                cursor.execute("SELECT current_database()")
                db_name = cursor.fetchone()
                print(f"Base de datos actual: {db_name[0]}")
                
                cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
                tables = cursor.fetchall()
                print(f"Tablas en la base de datos: {len(tables)}")
                if tables:
                    for table in tables:
                        print(f"  - {table[0]}")
            
            connection.close()
            print("\n✅ Prueba de conexión completada exitosamente!")
            return True
            
        except psycopg2.Error as e:
            print(f"❌ Error en el intento {attempt}: {e}")
            
            if attempt < max_retries:
                print(f"Esperando {retry_interval} segundos antes del próximo intento...")
                time.sleep(retry_interval)
            else:
                print("\n❌ No se pudo establecer conexión después de todos los intentos")
                print("Posibles causas:")
                print("  - La instancia RDS aún no está completamente disponible")
                print("  - El security group no permite conexiones desde tu IP")
                print("  - Credenciales incorrectas")
                print("  - La instancia no es públicamente accesible")
                return False

def main():
    parser = argparse.ArgumentParser(description='Prueba de conexión a AWS RDS PostgreSQL')
    parser.add_argument('--host', help='Endpoint de RDS')
    parser.add_argument('--username', default='admin', help='Usuario de la base de datos (default: admin)')
    parser.add_argument('--password', help='Contraseña de la base de datos')
    parser.add_argument('--database', default='testdb', help='Nombre de la base de datos (default: testdb)')
    parser.add_argument('--port', type=int, default=5432, help='Puerto (default: 5432)')
    parser.add_argument('--max-retries', type=int, default=5, help='Máximo de reintentos (default: 5)')
    parser.add_argument('--retry-interval', type=int, default=30, help='Intervalo entre reintentos en segundos (default: 30)')
    
    args = parser.parse_args()
    
    # Si no se proporcionan argumentos, usar modo interactivo
    if not args.host:
        print("=" * 50)
        print("Prueba de Conexión a AWS RDS PostgreSQL")
        print("=" * 50)
        
        args.host = input("Endpoint de RDS (ej: mysql-instance.xxxx.us-west-1.rds.amazonaws.com): ").strip()
        if not args.host:
            print("Error: El endpoint es requerido")
            sys.exit(1)
        
        args.username = input("Usuario (default: admin): ").strip() or "admin"
        args.password = getpass("Contraseña: ").strip()
        args.database = input("Nombre de la base de datos (default: testdb): ").strip() or "testdb"
        port_input = input("Puerto (default: 5432): ").strip()
        if port_input:
            try:
                args.port = int(port_input)
            except ValueError:
                print("Error: El puerto debe ser un número")
                sys.exit(1)
    else:
        # Modo no interactivo (GitHub Actions)
        if not args.password:
            args.password = sys.stdin.readline().strip()
    
    if not args.password:
        print("Error: La contraseña es requerida")
        sys.exit(1)
    
    # Ejecutar prueba de conexión
    success = test_rds_connection(
        args.host, 
        args.username, 
        args.password, 
        args.database, 
        args.port,
        args.max_retries,
        args.retry_interval
    )
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()

import psycopg2
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
import os

load_dotenv() # Uso de load_dotenv para cargar las variables de entorno desde el archivo .env

DB_NAME = os.getenv("DB_NAME") 
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

# Crear la base de datos si no existe
try:
    conn = psycopg2.connect( # Conexión a la base de datos
        dbname="postgres",
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT
    )
    conn.autocommit = True # Cada instrucción de SQL se ejecuta de inmediato
    cur = conn.cursor() # Intermediario entre python y la base de datos

    cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{DB_NAME}'")
    exists = cur.fetchone()
    if not exists:
        cur.execute(f"CREATE DATABASE {DB_NAME}")
        print(f"Base de datos '{DB_NAME}' creada.")
    else:
        print(f"ℹLa base de datos '{DB_NAME}' ya existe.")

    cur.close() # Desconexión
    conn.close()

except Exception as e:
    print(f"Error creando la base de datos: {e}")
    exit()

# Conectar y poblar datos
try:
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT
    )
    cur = conn.cursor()

    with open("create_tables.sql", "r") as sql_file:
        cur.execute(sql_file.read())
    conn.commit()
    print("Tablas creadas desde 'create_tables.sql'.")
    # Poblar datos
    df = pd.read_csv("supermarket_sales.csv")

    # Sucursales
    branch_map = {}
    for _, row in df[['Branch', 'City']].drop_duplicates().iterrows():
        cur.execute("INSERT INTO sucursal (tipo, ciudad) VALUES (%s, %s) RETURNING ID_sucursal;", (row['Branch'], row['City']))
        branch_map[row['Branch']] = cur.fetchone()[0]

    # Clientes
    customer_map = {}
    for _, row in df[['Customer type', 'Gender']].drop_duplicates().iterrows():
        cur.execute("INSERT INTO cliente (tipo_cliente, genero) VALUES (%s, %s) RETURNING ID_cliente;", (row['Customer type'], row['Gender']))
        customer_map[(row['Customer type'], row['Gender'])] = cur.fetchone()[0]
    # Productos
    product_map = {}
    for _,row in df[['Product line']].drop_duplicates().iterrows():
        cur.execute("INSERT INTO producto (linea_producto) VALUES (%s) RETURNING ID_producto;", (row['Product line'],))
        product_map[(row['Product line'])] = cur.fetchone()[0]



    # Boletas y Ventas
    boleta_map = {}
    for _, row in df.iterrows():
        if row['Invoice ID'] not in boleta_map:
            id_cliente = customer_map[(row['Customer type'], row['Gender'])]
            id_sucursal = branch_map[row['Branch']]
            fecha = datetime.strptime(row['Date'], "%m/%d/%Y").date()
            hora = datetime.strptime(row['Time'], "%H:%M").time()

            cur.execute("""
                INSERT INTO boleta (ID_boleta, ID_cliente, ID_sucursal, fecha, hora, tipo_pago, calificacion)
                VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING ID_boleta;
            """, (row['Invoice ID'], id_cliente, id_sucursal, fecha, hora, row['Payment'], row['Rating']))
            boleta_map[row['Invoice ID']] = cur.fetchone()[0]

        id_boleta = boleta_map[row['Invoice ID']]
        id_producto = product_map[row['Product line']]
        cur.execute("""
            INSERT INTO venta (ID_boleta, ID_producto, precio_unitario ,cantidad, total, impuesto)
            VALUES (%s, %s, %s, %s, %s, %s);
        """, (id_boleta, id_producto, row["Unit price"] , row['Quantity'], row['Total'], row['Tax 5%']))

    conn.commit()
    print("Datos insertados con éxito.")

except Exception as e:
    print(f"Error en la ejecución general: {e}")

finally:
    if 'cur' in locals():
        cur.close()
    if 'conn' in locals():
        conn.close()


from flask import Flask, render_template, request, redirect, url_for, session, jsonify, send_from_directory, send_file, flash
from flask_cors import CORS
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash 
import mysql.connector
import os
from db import get_connection

SECRET_KEY = "miclavesecreta"

app = Flask(__name__, static_folder="static", template_folder="template")
CORS(app)
app.secret_key = SECRET_KEY

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# TEST DE CONEXIÓN A LA BASE DE DATOS
#-------------------------------------------------------------------------------

@app.route("/test-db")
def test_db():
    conn = get_connection()
    if conn and conn.is_connected():
        return "✅ Conexión a la base de datos exitosa"
    else:
        return "❌ Falló la conexión a la base de datos"

@app.route('/', methods=['GET'])
def registro():
    return render_template('index.html')

# PRODUCTOS (CRUD)
@app.route('/productos', methods=['GET'])
def inicio():
    conn = get_connection()
    productos = []
    total_productos = 0

    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    per_page_options = [5, 10, 15]

    offset = (page - 1) * per_page

    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT COUNT(id_producto) AS total FROM producto")
            total_productos = cursor.fetchone()['total']

            cursor.execute(f"""
                SELECT
                    p.id_producto,
                    p.nombre_producto,
                    p.descripcion,
                    c.nombre_categoria,
                    SUM(COALESCE(pv.stock, 0)) AS stock_total,
                    MIN(pv.precio) AS precio_minimo,
                    p.disponible
                FROM
                    producto p
                LEFT JOIN
                    categoria c ON p.id_categoria = c.id_categoria
                LEFT JOIN
                    producto_variante pv ON p.id_producto = pv.id_producto
                GROUP BY
                    p.id_producto, p.nombre_producto, p.descripcion, c.nombre_categoria, p.disponible
                ORDER BY
                    p.nombre_producto
                LIMIT %s OFFSET %s;
            """, (per_page, offset))
            productos = cursor.fetchall()

        except mysql.connector.Error as err:
            print(f"Error al obtener productos: {err}")
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()

    total_pages = (total_productos + per_page - 1) // per_page

    return render_template('productos.html',
                           productos=productos,
                           page=page,
                           per_page=per_page,
                           total_pages=total_pages,
                           per_page_options=per_page_options)

@app.route('/productos/crear', methods=['GET'])
def crear_producto_form():
    conn = get_connection()
    categorias = []
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT id_categoria, nombre_categoria FROM categoria ORDER BY nombre_categoria")
            categorias = cursor.fetchall()
        except mysql.connector.Error as err:
            print(f"Error al obtener categorías: {err}")
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()
    return render_template('form_productos.html', categorias=categorias, product=None, is_editing=False)

@app.route('/productos/crear', methods=['POST'])
def crear_producto():
    nombre = request.form.get('nombre_producto')
    descripcion = request.form.get('descripcion')
    id_categoria = request.form.get('id_categoria')
    disponible = 'disponible' in request.form

    conn = get_connection()
    if conn:
        cursor = None
        try:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO producto (nombre_producto, descripcion, id_categoria, disponible)
                VALUES (%s, %s, %s, %s)
            """, (nombre, descripcion, id_categoria, disponible))
            conn.commit()
            flash('Producto creado exitosamente!', 'success')
            return redirect(url_for('inicio'))
        except mysql.connector.Error as err:
            conn.rollback()
            flash(f'Error al crear producto: {err}', 'error')
            print(f"Error al crear producto: {err}")
            return "Error al crear producto", 500
        finally:
            if cursor:
                cursor.close()
            if conn.is_connected():
                conn.close()
    flash('Error de conexión a la base de datos al crear producto.', 'error')
    return "Error de conexión a la base de datos", 500

@app.route('/productos/editar/<int:id_producto>', methods=['GET'])
def editar_producto_form(id_producto):
    conn = get_connection()
    product = None
    categorias = []
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
                SELECT
                    p.id_producto,
                    p.nombre_producto,
                    p.descripcion,
                    p.id_categoria,
                    p.disponible,
                    c.nombre_categoria
                FROM
                    producto p
                LEFT JOIN
                    categoria c ON p.id_categoria = c.id_categoria
                WHERE
                    p.id_producto = %s;
            """, (id_producto,))
            product = cursor.fetchone()

            cursor.execute("SELECT id_categoria, nombre_categoria FROM categoria ORDER BY nombre_categoria")
            categorias = cursor.fetchall()

        except mysql.connector.Error as err:
            print(f"Error al obtener producto para edición: {err}")
            flash(f'Error al cargar datos del producto para edición: {err}', 'error')
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()

    if product:
        return render_template('form_productos.html', product=product, categorias=categorias, is_editing=True)
    else:
        flash('Producto no encontrado.', 'error')
        return redirect(url_for('inicio'))

@app.route('/productos/actualizar/<int:id_producto>', methods=['POST'])
def actualizar_producto(id_producto):
    nombre = request.form.get('nombre_producto')
    descripcion = request.form.get('descripcion')
    id_categoria = request.form.get('id_categoria')
    disponible = 'disponible' in request.form

    conn = get_connection()
    if conn:
        cursor = None
        try:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE producto
                SET nombre_producto = %s,
                    descripcion = %s,
                    id_categoria = %s,
                    disponible = %s,
                    actualizado_en = CURRENT_TIMESTAMP
                WHERE id_producto = %s;
            """, (nombre, descripcion, id_categoria, disponible, id_producto))
            conn.commit()
            flash('Producto actualizado exitosamente!', 'success')
            return redirect(url_for('inicio'))
        except mysql.connector.Error as err:
            conn.rollback()
            flash(f'Error al actualizar producto: {err}', 'error')
            print(f"Error al actualizar producto: {err}")
            return "Error al actualizar producto", 500
        finally:
            if cursor:
                cursor.close()
            if conn.is_connected():
                conn.close()
    flash('Error de conexión a la base de datos al actualizar producto.', 'error')
    return "Error de conexión a la base de datos", 500

@app.route('/productos/eliminar/<int:id_producto>', methods=['POST'])
def eliminar_producto(id_producto):
    conn = get_connection()
    if conn:
        cursor = None
        try:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM item_pedido WHERE id_variante IN (SELECT id_variante FROM producto_variante WHERE id_producto = %s);", (id_producto,))
            conn.commit()
            cursor.execute("DELETE FROM item_carrito WHERE id_variante IN (SELECT id_variante FROM producto_variante WHERE id_producto = %s);", (id_producto,))
            conn.commit()
            cursor.execute("DELETE FROM producto_variante WHERE id_producto = %s;", (id_producto,))
            conn.commit()
            cursor.execute("DELETE FROM producto WHERE id_producto = %s;", (id_producto,))
            conn.commit()
            flash('Producto eliminado exitosamente!', 'success')
            return redirect(url_for('inicio'))
        except mysql.connector.Error as err:
            conn.rollback()
            flash(f'Error al eliminar producto: {err}', 'error')
            print(f"Error al eliminar producto: {err}")
            return "Error al eliminar producto", 500
        finally:
            if cursor:
                cursor.close()
            if conn.is_connected():
                conn.close()
    flash('Error de conexión a la base de datos al eliminar producto.', 'error')
    return "Error de conexión a la base de datos", 500

@app.route('/', methods=['GET'])
def index():
    return redirect(url_for('inicio'))

# LOGIN Y DASHBOARD
#-------------------------------------------------------------------------------
@app.route('/login', methods=['GET'])
def login():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def handle_login():
    email = request.form.get('email')
    password = request.form.get('password')

    conn = get_connection()
    user = None
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT id_usuario, email, contrasena FROM usuario WHERE email = %s", (email,))
            user = cursor.fetchone()
        except mysql.connector.Error as err:
            print(f"Error al buscar usuario: {err}")
            flash('Error en el servidor. Inténtalo de nuevo más tarde.', 'error')
            return redirect(url_for('login'))
        finally:
            if conn and conn.is_connected():
                cursor.close()
                conn.close()

    if user and user['contrasena'] == password: 
        session['logged_in'] = True
        session['user_id'] = user['id_usuario']
        session['user_email'] = user['email'] 
        flash('¡Has iniciado sesión correctamente!', 'success')
        return redirect(url_for('dashboard'))
    else:
        flash('Correo electrónico o contraseña incorrectos.', 'error')
        return redirect(url_for('login'))


@app.route('/dashboard')
def dashboard():
    if 'logged_in' in session and session['logged_in']:
        return render_template('dashboard.html')
    else:
        flash('Necesitas iniciar sesión para acceder a esta página.', 'error')
        return redirect(url_for('login'))

@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    session.pop('user_id', None)
    session.pop('user_email', None)
    flash('Has cerrado sesión.', 'success')
    return redirect(url_for('inicio')) 

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"message": "No se encontró el archivo"}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({"message": "No se seleccionó ningún archivo"}), 400
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        flash('Archivo subido exitosamente!', 'success')
        return jsonify({"message": "Archivo subido exitosamente", "filename": filename}), 200
    flash('Tipo de archivo no permitido.', 'error')
    return jsonify({"message": "Tipo de archivo no permitido"}), 400


if __name__ == "__main__":
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
    app.run(debug=True, host="0.0.0.0", port=5000)
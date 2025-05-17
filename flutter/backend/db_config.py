from flask_mysqldb import MySQL

mysql = MySQL()

def init_mysql(app):
    app.config['MYSQL_HOST'] = 'localhost'
    app.config['MYSQL_USER'] = 'teja'
    app.config['MYSQL_PASSWORD'] = 'Vagdeviteja@9'
    app.config['MYSQL_DB'] = 'ac'

    
    mysql.init_app(app)

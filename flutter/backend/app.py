from flask import Flask, request, jsonify, session
from db_config import mysql, init_mysql
from flask_cors import CORS

app = Flask(__name__)
app.secret_key = '12345'
CORS(app, supports_credentials=True)


init_mysql(app)

@app.route('/login', methods=['POST','GET'])
def login():
    data = request.get_json()    
    username = data.get('username')
    password = data.get('password')

    print(f"Username: {username}")
    
    session['username'] = username
    print("Session username:", session.get("username"))

    cur = mysql.connection.cursor()
    # Check if user with this username exists
    cur.execute("SELECT * FROM poke WHERE username = %s", (username,))
    user = cur.fetchone()

    if not user:
        cur.close()
        return jsonify({"message": "User does not exist"}), 401

    
    cur.execute("SELECT * FROM poke WHERE username = %s AND pass = %s", (username, password))
    user_with_password = cur.fetchone()
    cur.close()

    if user_with_password:
        return jsonify({"message": "Login successful!"}), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 401



    
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)


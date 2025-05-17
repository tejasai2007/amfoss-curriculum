from flask import Flask, request, jsonify, session
from db_config import mysql, init_mysql
from flask_cors import CORS

app = Flask(__name__)
app.secret_key = '12345'
CORS(app, supports_credentials=True)


init_mysql(app)

@app.route('/register', methods=['POST','GET'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    session['username']=username

    cur = mysql.connection.cursor()
    try:
        cur.execute("select * from poke where username=%s",(username,))
        user=cur.fetchone()
        if user:
            return jsonify({"message": "User already exists"}), 401


        cur.execute("insert into poke (username, pokemon_name,pass) values (%s,'PIKA',%s)", (username, password))
        mysql.connection.commit()
        return jsonify({"message": "Registration successful"}), 200
    except Exception as e:
        mysql.connection.rollback()
        return jsonify({"message": "Username already taken or error occurred"}), 400
    finally:
        cur.close()


@app.route('/login', methods=['POST','GET'])
def login():
    data = request.get_json()    
    username = data.get('username')
    password = data.get('password')
    print('yesss')

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




@app.route('/capture', methods=['POST'])
def captured():
    data = request.get_json()
    username = data.get("username")
    pokemon_name=data.get("pokemon")
    

    if not username :
        return jsonify({"error": "Missing data"}), 400

    cur = mysql.connection.cursor()
    cur.execute("select * from pokemon where (username, pokemon_captured) =(%s, %s)", (username,pokemon_name))
    data=cur.fetchone()
    if not data:

        try:
            cur.execute("INSERT INTO pokemon (username, pokemon_captured) VALUES (%s, %s)", (username,pokemon_name))
            mysql.connection.commit()
            return jsonify({"message": "Pokemon captured successfully"})
        except Exception as e:
            mysql.connection.rollback()
            return jsonify({"error": str(e)}), 500
        finally:
            cur.close()

@app.route('/captured', methods=['POST'])
def get_captured():
    data = request.get_json()
    username = data.get("username")

    if not username:
        return jsonify({"error": "Missing username"}), 400

    cur = mysql.connection.cursor()
    try:
        # Query from the same table where you store captures
        cur.execute("SELECT pokemon_captured FROM pokemon WHERE username = %s", (username,))
        rows = cur.fetchall()
        pokemons = [{'pokemon': row[0]} for row in rows]
        return jsonify({"captured": pokemons})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()   



@app.route('/trade', methods=['POST'])
def trade():
    data = request.get_json()
    from_user = data.get("from")      # Original owner
    to_user = data.get("to")          # New owner
    pokemon_name = data.get("pokemon")

    if not from_user or not to_user or not pokemon_name:
        return jsonify({"error": "Missing data"}), 400

    cur = mysql.connection.cursor()
    try:
        # Check if the from_user owns the Pokémon
        cur.execute("SELECT * FROM pokemon WHERE username = %s AND pokemon_captured = %s", (from_user, pokemon_name))
        existing = cur.fetchone()
        if not existing:
            return jsonify({"error": "Trade failed: Pokémon not owned by user"}), 404

        # Transfer Pokémon ownership
        cur.execute("UPDATE pokemon SET username = %s WHERE username = %s AND pokemon_captured = %s", (to_user, from_user, pokemon_name))
        mysql.connection.commit()
        return jsonify({"message": f"{pokemon_name} successfully traded to {to_user}"}), 200
    except Exception as e:
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)


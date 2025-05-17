from flask import Flask, request, jsonify,session
from db_config import mysql, init_mysql
from flask_cors import CORS

app = Flask(__name__)
app.secret_key = '12345'
CORS(app,supports_credentials=True)


init_mysql(app)



@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    session['username']=username

    cur = mysql.connection.cursor()
    try:
        cur.execute("select * from users where username=%s",(username,))
        user=cur.fetchone()
        if user:
            return jsonify({"message": "User already exists"}), 401


        cur.execute("insert into users (username, password) values (%s, %s)", (username, password))
        mysql.connection.commit()
        return jsonify({"message": "Registration successful"}), 200
    except Exception as e:
        mysql.connection.rollback()
        return jsonify({"message": "Username already taken or error occurred"}), 400
    finally:
        cur.close()

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    

    session['username']=username
    print(session.get("username"))

    cur = mysql.connection.cursor()
    # Check if user with this username exists
    cur.execute("SELECT * FROM users WHERE username = %s", (username,))
    user = cur.fetchone()

    if not user:
        cur.close()
        return jsonify({"message": "User does not exist"}), 401

    
    cur.execute("SELECT * FROM users WHERE username = %s AND password = %s", (username, password))
    user_with_password = cur.fetchone()
    cur.close()

    if user_with_password:
        return jsonify({"message": "Login successful!"}), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 401


@app.route('/api/account/settings', methods=['POST'])
def update():
    print(session.get("username"))
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    cur = mysql.connection.cursor()
    
    try:    
        cur.execute("update users set password=%s  where username=%s ",(password,username))
        mysql.connection.commit()
        return jsonify({"message": "updating successful"}), 200
    except Exception as e:
        print("Error:", e)
        return jsonify({"error": "Update failed"}), 500
    finally:
        cur.close()

@app.route('/api/watchlist', methods=['POST'])
def watchlist():
    data = request.get_json()
    watchlist = data.get("name")
    username = data.get("username")
    print(username,watchlist)
    cur = mysql.connection.cursor()

    try:
        cur.execute("SELECT movie_id FROM mv WHERE  username=%s and list_name = %s", (username, watchlist))
        rows = cur.fetchall()
        result = [{"movie_id": row[0]} for row in rows]  # This ensures an array is returned

        # Always return an empty array if no movies are found
        if not result:
            print("yes")
            return jsonify({"movie_ids": []})

        return jsonify({"movie_ids": result})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    finally:
        cur.close()

@app.route('/api/captured', methods=['POST'])
def save_watchlist():
    data = request.get_json()
    username = data.get("username")
    watchlist_name = data.get("watchlist_name")

    if not username or not watchlist_name:
        return jsonify({"error": "Missing data"}), 400

    cur = mysql.connection.cursor()
    try:
        cur.execute("INSERT INTO watchlists (username, list_name) VALUES (%s, %s)", (username, watchlist_name))
        mysql.connection.commit()
        return jsonify({"message": "Watchlist saved successfully"})
    except Exception as e:
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()


@app.route('/api/get_watchlists', methods=['POST'])
def get_watchlists():
    data = request.get_json()
    username = data.get("username")

    cur = mysql.connection.cursor()
    try:
        cur.execute("SELECT list_name FROM watchlists WHERE username = %s", (username,))
        rows = cur.fetchall()
        watchlists = [row[0] for row in rows]
        return jsonify({"watchlists": watchlists})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()



@app.route('/api/add', methods=['POST'])
def add():
    data = request.get_json()
    username = data.get("username")
    watchlist = data.get("name")
    movie_id = data.get("id")

    if not username or not movie_id or not watchlist:
        return jsonify({"error": "Missing required fields"}), 400

    try:
        movie_id = int(movie_id)  # Ensure movie_id is an integer
    except ValueError:
        return jsonify({"error": "Invalid movie ID"}), 400

    cur = mysql.connection.cursor()
    try:
        cur.execute("INSERT INTO mv (username, movie_id, list_name) VALUES (%s, %s, %s)",
                    (username, movie_id, watchlist))
        mysql.connection.commit()
        print("Movie added to watchlist successfully")
        return jsonify({"message": "Watchlist saved successfully"})
    except Exception as e:
        print("Database error:", e)  # Log the error
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()

@app.route('/api/save_review', methods=['POST'])
def save_review():
    data = request.get_json()
    username = data.get("username")
    review = data.get("review")
    movie_id = data.get("id")
    print(username,movie_id,review)

    if not username or not movie_id or not review:
        return jsonify({"error": "Missing required fields"}), 400

    try:
        movie_id = int(movie_id)
    except ValueError:
        return jsonify({"error": "Invalid movie ID"}), 400

    cur = mysql.connection.cursor()
    try:
        cur.execute("INSERT INTO review (username, review, id) VALUES (%s, %s, %s)",
                    (username, review, movie_id))
        mysql.connection.commit()
        print("Reviewed successfully")
        return jsonify({"message": "Review saved successfully"})
    except Exception as e:
        print("Database error:", e)
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()

@app.route('/api/get_review', methods=['POST'])
def get_review():
    data = request.get_json()
    id = data.get("id")

    cur = mysql.connection.cursor()
    try:
        cur.execute("SELECT review FROM review WHERE id = %s", (id,))
        rows = cur.fetchall()
        reviews = [row[0] for row in rows]
        return jsonify({"reviews": reviews})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()

if __name__ == '__main__':   
    app.run(debug=True)

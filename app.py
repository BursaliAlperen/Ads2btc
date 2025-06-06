from flask import Flask, send_file, request, jsonify, Response
import json, os
from datetime import datetime
from functools import wraps

app = Flask(__name__)

WITHDRAWALS_FILE = 'withdrawals.json'
ADMIN_PASSWORD = 'Alperen1628'

def save_withdrawal(data):
    if not os.path.exists(WITHDRAWALS_FILE):
        with open(WITHDRAWALS_FILE, 'w') as f:
            json.dump([], f)
    with open(WITHDRAWALS_FILE, 'r+') as f:
        withdrawals = json.load(f)
        withdrawals.append(data)
        f.seek(0)
        json.dump(withdrawals, f, indent=2)

@app.route('/')
def index():
    return send_file('index.html')

@app.route('/withdraw', methods=['POST'])
def withdraw():
    data = request.get_json()
    address = data.get('address')
    amount = data.get('amount')
    if address and amount:
        save_withdrawal({
            'address': address,
            'amount': amount,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        })
        return jsonify({'status': 'ok'})
    return jsonify({'error': 'Invalid data'}), 400

def check_auth(password):
    return password == ADMIN_PASSWORD

def authenticate():
    return Response('Unauthorized', 401, {'WWW-Authenticate': 'Basic realm="Login Required"'})

def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated

@app.route('/admin')
@requires_auth
def admin():
    if os.path.exists(WITHDRAWALS_FILE):
        with open(WITHDRAWALS_FILE) as f:
            data = json.load(f)
    else:
        data = []
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)

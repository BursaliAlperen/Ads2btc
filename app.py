from flask import Flask, request, jsonify, send_file, render_template
import time
import json
import os

app = Flask(__name__)
users_file = 'users.json'

def load_users():
    if os.path.exists(users_file):
        with open(users_file, 'r') as f:
            return json.load(f)
    return {}

def save_users(users):
    with open(users_file, 'w') as f:
        json.dump(users, f)

@app.route('/')
def index():
    return send_file('index.html')

@app.route('/save_address', methods=['POST'])
def save_address():
    data = request.json
    address = data.get('address')
    users = load_users()
    if address not in users:
        users[address] = {
            'balance': 0.0,
            'last_claim': time.time()
        }
        save_users(users)
    return jsonify({"status": "ok"})

@app.route('/update_balance', methods=['POST'])
def update_balance():
    data = request.json
    address = data.get('address')
    users = load_users()
    if address in users:
        now = time.time()
        if now - users[address]['last_claim'] >= 60:
            users[address]['balance'] += 0.0000001
            users[address]['last_claim'] = now
            save_users(users)
        return jsonify({"balance": users[address]['balance']})
    return jsonify({"balance": 0.0})

@app.route('/xadmin-panel-8w1hda')
def admin_panel():
    users = load_users()
    return render_template('admin.html', users=users)

if __name__ == '__main__':
    app.run()

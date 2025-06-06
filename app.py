from flask import Flask, request, send_file, jsonify, redirect, url_for
import json
import time
import os

app = Flask(__name__)

DATA_FILE = 'data.json'
WITHDRAWALS_FILE = 'withdrawals.json'
ADMIN_PASSWORD = 'Alperen1628'
REWARD_PER_MINUTE = 0.0000001
WITHDRAWAL_THRESHOLD = 0.000001
BONUS_INTERVAL = 600  # 10 dakika
BONUS_AMOUNT = 0.0000005  # Bonus BTC miktarı

def load_data():
    if not os.path.exists(DATA_FILE):
        return {}
    with open(DATA_FILE, 'r') as f:
        return json.load(f)

def save_data(data):
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f)

def load_withdrawals():
    if not os.path.exists(WITHDRAWALS_FILE):
        return []
    with open(WITHDRAWALS_FILE, 'r') as f:
        return json.load(f)

def save_withdrawals(data):
    with open(WITHDRAWALS_FILE, 'w') as f:
        json.dump(data, f)

@app.route('/')
def index():
    return send_file('index.html')

@app.route('/save_address', methods=['POST'])
def save_address():
    wallet = request.form.get('wallet')
    if not wallet:
        return 'No wallet provided', 400
    data = load_data()
    if wallet not in data:
        data[wallet] = {"balance": 0, "last_claim": time.time()}
        save_data(data)
    return 'Wallet saved'

@app.route('/get_balance', methods=['GET'])
def get_balance():
    wallet = request.args.get('wallet')
    if not wallet:
        return jsonify({'balance': 0})
    data = load_data()
    if wallet in data:
        now = time.time()
        elapsed = now - data[wallet]["last_claim"]
        added = int(elapsed / 60) * REWARD_PER_MINUTE
        data[wallet]["balance"] += added
        data[wallet]["last_claim"] = now
        balance = data[wallet]["balance"]
        if balance >= WITHDRAWAL_THRESHOLD:
            withdrawals = load_withdrawals()
            withdrawals.append({
                "wallet": wallet,
                "amount": balance,
                "timestamp": time.time()
            })
            save_withdrawals(withdrawals)
            data[wallet]["balance"] = 0
        save_data(data)
        return jsonify({'balance': round(balance, 8)})
    return jsonify({'balance': 0})

@app.route('/leaderboard')
def leaderboard():
    data = load_data()
    leaderboard = sorted(data.items(), key=lambda x: x[1].get('balance', 0), reverse=True)
    top_users = [{"wallet": user[0], "balance": round(user[1].get('balance', 0), 8)} for user in leaderboard[:10]]
    return jsonify(top_users)

@app.route('/claim_bonus', methods=['POST'])
def claim_bonus():
    wallet = request.form.get('wallet')
    if not wallet:
        return jsonify({"error": "Wallet required"}), 400

    data = load_data()
    now = time.time()

    if wallet not in data:
        return jsonify({"error": "Wallet not found"}), 404

    last_bonus = data[wallet].get('last_bonus', 0)
    if now - last_bonus < BONUS_INTERVAL:
        remaining = int(BONUS_INTERVAL - (now - last_bonus))
        return jsonify({"error": f"Bonus already claimed. Try again in {remaining} seconds."}), 429

    data[wallet]['balance'] += BONUS_AMOUNT
    data[wallet]['last_bonus'] = now
    save_data(data)

    return jsonify({"message": f"Bonus {BONUS_AMOUNT} BTC awarded!", "balance": round(data[wallet]['balance'], 8)})

@app.route('/admin', methods=['GET'])
def admin():
    password = request.args.get('password')
    if password != ADMIN_PASSWORD:
        return 'Unauthorized', 403
    withdrawals = load_withdrawals()
    html = "<h2>Çekim Talepleri</h2><ul>"
    for w in withdrawals:
        html += f"<li><b>{w['wallet']}</b> - {w['amount']} BTC - {time.ctime(w['timestamp'])}</li>"
    html += "</ul>"
    return html

if __name__ == '__main__':
    app.run(debug=True)
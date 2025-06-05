from flask import Flask, request, send_file
import json
import os
import time

app = Flask(__name__)

DATA_FILE = "wallets.json"

@app.route("/", methods=["GET"])
def home():
    return send_file("index.html")

@app.route("/save", methods=["POST"])
def save_wallet():
    wallet = request.form.get("wallet")
    if not wallet:
        return "Cüzdan adresi girilmedi", 400

    if not os.path.exists(DATA_FILE):
        with open(DATA_FILE, "w") as f:
            json.dump({}, f)

    with open(DATA_FILE, "r") as f:
        data = json.load(f)

    timestamp = int(time.time())
    if wallet not in data:
        data[wallet] = {"balance": 0.0000000, "last_active": timestamp}

    with open(DATA_FILE, "w") as f:
        json.dump(data, f)

    return send_file("index.html")

if __name__ == "__main__":
    app.run(debug=True)


from flask import Flask, request, send_file
import time

app = Flask(__name__)
wallets = {}

@app.route("/", methods=["GET"])
def home():
    return send_file("index.html")

@app.route("/save_wallet", methods=["POST"])
def save_wallet():
    wallet = request.form.get("wallet")
    if wallet:
        wallets[wallet] = {"timestamp": time.time(), "balance": 0}
    return send_file("index.html")

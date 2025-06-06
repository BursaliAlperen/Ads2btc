
from flask import Flask, request, send_file, jsonify
import json
import time
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/")
def index():
    return send_file("index.html")

@app.route("/withdraw", methods=["POST"])
def withdraw():
    data = request.get_json()
    wallet = data.get("wallet")
    amount = data.get("amount")
    ts = time.strftime('%Y-%m-%d %H:%M:%S')

    if wallet and amount:
        new_entry = {"wallet": wallet, "amount": amount, "time": ts}
        try:
            with open("withdrawals.json", "r") as file:
                withdrawals = json.load(file)
        except:
            withdrawals = []

        withdrawals.append(new_entry)

        with open("withdrawals.json", "w") as file:
            json.dump(withdrawals, file, indent=4)

        return jsonify({"status": "success"}), 200
    return jsonify({"status": "error"}), 400

if __name__ == "__main__":
    app.run(debug=True)

from flask import Flask, send_file, request, jsonify
import time

app = Flask(__name__)

clicks = 0
btc_per_click = 0.0000001
wallet = "BURAYA_BTC_ADRESİNİ_YAZ"

@app.route("/", methods=["GET", "HEAD"])
def index():
    return send_file("index.html")

@app.route("/click", methods=["POST"])
def click():
    global clicks
    clicks += 1
    return jsonify({"clicks": clicks, "reward": btc_per_click})

@app.route("/stats", methods=["GET"])
def stats():
    return jsonify({
        "total_clicks": clicks,
        "btc_per_click": btc_per_click,
        "total_reward_btc": clicks * btc_per_click
    })

if __name__ == "__main__":
    app.run(debug=True)

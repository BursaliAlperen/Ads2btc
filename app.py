from flask import Flask, request, render_template, redirect
import json, os

app = Flask(__name__)
DATA_FILE = "data.json"

# Veri dosyası yoksa oluştur
if not os.path.exists(DATA_FILE):
    with open(DATA_FILE, "w") as f:
        json.dump({}, f)

@app.route("/", methods=["GET", "HEAD"])
def index():
    return render_template("index.html")

@app.route("/submit", methods=["POST", "HEAD"])
def submit():
    btc = request.form.get("btc")
    with open(DATA_FILE, "r") as f:
        data = json.load(f)

    if btc not in data:
        data[btc] = {"views": 0}

    data[btc]["views"] += 1

    with open(DATA_FILE, "w") as f:
        json.dump(data, f)

    return render_template("thankyou.html", btc=btc, views=data[btc]["views"])

@app.route("/stats/<btc>", methods=["GET", "HEAD"])
def stats(btc):
    with open(DATA_FILE, "r") as f:
        data = json.load(f)

    user = data.get(btc, {"views": 0})
    return render_template("stats.html", btc=btc, views=user["views"])

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000)


from flask import Flask, render_template, request
import json, os

app = Flask(__name__)

DATA_FILE = "admin_panel/data.json"

def load_data():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    return {}

@app.route("/admin")
def admin():
    data = load_data()
    return render_template("admin.html", users=data)

if __name__ == "__main__":
    app.run(debug=True)

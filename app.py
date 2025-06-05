
from flask import Flask, request, redirect, send_file, session, render_template_string
import time
import os

app = Flask(__name__)
app.secret_key = 'btc_secret_key'

user_data = {}

@app.route('/', methods=['GET', 'POST'])
def index():
    wallet = session.get('wallet')
    satoshis = user_data.get(wallet, {}).get('satoshis', 0) if wallet else 0
    return render_template_string(open("index.html").read(), satoshis=satoshis)

@app.route('/set_wallet', methods=['POST'])
def set_wallet():
    wallet = request.form.get('wallet')
    session['wallet'] = wallet
    if wallet not in user_data:
        user_data[wallet] = {'satoshis': 0, 'last_click': time.time()}
    return redirect('/')

@app.route('/withdraw', methods=['POST'])
def withdraw():
    wallet = session.get('wallet')
    if not wallet or user_data.get(wallet, {}).get('satoshis', 0) < 100:
        return redirect('/')
    user_data[wallet]['satoshis'] = 0
    print(f"Ödeme talebi alındı: {wallet}")
    return redirect('/')

@app.before_request
def count_view_time():
    wallet = session.get('wallet')
    if not wallet:
        return
    now = time.time()
    last = user_data.get(wallet, {}).get('last_click', 0)
    if now - last >= 60:
        user_data[wallet]['satoshis'] += 10
        user_data[wallet]['last_click'] = now

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))

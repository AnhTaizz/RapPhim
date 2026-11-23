"""HTTP smoke test for a running, seeded demo. Buys three seats on show 1."""
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
from http.cookiejar import CookieJar
import os
import re
from threading import Barrier
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import build_opener, HTTPCookieProcessor

BASE = os.environ.get("DEMO_URL", "http://127.0.0.1:8088") + "/"
TODAY = datetime.now(timezone(timedelta(hours=7))).date().isoformat()


class Client:
    def __init__(self, user):
        self.http = build_opener(HTTPCookieProcessor(CookieJar()))
        self.token = ""
        self.call("index.jsp")
        self.call("index.jsp", {"user": user, "password": "Demo08!"})

    def call(self, page, form=None):
        data = None if form is None else urlencode(dict(form, token=self.token), doseq=True).encode()
        with self.http.open(BASE + page, data, timeout=40) as response:
            body = response.read().decode()
        tokens = re.findall(r'name="token" value="([^"]+)"', body)
        if tokens:
            self.token = tokens[0]
        return body


manager = Client("quanly")
first, second = Client("khach"), Client("khach")
edit = "gdSuaPhim.jsp?id=1"
assert "Mắt biếc" in manager.call("gdTimPhim.jsp?" + urlencode({"q": "biếc"}))
original = manager.call(edit)
description = re.search(r'name="description">(.*?)</textarea>', original, re.S)[1]
form = dict(id=1, name="Mắt biếc", genre="Tình cảm", minutes="117", description=description)
assert "Sửa thông tin phim thành công" in manager.call(edit, dict(form, minutes="118"))
assert 'name="minutes" value="118"' in manager.call(edit)
assert "Sửa thông tin phim thành công" in manager.call(edit, form)
duplicate = manager.call(edit, dict(form, name="Song Lang"))
assert "Tên phim đã tồn tại" in duplicate and 'name="name" value="Song Lang"' in duplicate
assert "Thời lượng phải" in manager.call(edit, dict(form, minutes="0"))
for path, payload in [(edit, form), ("gdTimPhim.jsp", None), ("gdThongKe.jsp", None)]:
    try:
        first.call(path, payload)
    except HTTPError as exc:
        assert exc.code == 403
    else:
        raise AssertionError("Customer accessed " + path)

stats = "gdThongKe.jsp?from=" + TODAY + "&to=" + TODAY
def revenue():
    body = manager.call(stats)
    match = re.search(r'<td>Mắt biếc</td><td>Tình cảm</td><td class="currency">([0-9.]+) ₫', body)
    return int(match[1].replace(".", "")) if match else 0

before = revenue()
page = "gdChonGhe.jsp?id=1"
seat_map = first.call(page)
all_seats = re.findall(r'name="seat" value="([A-H](?:10|[1-9]))" aria-label="Ghế ', seat_map)
assert all_seats == [f"{row}{col}" for row in "ABCDEFGH" for col in range(1, 11)]
free = re.findall(r'name="seat" value="([A-H](?:10|[1-9]))" aria-label="Ghế [A-H](?:10|[1-9])"', seat_map)
expanded = [seat for seat in free if seat[0] in "GH" or int(seat[1:]) > 8]
assert len(free) >= 4 and expanded, "Run against fresh demo data"
chosen = [free[0], expanded[-1]] if free[0] != expanded[-1] else free[:2]
remaining = [seat for seat in free if seat not in chosen]
def buy(client, seats, action):
    return client.call(page, dict(id=1, seat=seats, action=action))

assert "160.000 ₫" in buy(first, chosen, "preview")
assert "Danh sách ghế không hợp lệ" in buy(first, ["H11"], "confirm")
receipt = buy(first, chosen, "confirm")
assert "Mua vé thành công. Ngày mua:" in receipt
refreshed = first.call(page)
assert all("Ghế " + seat + " đã bán" in refreshed for seat in chosen)
gate = Barrier(2)
def compete(client):
    assert "Xác nhận mua" in buy(client, [remaining[0]], "preview")
    gate.wait(timeout=20)
    return buy(client, [remaining[0]], "confirm")

with ThreadPoolExecutor(2) as pool:
    results = list(pool.map(compete, [first, second]))
assert sum("Mua vé thành công" in body for body in results) == 1
assert sum("Ghế đã bán: " + remaining[0] in body for body in results) == 1
assert "Ghế đã bán" in buy(second, remaining[:2], "confirm")
assert "Ghế " + remaining[1] + " đã bán" not in first.call(page)
assert revenue() - before == 240000
assert "Không có doanh thu" in manager.call("gdThongKe.jsp?from=2001-01-01&to=2001-01-31")
assert "Từ ngày phải" in manager.call("gdThongKe.jsp?from=2026-01-02&to=2026-01-01")
assert "Đăng nhập" in first.call("logout.jsp", {})
assert "Đăng nhập" in first.call(page)
print("PASS: edit, duplicate, validation, roles, booking, race, rollback, revenue, dates, logout")

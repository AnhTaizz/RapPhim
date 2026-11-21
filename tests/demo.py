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
    match = re.search(r"<td>Mắt biếc</td><td>([0-9.]+) ₫", body)
    return int(match[1].replace(".", "")) if match else 0

before = revenue()
page = "gdChonGhe.jsp?id=1"
free = re.findall(r'name="seat" value="([A-F][1-8])" aria-label="Ghế [A-F][1-8]"', first.call(page))
assert len(free) >= 4, "Run against fresh demo data"
def buy(client, seats, action):
    return client.call(page, dict(id=1, seat=seats, action=action))

assert "160.000 ₫" in buy(first, free[:2], "preview")
assert "Mua vé thành công" in buy(first, free[:2], "confirm")
refreshed = first.call(page)
assert all("Ghế " + seat + " đã bán" in refreshed for seat in free[:2])
gate = Barrier(2)
def compete(client):
    assert "Xác nhận mua" in buy(client, [free[2]], "preview")
    gate.wait(timeout=20)
    return buy(client, [free[2]], "confirm")

with ThreadPoolExecutor(2) as pool:
    results = list(pool.map(compete, [first, second]))
assert sum("Mua vé thành công" in body for body in results) == 1
assert sum("Ghế đã bán: " + free[2] in body for body in results) == 1
assert "Ghế đã bán" in buy(second, [free[2], free[3]], "confirm")
assert "Ghế " + free[3] + " đã bán" not in first.call(page)
assert revenue() - before == 240000
assert "Không có doanh thu" in manager.call("gdThongKe.jsp?from=2001-01-01&to=2001-01-31")
assert "Từ ngày phải" in manager.call("gdThongKe.jsp?from=2026-01-02&to=2026-01-01")
assert "Đăng nhập" in first.call("logout.jsp", {})
assert "Đăng nhập" in first.call(page)
print("PASS: edit, duplicate, validation, roles, booking, race, rollback, revenue, dates, logout")

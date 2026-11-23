<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/customer.jspf" %><%
int id=number(request.getParameter("id")); var dao=new VeMuaDAO();
VeMua.SuatChieu show;
try {show=dao.dkChonSuatChieu(id);} catch(IllegalArgumentException e){response.sendError(404,e.getMessage());return;}
String[] values=request.getParameterValues("seat"); var seats=values==null?List.<String>of():Arrays.asList(values);
VeMua review=null;
VeMuaDAO.Receipt receipt=null;
if(post) {
    try {
        if("confirm".equals(request.getParameter("action"))) {
            var result=dao.dkXacNhanMua(member.id(),id,seats);
            session.setAttribute("receipt-"+id,result);
            response.sendRedirect("gdChonGhe.jsp?id="+id);return;
        }
        review=dao.dkChonGhe(id,seats);
    } catch(IllegalArgumentException e){error=e.getMessage();}
} else {
    Object savedReceipt=session.getAttribute("receipt-"+id);
    if(savedReceipt instanceof VeMuaDAO.Receipt) receipt=(VeMuaDAO.Receipt)savedReceipt;
    session.removeAttribute("receipt-"+id);
}
var sold=dao.gheDaBan(id);
var selected=new ArrayList<String>();
title="Chọn ghế";
%><%@ include file="WEB-INF/header.jspf" %>
<p class="customer-name">Khách hàng: <%=h(member.name())%></p>
<p class="show-details">
  <span><%=h(show.phim())%></span><span><time datetime="<%=show.gio()%>"><%=dateTime(show.gio())%></time></span>
  <span>Phòng <%=h(show.phong())%></span><span>Giá vé: <%=money(show.gia())%></span>
</p>
<form method="post" class="booking">
  <input type="hidden" name="token" value="<%=token%>">
  <input type="hidden" name="id" value="<%=id%>">
  <fieldset class="seat-map">
    <legend class="sr-only">Sơ đồ ghế</legend>
    <p class="screen">Màn hình</p>
    <% for(char row='A';row<=VeMua.LAST_ROW;row++){ %>
    <div class="seat-row">
      <b aria-hidden="true"><%=row%></b>
      <% for(int col=1;col<=VeMua.SEATS_PER_ROW;col++){
          String n=""+row+col;
          boolean taken=sold.contains(n), chosen=post && seats.contains(n) && !taken;
          if(chosen) selected.add(n);
      %>
      <label class="seat">
        <input type="checkbox" name="seat" value="<%=n%>" aria-label="Ghế <%=n%><%=taken?" đã bán":""%>" <%=taken||review!=null?"disabled":""%> <%=chosen?"checked":""%>>
        <span><%=n%></span>
      </label>
      <% } %>
    </div>
    <% } %>
    <p class="seat-legend">
      <span><i aria-hidden="true"></i>Trống</span>
      <span><i class="selected-key" aria-hidden="true"></i>Đang chọn</span>
      <span><i class="sold-key" aria-hidden="true"></i>Đã bán</span>
    </p>
  </fieldset>
  <%
    if(receipt!=null) selected.addAll(receipt.order().ghe());
    BigDecimal amount=receipt==null?show.gia().multiply(BigDecimal.valueOf(selected.size())):receipt.order().tinhTien();
  %>
  <div class="booking-summary" aria-live="polite">
    <p>Ghế đã chọn: <span id="selected"><%=selected.isEmpty()?"—":String.join(", ",selected)%></span></p>
    <p class="booking-total">Tổng tiền: <strong id="amount"><%=money(amount)%></strong></p>
  </div>
  <% if(review!=null){for(String n:review.ghe()){ %><input type="hidden" name="seat" value="<%=n%>"><% }} %>
  <div class="booking-actions">
    <button name="action" value="confirm">Xác nhận mua</button>
    <% if(!error.isEmpty()){ %><p role="alert"><%=h(error)%></p>
    <% }else if(receipt!=null){ %><p class="notice" role="status">Mua vé thành công. Ngày mua: <time datetime="<%=receipt.purchasedAt()%>"><%=dateTime(receipt.purchasedAt())%></time> · Vé #<%=receipt.id()%></p><% } %>
  </div>
  <% if(review!=null){ %><p><a href="gdChonGhe.jsp?id=<%=id%>">Chọn lại ghế</a></p><% } %>
</form>
<% if(review==null){ %><script>
const seats = [...document.querySelectorAll('.seat input:not(:disabled)')];
const selected = document.querySelector('#selected');
const amount = document.querySelector('#amount');
const currency = new Intl.NumberFormat('vi-VN');
function updateSelection() {
  const chosen = seats.filter(seat => seat.checked).map(seat => seat.value);
  selected.textContent = chosen.join(', ') || '—';
  amount.textContent = currency.format(chosen.length * <%=show.gia()%>) + ' ₫';
}
document.querySelector('.seat-map').addEventListener('change', updateSelection);
</script><% } %><%@ include file="WEB-INF/footer.jspf" %>

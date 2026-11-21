<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/customer.jspf" %><%
int id=number(request.getParameter("id")); var dao=new VeMuaDAO();
VeMua.SuatChieu show;
try {show=dao.dkChonSuatChieu(id);} catch(IllegalArgumentException e){response.sendError(404,e.getMessage());return;}
String[] values=request.getParameterValues("seat"); var seats=values==null?List.<String>of():Arrays.asList(values);
VeMua review=null; String receipt=null;
if(post) {
    try {
        if("confirm".equals(request.getParameter("action"))) {
            var result=dao.dkXacNhanMua(member.id(),id,seats);
            session.setAttribute("receipt-"+id,"Mua vé thành công. Vé #"+result.id()+" · Ghế "+String.join(", ",result.order().ghe())+" · "+money(result.order().tinhTien()));
            response.sendRedirect("gdChonGhe.jsp?id="+id);return;
        }
        review=dao.dkChonGhe(id,seats);
    } catch(IllegalArgumentException e){error=e.getMessage();}
} else {receipt=(String)session.getAttribute("receipt-"+id);session.removeAttribute("receipt-"+id);}
var sold=dao.gheDaBan(id); title=show.phim();
%><%@ include file="WEB-INF/header.jspf" %>
<p class="sub"><%=when(show)%> · Phòng <%=h(show.phong())%> · <%=show.phut()%> phút</p>
<% if(receipt!=null){ %><p class="notice" role="status"><%=h(receipt)%></p><% } if(!error.isEmpty()){ %><p role="alert"><%=h(error)%></p><% } %>
<form method="post" class="booking">
<input type="hidden" name="token" value="<%=token%>"><input type="hidden" name="id" value="<%=id%>">
<section class="panel"><h2>Sơ đồ ghế</h2><p class="screen">Màn hình</p>
<div class="grid"><% for(char row='A';row<='F';row++){ %><b class="row"><%=row%></b><% for(int col=1;col<=8;col++){
String n=""+row+col; boolean taken=sold.contains(n), chosen=seats.contains(n) && !taken;
%><label class="seat"><input type="checkbox" name="seat" value="<%=n%>" aria-label="Ghế <%=n%><%=taken?" đã bán":""%>" <%=taken||review!=null?"disabled":""%> <%=chosen?"checked":""%>><span><%=n%></span></label><% }} %></div>
<p class="legend">□ Trống &nbsp; ✓ Đang chọn &nbsp; × Đã bán</p></section>
<aside class="panel summary"><h2><%=review==null?"Vé của bạn":"Xác nhận vé"%></h2>
<dl><dt>Giá mỗi ghế</dt><dd><%=money(show.gia())%></dd><dt>Ghế</dt><dd id="selected"><%=review==null?"—":String.join(", ",review.ghe())%></dd>
<dt>Tổng tiền</dt><dd id="amount"><%=money(review==null?BigDecimal.ZERO:review.tinhTien())%></dd></dl>
<% if(review!=null){for(String n:review.ghe()){ %><input type="hidden" name="seat" value="<%=n%>"><% } %>
<button name="action" value="confirm">Xác nhận mua</button><a href="gdChonGhe.jsp?id=<%=id%>">Chọn lại ghế</a>
<% }else{ %><button name="action" value="preview">Kiểm tra vé</button><% } %></aside></form>
<% if(review==null){ %><script>
const boxes=[...document.querySelectorAll('.seat input:not(:disabled)')];
function update(){const seats=boxes.filter(b=>b.checked).map(b=>b.value);
document.querySelector('#selected').textContent=seats.join(', ') || '—';
document.querySelector('#amount').textContent=new Intl.NumberFormat('vi-VN').format(seats.length*<%=show.gia()%>)+' ₫';}
boxes.forEach(b=>b.addEventListener('change',update));update();
</script><% } %><%@ include file="WEB-INF/footer.jspf" %>

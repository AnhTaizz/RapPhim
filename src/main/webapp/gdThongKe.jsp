<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/manager.jspf" %><%
var today=LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));boolean query=request.getParameter("from")!=null || request.getParameter("to")!=null;
String from=query?val(request.getParameter("from")):today.withDayOfMonth(1).toString();
String to=query?val(request.getParameter("to")):today.toString();
List<PhimThongKe> rows=List.of();
if(query){try{var start=LocalDate.parse(from);var end=LocalDate.parse(to);
rows=new PhimThongKeDAO().dkThongKe(start,end);}
catch(DateTimeException e){error="Vui lòng nhập đủ hai ngày hợp lệ.";}catch(IllegalArgumentException e){error=e.getMessage();}}
title="Thống kê phim theo doanh thu";
%><%@ include file="WEB-INF/header.jspf" %>
<form class="filters date-filters" method="get">
  <div><label for="from-date">Từ ngày:</label><input id="from-date" required type="date" name="from" value="<%=h(from)%>"></div>
  <div><label for="to-date">Đến ngày:</label><input id="to-date" required type="date" name="to" value="<%=h(to)%>"></div>
  <button>Thống kê</button>
</form>
<% if(!error.isEmpty()){ %><p role="alert"><%=h(error)%></p>
<% }else if(query){ %>
  <% if(rows.isEmpty()){ %><p class="notice" role="status">Không có doanh thu trong khoảng thời gian đã chọn.</p>
  <% }else{BigDecimal total=BigDecimal.ZERO; int rank=0; %>
  <div class="table-scroll" tabindex="0" role="region" aria-label="Doanh thu theo phim">
    <table class="revenue">
      <thead><tr><th scope="col">STT</th><th scope="col">Tên phim</th><th scope="col">Thể loại</th><th scope="col" aria-sort="descending">Doanh thu</th></tr></thead>
      <tbody>
        <% for(var p:rows){total=total.add(p.getDoanhThu()); %>
        <tr><td><%=++rank%></td><td><%=h(p.tenPhim)%></td><td><%=h(p.theLoai)%></td><td class="currency"><%=money(p.getDoanhThu())%></td></tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <p class="revenue-total">Tổng doanh thu: <strong class="currency"><%=money(total)%></strong></p>
  <% } %>
<% } %>
<%@ include file="WEB-INF/footer.jspf" %>

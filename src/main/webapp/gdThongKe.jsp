<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/manager.jspf" %><%
var today=LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));boolean query=request.getParameter("from")!=null || request.getParameter("to")!=null;
String from=query?val(request.getParameter("from")):today.withDayOfMonth(1).toString();
String to=query?val(request.getParameter("to")):today.toString();
List<PhimThongKe> rows=List.of();String period="";
if(query){try{var start=LocalDate.parse(from);var end=LocalDate.parse(to);
rows=new PhimThongKeDAO().dkThongKe(start,end);
var fmt=DateTimeFormatter.ofPattern("dd/MM/yyyy");period=start.format(fmt)+" – "+end.format(fmt);}
catch(DateTimeException e){error="Vui lòng nhập đủ hai ngày hợp lệ.";}catch(IllegalArgumentException e){error=e.getMessage();}}
title="Doanh thu theo phim";
%><%@ include file="WEB-INF/header.jspf" %><form class="filters"><label>Từ ngày<input required type="date" name="from" value="<%=h(from)%>"></label><label>Đến ngày<input required type="date" name="to" value="<%=h(to)%>"></label><button>Thống kê</button></form>
<% if(!error.isEmpty()){ %><p role="alert"><%=h(error)%></p><% }else if(query){ %><section class="panel"><h2><%=h(period)%></h2>
<% if(rows.isEmpty()){ %><p>Không có doanh thu trong khoảng thời gian đã chọn.</p><% }else{BigDecimal total=BigDecimal.ZERO; %>
<table><thead><tr><th>Tên phim</th><th>Doanh thu</th></tr></thead><tbody><% for(var p:rows){total=total.add(p.getDoanhThu()); %>
<tr><td><%=h(p.tenPhim)%></td><td><%=money(p.getDoanhThu())%></td></tr><% } %></tbody><tfoot><tr><th>Tổng doanh thu</th><td><%=money(total)%></td></tr></tfoot></table><% } %></section><% } %><%@ include file="WEB-INF/footer.jspf" %>

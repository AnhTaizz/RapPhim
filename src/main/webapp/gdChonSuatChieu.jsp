<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/customer.jspf" %><%
title="Lịch chiếu"; var shows=new VeMuaDAO().dkLayDsSuatChieu();
%><%@ include file="WEB-INF/header.jspf" %>
<section class="list"><% for(var s:shows){ %><article><div><h2><%=h(s.phim())%></h2><small><%=h(s.loai())%> · <%=s.phut()%> phút</small></div>
<div><strong><%=when(s)%></strong><br>Phòng <%=h(s.phong())%> · <%=money(s.gia())%></div>
<a class="button" href="gdChonGhe.jsp?id=<%=s.id()%>">Chọn ghế</a></article><% } if(shows.isEmpty()){ %><p>Chưa có suất chiếu sắp tới.</p><% } %></section>
<%@ include file="WEB-INF/footer.jspf" %>

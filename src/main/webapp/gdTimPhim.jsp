<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/manager.jspf" %><%
title="Quản lý phim"; String keyword=val(request.getParameter("q")); var films=new PhimDAO().dkTimPhim(keyword);
%><%@ include file="WEB-INF/header.jspf" %><form class="filters" method="get"><label>Tìm theo tên phim<input name="q" type="search" value="<%=h(keyword)%>"></label><button>Tìm phim</button></form>
<div class="list"><% for(var p:films){ %><article><div><h2><%=h(p.tenPhim)%></h2><small><%=h(p.theLoai)%> · <%=p.thoiLuong%> phút</small></div><a href="gdSuaPhim.jsp?id=<%=p.id%>">Chỉnh sửa</a></article><% } if(films.isEmpty()){ %><p>Không tìm thấy phim phù hợp.</p><% } %></div><%@ include file="WEB-INF/footer.jspf" %>

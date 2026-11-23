<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/manager.jspf" %><%
title="Tìm phim cần sửa"; String keyword=val(request.getParameter("q")); var films=new PhimDAO().dkTimPhim(keyword);
%><%@ include file="WEB-INF/header.jspf" %>
<form class="filters search-filters" method="get">
  <label for="film-query">Tên phim:</label>
  <input id="film-query" name="q" type="search" value="<%=h(keyword)%>">
  <button>Tìm</button>
</form>
<div class="table-scroll" tabindex="0" role="region" aria-label="Danh sách phim">
  <table class="films">
    <thead><tr><th scope="col">Tên phim</th><th scope="col">Thể loại</th><th scope="col">Thời lượng</th><th scope="col"><span class="sr-only">Thao tác</span></th></tr></thead>
    <tbody>
      <% for(var p:films){ %>
      <tr>
        <td><%=h(p.tenPhim)%></td>
        <td><%=h(p.theLoai)%></td>
        <td><%=p.thoiLuong%> phút</td>
        <td><a href="gdSuaPhim.jsp?id=<%=p.id%>" aria-label="Chọn <%=h(p.tenPhim)%> để sửa">Chọn</a></td>
      </tr>
      <% } if(films.isEmpty()){ %><tr><td colspan="4">Không tìm thấy phim phù hợp.</td></tr><% } %>
    </tbody>
  </table>
</div>
<%@ include file="WEB-INF/footer.jspf" %>

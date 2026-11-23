<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/customer.jspf" %><%
title="Chọn suất chiếu"; var shows=new VeMuaDAO().dkLayDsSuatChieu();
%><%@ include file="WEB-INF/header.jspf" %>
<div class="table-scroll" tabindex="0" role="region" aria-label="Danh sách suất chiếu">
  <table class="showtimes">
    <thead><tr><th scope="col">Tên phim</th><th scope="col">Ngày giờ chiếu</th><th scope="col">Phòng</th><th scope="col">Giá vé</th><th scope="col"><span class="sr-only">Thao tác</span></th></tr></thead>
    <tbody>
      <% for(var s:shows){ %>
      <tr>
        <td><%=h(s.phim())%></td>
        <td><time datetime="<%=s.gio()%>"><%=dateTime(s.gio())%></time></td>
        <td><%=h(s.phong())%></td>
        <td class="currency"><%=money(s.gia())%></td>
        <td><a href="gdChonGhe.jsp?id=<%=s.id()%>" aria-label="Chọn <%=h(s.phim())%> — <%=dateTime(s.gio())%>">Chọn</a></td>
      </tr>
      <% } if(shows.isEmpty()){ %><tr><td colspan="5">Chưa có suất chiếu sắp tới.</td></tr><% } %>
    </tbody>
  </table>
</div>
<%@ include file="WEB-INF/footer.jspf" %>

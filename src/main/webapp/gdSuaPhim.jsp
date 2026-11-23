<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/manager.jspf" %><%
int id=number(request.getParameter("id")); var dao=new PhimDAO(); var film=dao.dkChonPhim(id);
if(film==null){response.sendError(404);return;}
String name=film.tenPhim,genre=film.theLoai,minutes=""+film.thoiLuong,description=film.moTa;
if(post){name=val(request.getParameter("name"));genre=val(request.getParameter("genre"));minutes=val(request.getParameter("minutes"));description=val(request.getParameter("description"));
try{dao.dkLuu(new Phim(id,name,genre,number(minutes),description));
session.setAttribute("savedFilm",id);response.sendRedirect("gdSuaPhim.jsp?id="+id);return;}
catch(IllegalArgumentException e){error=e.getMessage();}}
boolean saved=Integer.valueOf(id).equals(session.getAttribute("savedFilm"));session.removeAttribute("savedFilm");
title="Sửa thông tin phim";
%><%@ include file="WEB-INF/header.jspf" %>
<form class="edit" method="post">
  <input type="hidden" name="token" value="<%=token%>">
  <input type="hidden" name="id" value="<%=id%>">
  <label for="film-name">Tên phim:</label>
  <input id="film-name" required maxlength="255" name="name" value="<%=h(name)%>">
  <label for="film-genre">Thể loại:</label>
  <input id="film-genre" required maxlength="100" name="genre" value="<%=h(genre)%>">
  <label for="film-minutes">Thời lượng:</label>
  <div class="duration">
    <input id="film-minutes" aria-describedby="duration-unit" required type="number" min="1" name="minutes" value="<%=h(minutes)%>">
    <span id="duration-unit">phút</span>
  </div>
  <label for="film-description">Mô tả:</label>
  <textarea id="film-description" rows="4" name="description"><%=h(description)%></textarea>
  <div class="edit-actions">
    <button>Lưu</button>
    <a href="gdTimPhim.jsp">Quay lại</a>
    <% if(!error.isEmpty()){ %><p role="alert"><%=h(error)%></p>
    <% }else if(saved){ %><p class="notice" role="status">Sửa thông tin phim thành công.</p><% } %>
  </div>
</form>
<%@ include file="WEB-INF/footer.jspf" %>

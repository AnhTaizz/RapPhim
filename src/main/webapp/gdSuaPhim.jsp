<%@ include file="WEB-INF/base.jspf" %><%@ include file="WEB-INF/manager.jspf" %><%
int id=number(request.getParameter("id")); var dao=new PhimDAO(); var film=dao.dkChonPhim(id);
if(film==null){response.sendError(404);return;}
String name=film.tenPhim,genre=film.theLoai,minutes=""+film.thoiLuong,description=film.moTa;
if(post){name=val(request.getParameter("name"));genre=val(request.getParameter("genre"));minutes=val(request.getParameter("minutes"));description=val(request.getParameter("description"));
try{dao.dkLuu(new Phim(id,name,genre,number(minutes),description));
session.setAttribute("savedFilm",id);response.sendRedirect("gdSuaPhim.jsp?id="+id);return;}
catch(IllegalArgumentException e){error=e.getMessage();}}
boolean saved=Integer.valueOf(id).equals(session.getAttribute("savedFilm"));session.removeAttribute("savedFilm");
title="Chỉnh sửa thông tin phim";
%><%@ include file="WEB-INF/header.jspf" %>
<% if(saved){ %><p class="notice" role="status">Sửa thông tin phim thành công.</p><% } %>
<form class="panel edit" method="post"><input type="hidden" name="token" value="<%=token%>"><input type="hidden" name="id" value="<%=id%>">
<label>Tên phim<input required maxlength="255" name="name" value="<%=h(name)%>"></label>
<% if(error.startsWith("Tên phim")){ %><p role="alert"><%=h(error)%></p><% } %>
<label>Thể loại<input required maxlength="100" name="genre" value="<%=h(genre)%>"></label>
<% if(error.startsWith("Thể loại")){ %><p role="alert"><%=h(error)%></p><% } %>
<label>Thời lượng (phút)<input required type="number" min="1" name="minutes" value="<%=h(minutes)%>"></label>
<% if(error.startsWith("Thời lượng")){ %><p role="alert"><%=h(error)%></p><% } %>
<label>Mô tả<textarea rows="4" name="description"><%=h(description)%></textarea></label>
<% if(!error.isEmpty() && !error.startsWith("Tên phim") && !error.startsWith("Thể loại") && !error.startsWith("Thời lượng")){ %><p role="alert"><%=h(error)%></p><% } %>
<button>Lưu thay đổi</button> <a href="gdTimPhim.jsp">Quay lại</a></form><%@ include file="WEB-INF/footer.jspf" %>

<%@ include file="WEB-INF/base.jspf" %><%
if(post){
    member=new ThanhVienDAO().login(val(request.getParameter("user")),request.getParameter("password"));
    if(member!=null){request.changeSessionId();session.setAttribute("member",member);session.removeAttribute("token");}
    else error="Tên đăng nhập hoặc mật khẩu không đúng.";
}
if(member!=null){response.sendRedirect(member.role().equals("QL")?"gdTimPhim.jsp":"gdChonSuatChieu.jsp");return;}
title="Đăng nhập";
%><%@ include file="WEB-INF/header.jspf" %>
<form class="panel narrow" method="post"><input type="hidden" name="token" value="<%=token%>">
<label>Tên đăng nhập<input required name="user" autofocus autocomplete="username" value="<%=h(request.getParameter("user"))%>"></label>
<label>Mật khẩu<input type="password" name="password" required autocomplete="current-password"></label>
<% if(!error.isEmpty()){ %><p role="alert"><%=h(error)%></p><% } %><button>Đăng nhập</button></form>
<%@ include file="WEB-INF/footer.jspf" %>

<%@ include file="WEB-INF/base.jspf" %><% if(!post){response.sendError(405);return;} session.invalidate();response.sendRedirect("index.jsp"); %>

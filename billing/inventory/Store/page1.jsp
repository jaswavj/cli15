<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String name = request.getParameter("name");
String code = request.getParameter("code");
String address = request.getParameter("address");

if (name == null || name.trim().length() == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+name+is+required&type=danger");
    return;
}

if (code == null || code.trim().length() == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+code+is+required&type=danger");
    return;
}

try {
    int existingName = inv.checkInvStoreNameExist(name.trim());
    if (existingName != 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+name+already+exists&type=warning");
        return;
    }

    int existingCode = inv.checkInvStoreCodeExist(code.trim());
    if (existingCode != 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+code+already+exists&type=warning");
        return;
    }

    inv.addInvStore(name.trim(), code.trim(), address);
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+added+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

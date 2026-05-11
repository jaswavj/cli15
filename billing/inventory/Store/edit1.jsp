<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
int id = Integer.parseInt(request.getParameter("id"));
String name = request.getParameter("name");
String code = request.getParameter("code");
String address = request.getParameter("address");
String block = request.getParameter("block");

if (name == null || name.trim().length() == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+name+is+required&type=danger");
    return;
}

if (code == null || code.trim().length() == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+code+is+required&type=danger");
    return;
}

try {
    if (block != null) {
        inv.blockInvStore(id);
        response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+blocked+successfully&type=success");
        return;
    }

    int existingName = inv.checkInvStoreNameExistForEdit(name.trim(), id);
    if (existingName != 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+name+already+exists&type=warning");
        return;
    }

    int existingCode = inv.checkInvStoreCodeExistForEdit(code.trim(), id);
    if (existingCode != 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+code+already+exists&type=warning");
        return;
    }

    inv.editInvStore(id, name.trim(), code.trim(), address);
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=Store+updated+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Store/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

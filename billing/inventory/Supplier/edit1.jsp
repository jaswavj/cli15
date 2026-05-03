<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
int id = Integer.parseInt(request.getParameter("id"));
String name = request.getParameter("name");
String phoneNumber = request.getParameter("phoneNumber");
String description = request.getParameter("description");
String gstin = request.getParameter("gstin");
String isGstParam = request.getParameter("isGst");
int isGst = (isGstParam != null && isGstParam.equals("on")) ? 1 : 0;
String block = request.getParameter("block");

try {
    if (block != null) {
        inv.blockInvSupplier(id);
        response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=Supplier+blocked+successfully&type=success");
        return;
    }

    int existing = inv.checkInvSupplierNameExistForEdit(name.trim(), id);
    if (existing != 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=Supplier+name+already+exists&type=warning");
        return;
    }

    inv.editInvSupplier(id, name.trim(), phoneNumber, description, gstin, isGst);
    response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=Supplier+updated+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

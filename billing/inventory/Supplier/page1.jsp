<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String name = request.getParameter("name");
String description = request.getParameter("description");
String phoneNumber = request.getParameter("phoneNumber");
String gstin = request.getParameter("gstin");
String isGstParam = request.getParameter("isGst");
int isGst = (isGstParam != null && isGstParam.equals("on")) ? 1 : 0;

if (name == null || name.trim().length() == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=Supplier+name+is+required&type=danger");
    return;
}

try {
    int existing = inv.checkInvSupplierNameExist(name.trim());
    if (existing != 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=Supplier+name+already+exists&type=warning");
        return;
    }

    inv.addInvSupplier(name.trim(), phoneNumber, description, gstin, isGst);
    response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=Supplier+added+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Supplier/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

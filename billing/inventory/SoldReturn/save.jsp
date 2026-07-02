<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
Integer uidObj = (Integer) session.getAttribute("userId");
if (uidObj == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
int returnUid = uidObj.intValue();

int id = 0;
String returnReason = null;

try {
    id = Integer.parseInt(request.getParameter("id"));
    returnReason = request.getParameter("returnReason");

    if (returnReason == null || returnReason.trim().length() == 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/SoldReturn/page.jsp?msg=Reason+for+return+is+required&type=danger");
        return;
    }

    inv.returnSoldBike(id, returnReason.trim(), returnUid);
    response.sendRedirect(request.getContextPath() + "/inventory/SoldReturn/page.jsp?msg=Bike+returned+successfully&type=success");

} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/SoldReturn/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

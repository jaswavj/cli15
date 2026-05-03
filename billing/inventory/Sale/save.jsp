<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
Integer uidObj = (Integer) session.getAttribute("userId");
if (uidObj == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
int soldUid = uidObj.intValue();

int id = 0;
double saleAmount = 0;
String soldDate = null;
String saleRemark = null;

try {
    id = Integer.parseInt(request.getParameter("id"));
    String saleAmountStr = request.getParameter("saleAmount");
    soldDate = request.getParameter("soldDate");
    saleRemark = request.getParameter("saleRemark");

    if (saleAmountStr == null || saleAmountStr.trim().length() == 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Sale/page.jsp?msg=Sale+amount+is+required&type=danger");
        return;
    }
    if (soldDate == null || soldDate.trim().length() == 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Sale/page.jsp?msg=Sold+date+is+required&type=danger");
        return;
    }

    saleAmount = Double.parseDouble(saleAmountStr.trim());

    inv.markAsSold(id, saleAmount, soldDate, saleRemark, soldUid);
    response.sendRedirect(request.getContextPath() + "/inventory/Sale/page.jsp?msg=Bike+marked+as+sold+successfully&type=success");

} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Sale/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

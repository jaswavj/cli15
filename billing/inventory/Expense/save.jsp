<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
Integer uidObj = (Integer) session.getAttribute("userId");
if (uidObj == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
int uid = uidObj.intValue();

try {
    String bikeIdStr = request.getParameter("bikeId");
    String content   = request.getParameter("content");
    String amountStr = request.getParameter("amount");
    String description = request.getParameter("description");
    String excDate   = request.getParameter("excDate");

    if (bikeIdStr == null || bikeIdStr.trim().length() == 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Expense/page.jsp?msg=Invalid+bike&type=danger");
        return;
    }
    if (content == null || content.trim().length() == 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Expense/page.jsp?msg=Expense+name+is+required&type=danger&openBikeId=" + bikeIdStr);
        return;
    }
    if (amountStr == null || amountStr.trim().length() == 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Expense/page.jsp?msg=Cost+is+required&type=danger&openBikeId=" + bikeIdStr);
        return;
    }
    if (excDate == null || excDate.trim().length() == 0) {
        response.sendRedirect(request.getContextPath() + "/inventory/Expense/page.jsp?msg=Date+is+required&type=danger&openBikeId=" + bikeIdStr);
        return;
    }

    int bikeId = Integer.parseInt(bikeIdStr.trim());
    double amount = Double.parseDouble(amountStr.trim());
    String excDateTime = excDate.trim() + " 00:00:00";

    inv.addExpenseEntry(bikeId, content.trim(), amount,
        (description != null ? description.trim() : ""), excDateTime, uid);

    response.sendRedirect(request.getContextPath() + "/inventory/Expense/page.jsp?msg=Expense+added+successfully&type=success&openBikeId=" + bikeId);

} catch (Exception e) {
    String bikeIdFb = request.getParameter("bikeId");
    String redirect = request.getContextPath() + "/inventory/Expense/page.jsp?msg="
        + java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Error", "UTF-8") + "&type=danger";
    if (bikeIdFb != null && bikeIdFb.trim().length() > 0) {
        redirect += "&openBikeId=" + bikeIdFb.trim();
    }
    response.sendRedirect(redirect);
}
%>

<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
try {
    int id = Integer.parseInt(request.getParameter("id"));
    String invDate = request.getParameter("invDate");
    int supplierId = Integer.parseInt(request.getParameter("supplierId"));
    int fileId = Integer.parseInt(request.getParameter("fileId"));
    String productName = request.getParameter("productName");
    String vehicleNumber = request.getParameter("vehicleNumber");
    int isRc = Integer.parseInt(request.getParameter("isRc"));
    String modelYear = request.getParameter("modelYear");
    String purchaseCostStr = request.getParameter("purchaseCost");
    String purchaseRemark = request.getParameter("purchaseRemark");

    double purchaseCost = 0;
    if (purchaseCostStr != null && purchaseCostStr.trim().length() > 0) {
        purchaseCost = Double.parseDouble(purchaseCostStr);
    }

    inv.editInventoryPurchase(id, invDate, supplierId, fileId, productName, vehicleNumber, isRc, modelYear, purchaseCost, purchaseRemark);
    response.sendRedirect(request.getContextPath() + "/inventory/Purchase/page.jsp?msg=Purchase+updated+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Purchase/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

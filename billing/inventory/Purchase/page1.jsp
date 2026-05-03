<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
Integer uidObj = (Integer) session.getAttribute("userId");
if (uidObj == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
int uid = uidObj.intValue();

String invDate = request.getParameter("invDate");
String supplierIdStr = request.getParameter("supplierId");
String purchaseRemark = request.getParameter("purchaseRemark");

String[] fileIds = request.getParameterValues("fileId[]");
String[] productNames = request.getParameterValues("productName[]");
String[] vehicleNumbers = request.getParameterValues("vehicleNumber[]");
String[] isRcValues = request.getParameterValues("isRc[]");
String[] modelYears = request.getParameterValues("modelYear[]");
String[] purchaseCosts = request.getParameterValues("purchaseCost[]");

if (invDate == null || invDate.trim().length() == 0 || supplierIdStr == null || supplierIdStr.trim().length() == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Purchase/page.jsp?msg=Invoice+date+and+supplier+are+required&type=danger");
    return;
}

if (fileIds == null || fileIds.length == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Purchase/page.jsp?msg=At+least+one+product+row+is+required&type=danger");
    return;
}

try {
    int supplierId = Integer.parseInt(supplierIdStr);
    inv.addInventoryPurchaseItems(invDate, supplierId, purchaseRemark, uid, fileIds, productNames, vehicleNumbers, isRcValues, modelYears, purchaseCosts);
    response.sendRedirect(request.getContextPath() + "/inventory/Purchase/page.jsp?msg=Purchase+saved+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Purchase/page.jsp?msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

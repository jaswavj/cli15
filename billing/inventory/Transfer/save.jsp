<%@page language="java" import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
Integer uidObj = (Integer) session.getAttribute("userId");
if (uidObj == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
int uid = uidObj.intValue();

int bikeId = 0;
int fromStoreId = 0;
int toStoreId = 0;
String remark = request.getParameter("remark");

try {
    bikeId = Integer.parseInt(request.getParameter("bikeId"));
    fromStoreId = Integer.parseInt(request.getParameter("fromStoreId"));
    toStoreId = Integer.parseInt(request.getParameter("toStoreId"));

    inv.transferUnsoldBikeStore(bikeId, fromStoreId, toStoreId, remark, uid);
    response.sendRedirect(request.getContextPath() + "/inventory/Transfer/page.jsp?fromStoreId=" + fromStoreId + "&msg=Bike+transferred+successfully&type=success");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/inventory/Transfer/page.jsp?fromStoreId=" + fromStoreId + "&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>

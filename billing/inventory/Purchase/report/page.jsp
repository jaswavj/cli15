<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
Vector suppliers = new Vector();
String setupError = null;
try {
    suppliers = inv.getActiveInvSuppliers();
} catch (Exception e) {
    setupError = e.getMessage();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory Purchase Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3 class="mb-4">Bike Inventory Purchase Report</h3>

        <% if (setupError != null) { %>
        <div class="alert alert-danger" role="alert">
            Unable to load suppliers: <%= setupError %>
        </div>
        <% } %>

        <form action="<%=contextPath%>/inventory/Purchase/report/page0.jsp" method="get" class="row g-3">
            <div class="col-md-3">
                <label class="form-label">From Date</label>
                <input type="date" name="fromDate" value="<%=today%>" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">To Date</label>
                <input type="date" name="toDate" value="<%=today%>" class="form-control" required>
            </div>
            <div class="col-md-4">
                <label class="form-label">Supplier (Optional)</label>
                <select name="supplierId" class="form-select">
                    <option value="0">All Suppliers</option>
                    <% for (int i = 0; i < suppliers.size(); i++) {
                        Vector row = (Vector) suppliers.get(i);
                    %>
                        <option value="<%=row.elementAt(0)%>"><%=row.elementAt(1)%></option>
                    <% } %>
                </select>
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100">Generate</button>
            </div>
        </form>
    </div>
</body>
</html>

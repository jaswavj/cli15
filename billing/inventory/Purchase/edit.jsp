<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
int id = Integer.parseInt(request.getParameter("id"));
Vector purchase = inv.getInventoryPurchaseById(id);
if (purchase == null || purchase.size() == 0) {
    response.sendRedirect(request.getContextPath() + "/inventory/Purchase/page.jsp?msg=Record+not+found&type=warning");
    return;
}
Vector suppliers = inv.getActiveInvSuppliers();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Bike Inventory Purchase</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3>Edit Purchase Row</h3>
        <div class="card">
            <div class="card-body">
                <form action="<%=contextPath%>/inventory/Purchase/edit1.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=purchase.elementAt(0)%>">

                    <div class="col-md-4 input-outline">
                        <input type="date" name="invDate" class="form-control" value="<%=purchase.elementAt(1)%>" required>
                        <label>Invoice Date</label>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Supplier</label>
                        <select name="supplierId" class="form-select" required>
                            <option value="">Select Supplier</option>
                            <%
                            String selectedSupplierId = purchase.elementAt(2).toString();
                            for (int i = 0; i < suppliers.size(); i++) {
                                Vector row = (Vector) suppliers.get(i);
                                String supplierId = row.elementAt(0).toString();
                            %>
                                <option value="<%=supplierId%>" <%= supplierId.equals(selectedSupplierId) ? "selected" : "" %>><%=row.elementAt(1)%></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="col-md-4 input-outline">
                        <input type="number" name="fileId" class="form-control" value="<%=purchase.elementAt(3)%>" required>
                        <label>File No</label>
                    </div>

                    <div class="col-md-4 input-outline">
                        <input type="text" name="productName" class="form-control" value="<%=purchase.elementAt(4)%>" required>
                        <label>Product Name</label>
                    </div>

                    <div class="col-md-4 input-outline">
                        <input type="text" name="vehicleNumber" class="form-control" value="<%=purchase.elementAt(5)%>" required>
                        <label>Vehicle Number</label>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">RC</label>
                        <select name="isRc" class="form-select">
                            <option value="1" <%= "1".equals(purchase.elementAt(6).toString()) ? "selected" : "" %>>Yes</option>
                            <option value="0" <%= "0".equals(purchase.elementAt(6).toString()) ? "selected" : "" %>>No</option>
                        </select>
                    </div>

                    <div class="col-md-4 input-outline">
                        <input type="text" name="modelYear" class="form-control" value="<%=purchase.elementAt(7)%>">
                        <label>Model Year</label>
                    </div>

                    <div class="col-md-4 input-outline">
                        <input type="number" step="0.001" name="purchaseCost" class="form-control" value="<%=purchase.elementAt(8)%>">
                        <label>Purchase Cost</label>
                    </div>

                    <div class="col-md-12 input-outline">
                        <input type="text" name="purchaseRemark" class="form-control" value="<%=purchase.elementAt(9)%>">
                        <label>Purchase Remark</label>
                    </div>

                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Update</button>
                        <a href="<%=contextPath%>/inventory/Purchase/page.jsp" class="btn btn-secondary">Back</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>

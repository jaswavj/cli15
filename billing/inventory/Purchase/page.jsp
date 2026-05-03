<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
Vector suppliers = new Vector();
Vector purchases = new Vector();
String setupError = null;
try {
    suppliers = inv.getActiveInvSuppliers();
    purchases = inv.getInventoryPurchases();
} catch (Exception e) {
    setupError = e.getMessage();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory Purchase</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table-input { min-width: 140px; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4 mb-4">
        <h3>Bike Inventory Purchase</h3>

        <% if (msg != null) { %>
        <div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show" role="alert">
            <%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <% if (setupError != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            Bike Inventory setup is incomplete. Please run setup SQL and refresh this page.<br>
            <small><%= setupError %></small>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/inventory/Purchase/page1.jsp" method="post" id="purchaseForm">
                    <div class="row g-3 mb-3">
                        <div class="col-md-4 input-outline">
                            <input type="date" name="invDate" class="form-control" required>
                            <label>Invoice Date</label>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Supplier</label>
                            <select name="supplierId" class="form-select" required>
                                <option value="">Select Supplier</option>
                                <% for (int i = 0; i < suppliers.size(); i++) {
                                    Vector row = (Vector) suppliers.get(i);
                                %>
                                    <option value="<%=row.elementAt(0)%>"><%=row.elementAt(1)%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-4 input-outline">
                            <input type="text" name="purchaseRemark" class="form-control">
                            <label>Purchase Remark</label>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-bordered" id="itemTable">
                            <thead>
                                <tr>
                                    <th>File No</th>
                                    <th>Product Name</th>
                                    <th>Vehicle Number</th>
                                    <th>RC</th>
                                    <th>Model Year</th>
                                    <th>Purchase Cost</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><input type="number" name="fileId[]" class="form-control table-input" required></td>
                                    <td><input type="text" name="productName[]" class="form-control table-input" required></td>
                                    <td><input type="text" name="vehicleNumber[]" class="form-control table-input" required></td>
                                    <td>
                                        <select name="isRc[]" class="form-select table-input">
                                            <option value="1">Yes</option>
                                            <option value="0" selected>No</option>
                                        </select>
                                    </td>
                                    <td><input type="text" name="modelYear[]" class="form-control table-input" placeholder="e.g. 2024"></td>
                                    <td><input type="number" step="0.001" name="purchaseCost[]" class="form-control table-input" value="0"></td>
                                    <td><button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">Remove</button></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-secondary" onclick="addRow()">Add More Product</button>
                        <button type="submit" class="btn btn-primary">Save Purchase</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <h5>Purchase List</h5>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Invoice Date</th>
                                <th>Supplier</th>
                                <th>File No</th>
                                <th>Product Name</th>
                                <th>Vehicle Number</th>
                                <th>RC</th>
                                <th>Model Year</th>
                                <th>Cost</th>
                                <th>Remark</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        for (int i = 0; i < purchases.size(); i++) {
                            Vector row = (Vector) purchases.get(i);
                            int id = Integer.parseInt(row.elementAt(0).toString());
                            int isRc = Integer.parseInt(row.elementAt(6).toString());
                        %>
                            <tr>
                                <td><%= i + 1 %></td>
                                <td><%= row.elementAt(1) %></td>
                                <td><%= row.elementAt(2) %></td>
                                <td><%= row.elementAt(3) %></td>
                                <td><%= row.elementAt(4) %></td>
                                <td><%= row.elementAt(5) %></td>
                                <td><%= isRc == 1 ? "Yes" : "No" %></td>
                                <td><%= row.elementAt(7) %></td>
                                <td><%= row.elementAt(8) %></td>
                                <td><%= row.elementAt(9) %></td>
                                <td>
                                    <a href="<%=contextPath%>/inventory/Purchase/edit.jsp?id=<%=id%>" class="btn btn-warning btn-sm">Edit</a>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        window.addRow = function() {
            var tbody = document.querySelector('#itemTable tbody');
            var tr = document.createElement('tr');
            tr.innerHTML = ''
                + '<td><input type="number" name="fileId[]" class="form-control table-input" required></td>'
                + '<td><input type="text" name="productName[]" class="form-control table-input" required></td>'
                + '<td><input type="text" name="vehicleNumber[]" class="form-control table-input" required></td>'
                + '<td><select name="isRc[]" class="form-select table-input"><option value="1">Yes</option><option value="0" selected>No</option></select></td>'
                + '<td><input type="text" name="modelYear[]" class="form-control table-input" placeholder="e.g. 2024"></td>'
                + '<td><input type="number" step="0.001" name="purchaseCost[]" class="form-control table-input" value="0"></td>'
                + '<td><button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">Remove</button></td>';
            tbody.appendChild(tr);
        };

        window.removeRow = function(btn) {
            var tbody = document.querySelector('#itemTable tbody');
            if (tbody.rows.length === 1) {
                return;
            }
            btn.closest('tr').remove();
        };
    </script>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
Vector unsoldList = new Vector();
Vector stores = new Vector();
String loadError = null;
try {
    unsoldList = inv.getUnsoldInventory();
    stores = inv.getActiveInvStores();
} catch (Exception e) {
    loadError = e.getMessage();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory - Sold Entry</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4 mb-4">
        <h3>Sold Entry</h3>

        <% if (msg != null) { %>
        <div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show" role="alert">
            <%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <% if (loadError != null) { %>
        <div class="alert alert-danger">Error loading data: <%=loadError%></div>
        <% } %>

        <div class="card">
            <div class="card-body">
                <div class="row align-items-center mb-3">
                    <div class="col-md-4">
                        <h5 class="mb-0">Unsold Bikes (<span class="text-primary" id="filteredCount"><%=unsoldList.size()%></span> of <%=unsoldList.size()%>)</h5>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small mb-1">Filter by Store</label>
                        <select id="storeFilter" class="form-select form-select-sm" onchange="filterRows()">
                            <option value="">All Stores</option>
                            <% for (int i = 0; i < stores.size(); i++) {
                                Vector row = (Vector) stores.get(i);
                            %>
                                <option value="<%=row.elementAt(0)%>"><%=row.elementAt(1)%> (<%=row.elementAt(2)%>)</option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label small mb-1">Search</label>
                        <input type="text" id="filterInput" class="form-control form-control-sm" placeholder="Product or vehicle..." oninput="filterRows()">
                    </div>
                </div>
                <div class="table-responsive">
                    <table id="unsoldTable" class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Store</th>
                                <th>Invoice Date</th>
                                <th>Supplier</th>
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
                        <%
                        if (unsoldList.size() == 0 && loadError == null) {
                        %>
                            <tr>
                                <td colspan="11" class="text-center text-muted py-3">No unsold bikes found.</td>
                            </tr>
                        <%
                        }
                        for (int i = 0; i < unsoldList.size(); i++) {
                            Vector row = (Vector) unsoldList.get(i);
                            int id = Integer.parseInt(row.elementAt(0).toString());
                            String storeId = row.elementAt(9).toString();
                        %>
                            <tr data-product="<%=row.elementAt(4).toString().toLowerCase()%>" data-vehicle="<%=row.elementAt(5).toString().toLowerCase()%>" data-store="<%=storeId%>">
                                <td class="row-num"><%=i + 1%></td>
                                <td><%=row.elementAt(10)%></td>
                                <td><%=row.elementAt(1)%></td>
                                <td><%=row.elementAt(2)%></td>
                                <td><%=row.elementAt(3)%></td>
                                <td><%=row.elementAt(4)%></td>
                                <td><%=row.elementAt(5)%></td>
                                <td><%= "1".equals(row.elementAt(6).toString()) ? "Yes" : "No" %></td>
                                <td><%=row.elementAt(7)%></td>
                                <td><%=String.format("%.3f", Double.parseDouble(row.elementAt(8).toString()))%></td>
                                <td>
                                    <button type="button" class="btn btn-success btn-sm"
                                        onclick="openSellModal(<%=id%>, '<%=row.elementAt(4).toString().replace("'","\\\'")%>', '<%=row.elementAt(5)%>')">
                                        Mark as Sold
                                    </button>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Sell Modal -->
    <div class="modal fade" id="sellModal" tabindex="-1" aria-labelledby="sellModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="sellModalLabel">Mark as Sold</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="<%=contextPath%>/inventory/Sale/save.jsp" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="id" id="sellId">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Product</label>
                            <div id="sellProductInfo" class="form-control-plaintext"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Sale Amount <span class="text-danger">*</span></label>
                            <input type="number" step="0.001" name="saleAmount" class="form-control" required min="0">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Sold Date <span class="text-danger">*</span></label>
                            <input type="date" name="soldDate" id="soldDate" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Remark</label>
                            <textarea name="saleRemark" class="form-control" rows="2" placeholder="Optional remark"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success">Confirm Sale</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
    window.filterRows = function() {
        var keyword = document.getElementById('filterInput').value.toLowerCase().trim();
        var storeId = document.getElementById('storeFilter').value;
        var rows = document.querySelectorAll('#unsoldTable tbody tr[data-product]');
        var visibleCount = 0;
        var num = 0;
        rows.forEach(function(row) {
            var product = row.getAttribute('data-product') || '';
            var vehicle = row.getAttribute('data-vehicle') || '';
            var rowStore = row.getAttribute('data-store') || '';
            var keywordMatch = !keyword || product.indexOf(keyword) !== -1 || vehicle.indexOf(keyword) !== -1;
            var storeMatch = !storeId || rowStore === storeId;
            if (keywordMatch && storeMatch) {
                row.style.display = '';
                num++;
                var numCell = row.querySelector('.row-num');
                if (numCell) numCell.textContent = num;
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });
        document.getElementById('filteredCount').textContent = visibleCount;
    };

    window.openSellModal = function(id, productName, vehicleNumber) {
        document.getElementById('sellId').value = id;
        document.getElementById('sellProductInfo').textContent = productName + '  |  ' + vehicleNumber;

        var today = new Date();
        var yyyy = today.getFullYear();
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var dd = String(today.getDate()).padStart(2, '0');
        document.getElementById('soldDate').value = yyyy + '-' + mm + '-' + dd;

        var modal = new bootstrap.Modal(document.getElementById('sellModal'));
        modal.show();
    };
    </script>
</body>
</html>

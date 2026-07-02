<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
Vector soldList = new Vector();
Vector stores = new Vector();
String loadError = null;
try {
    soldList = inv.getSoldInventory();
    stores = inv.getActiveInvStores();
} catch (Exception e) {
    loadError = e.getMessage();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory - Sold Return</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4 mb-4">
        <h3>Sold Return</h3>

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
                        <h5 class="mb-0">Sold Bikes (<span class="text-primary" id="filteredCount"><%=soldList.size()%></span> of <%=soldList.size()%>)</h5>
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
                    <table id="soldTable" class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Action</th>
                                <th>Store</th>
                                <th>Invoice Date</th>
                                <th>Supplier</th>
                                <th>File No</th>
                                <th>Product Name</th>
                                <th>Vehicle Number</th>
                                <th>RC</th>
                                <th>NOC</th>
                                <th>Model Year</th>
                                <th>Purchase Cost</th>
                                <th>Sale Amount</th>
                                <th>Sold Date</th>
                                <th>Sale Remark</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        if (soldList.size() == 0 && loadError == null) {
                        %>
                            <tr>
                                <td colspan="15" class="text-center text-muted py-3">No sold bikes found.</td>
                            </tr>
                        <%
                        }
                        for (int i = 0; i < soldList.size(); i++) {
                            Vector row = (Vector) soldList.get(i);
                            int id = Integer.parseInt(row.elementAt(0).toString());
                            String storeId = row.elementAt(9).toString();
                            String productName = row.elementAt(4).toString();
                            String vehicleNumber = row.elementAt(5).toString();
                            String saleAmount = row.elementAt(12).toString();
                            String soldDate = row.elementAt(13).toString();
                            String saleRemark = row.elementAt(14).toString();
                        %>
                            <tr data-product="<%=productName.toLowerCase()%>" data-vehicle="<%=vehicleNumber.toLowerCase()%>" data-store="<%=storeId%>">
                                <td class="row-num"><%=i + 1%></td>
                                <td>
                                    <button type="button" class="btn btn-danger btn-sm btn-return"
                                        data-id="<%=id%>"
                                        data-product="<%=productName.replace("\"", "&quot;")%>"
                                        data-vehicle="<%=vehicleNumber%>"
                                        data-sale-amount="<%=saleAmount%>"
                                        data-sold-date="<%=soldDate%>"
                                        data-sale-remark="<%=saleRemark.replace("\"", "&quot;")%>">
                                        Return
                                    </button>
                                </td>
                                <td><%=row.elementAt(10)%></td>
                                <td><%=row.elementAt(1)%></td>
                                <td><%=row.elementAt(2)%></td>
                                <td><%=row.elementAt(3)%></td>
                                <td><%=productName%></td>
                                <td><%=vehicleNumber%></td>
                                <td><%= "1".equals(row.elementAt(6).toString()) ? "Yes" : "No" %></td>
                                <td><%= "1".equals(row.elementAt(11).toString()) ? "Yes" : "No" %></td>
                                <td><%=row.elementAt(7)%></td>
                                <td><%=String.format("%.3f", Double.parseDouble(row.elementAt(8).toString()))%></td>
                                <td><%=String.format("%.3f", Double.parseDouble(saleAmount))%></td>
                                <td><%=soldDate%></td>
                                <td><%=saleRemark%></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Return Modal -->
    <div class="modal fade" id="returnModal" tabindex="-1" aria-labelledby="returnModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="returnModalLabel">Sold Return</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="<%=contextPath%>/inventory/SoldReturn/save.jsp" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="id" id="returnId">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Bike</label>
                            <div id="returnProductInfo" class="form-control-plaintext"></div>
                        </div>
                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label text-muted small">Old Sale Amount</label>
                                <div id="returnSaleAmount" class="fw-bold text-success"></div>
                            </div>
                            <div class="col-6">
                                <label class="form-label text-muted small">Old Sold Date</label>
                                <div id="returnSoldDate" class="fw-bold"></div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small">Old Sale Remark</label>
                            <div id="returnSaleRemark" class="text-muted small"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Reason for Return <span class="text-danger">*</span></label>
                            <textarea name="returnReason" id="returnReason" class="form-control" rows="3" placeholder="Enter reason for return" required></textarea>
                        </div>
                        <div class="alert alert-warning small mb-0">
                            This will mark the bike as unsold and clear all sale details.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger">Confirm Return</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
    window.filterRows = function() {
        var keyword = document.getElementById('filterInput').value.toLowerCase().trim();
        var storeId = document.getElementById('storeFilter').value;
        var rows = document.querySelectorAll('#soldTable tbody tr[data-product]');
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

    window.openReturnModal = function(id, productName, vehicleNumber, saleAmount, soldDate, saleRemark) {
        document.getElementById('returnId').value = id;
        document.getElementById('returnProductInfo').textContent = productName + '  |  ' + vehicleNumber;
        document.getElementById('returnSaleAmount').textContent = parseFloat(saleAmount).toFixed(3);
        document.getElementById('returnSoldDate').textContent = soldDate;
        document.getElementById('returnSaleRemark').textContent = saleRemark && saleRemark !== '-' ? saleRemark : '-';
        document.getElementById('returnReason').value = '';

        var modal = new bootstrap.Modal(document.getElementById('returnModal'));
        modal.show();
    };

    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-return');
        if (!btn) return;
        openReturnModal(
            btn.getAttribute('data-id'),
            btn.getAttribute('data-product'),
            btn.getAttribute('data-vehicle'),
            btn.getAttribute('data-sale-amount'),
            btn.getAttribute('data-sold-date'),
            btn.getAttribute('data-sale-remark')
        );
    });
    </script>
</body>
</html>

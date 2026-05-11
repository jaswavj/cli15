<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
String openBikeId = request.getParameter("openBikeId");

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
    <title>Bike Expense Entry</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
    <script>var contextPath = '<%=contextPath%>';</script>

    <div class="container mt-4 mb-4">
        <h3>Bike Expense Entry</h3>

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
                        <input type="text" id="filterInput" class="form-control form-control-sm"
                            placeholder="Search by product or vehicle..."
                            oninput="filterRows()">
                    </div>
                </div>
                <div class="table-responsive">
                    <table id="bikeTable" class="table table-hover mb-0">
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
                            int bikeId = Integer.parseInt(row.elementAt(0).toString());
                            String productName = row.elementAt(4).toString();
                            String vehicleNumber = row.elementAt(5).toString();
                            String storeId = row.elementAt(9).toString();
                        %>
                            <tr data-product="<%=productName.toLowerCase()%>" data-vehicle="<%=vehicleNumber.toLowerCase()%>" data-store="<%=storeId%>">
                                <td class="row-num"><%=i + 1%></td>
                                <td><%=row.elementAt(10)%></td>
                                <td><%=row.elementAt(1)%></td>
                                <td><%=row.elementAt(2)%></td>
                                <td><%=row.elementAt(3)%></td>
                                <td><%=productName%></td>
                                <td><%=vehicleNumber%></td>
                                <td><%= "1".equals(row.elementAt(6).toString()) ? "Yes" : "No" %></td>
                                <td><%=row.elementAt(7)%></td>
                                <td><%=String.format("%.3f", Double.parseDouble(row.elementAt(8).toString()))%></td>
                                <td>
                                    <button type="button" class="btn btn-warning btn-sm"
                                        data-bike-id="<%=bikeId%>"
                                        data-product="<%=productName.replace("'", "\\'")%>"
                                        data-vehicle="<%=vehicleNumber%>"
                                        onclick="openExpenseModal(<%=bikeId%>, '<%=productName.replace("'","\\'")%>', '<%=vehicleNumber%>')">
                                        <i class="fas fa-plus-circle"></i> Expense
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

    <!-- Expense Entry Modal -->
    <div class="modal fade" id="expenseModal" tabindex="-1" aria-labelledby="expenseModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="expenseModalLabel">
                        <i class="fas fa-receipt"></i> Expense Entry
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="<%=contextPath%>/inventory/Expense/save.jsp" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="bikeId" id="expBikeId">
                        <div class="mb-3 p-2 bg-light rounded">
                            <strong>Bike:</strong> <span id="expBikeName" class="text-primary"></span>
                        </div>

                        <div class="row g-2 mb-2">
                            <div class="col-md-6">
                                <label class="form-label">Expense Name <span class="text-danger">*</span></label>
                                <input type="text" name="content" class="form-control" placeholder="e.g. Oil Change, Insurance" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date <span class="text-danger">*</span></label>
                                <input type="date" name="excDate" id="expExcDate" class="form-control" required>
                            </div>
                        </div>
                        <div class="row g-2 mb-3">
                            <div class="col-md-4">
                                <label class="form-label">Cost <span class="text-danger">*</span></label>
                                <input type="number" step="0.01" name="amount" class="form-control" placeholder="0.00" required min="0">
                            </div>
                            <div class="col-md-8">
                                <label class="form-label">Description</label>
                                <textarea name="description" class="form-control" rows="2" placeholder="Optional details"></textarea>
                            </div>
                        </div>

                        <hr>
                        <h6 class="mb-2"><i class="fas fa-list"></i> Previous Expenses for this Bike</h6>
                        <div id="expenseListContainer">
                            <div class="text-center text-muted py-2">
                                <div class="spinner-border spinner-border-sm" role="status"></div> Loading...
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-warning">
                            <i class="fas fa-save"></i> Add Expense
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
    window.filterRows = function() {
        var keyword = document.getElementById('filterInput').value.toLowerCase().trim();
        var storeId = document.getElementById('storeFilter').value;
        var rows = document.querySelectorAll('#bikeTable tbody tr[data-product]');
        var visible = 0, num = 0;
        rows.forEach(function(row) {
            var keywordMatch = !keyword ||
                (row.getAttribute('data-product') || '').indexOf(keyword) !== -1 ||
                (row.getAttribute('data-vehicle') || '').indexOf(keyword) !== -1;
            var rowStore = row.getAttribute('data-store') || '';
            var storeMatch = !storeId || rowStore === storeId;
            var match = keywordMatch && storeMatch;
            row.style.display = match ? '' : 'none';
            if (match) {
                num++;
                var cell = row.querySelector('.row-num');
                if (cell) cell.textContent = num;
                visible++;
            }
        });
        document.getElementById('filteredCount').textContent = visible;
    };

    window.openExpenseModal = function(bikeId, productName, vehicleNumber) {
        document.getElementById('expBikeId').value = bikeId;
        document.getElementById('expBikeName').textContent = productName + '  |  ' + vehicleNumber;

        var today = new Date();
        var yyyy = today.getFullYear();
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var dd = String(today.getDate()).padStart(2, '0');
        document.getElementById('expExcDate').value = yyyy + '-' + mm + '-' + dd;

        // Reset form fields
        var form = document.getElementById('expenseModal').querySelector('form');
        form.querySelector('[name="content"]').value = '';
        form.querySelector('[name="amount"]').value = '';
        form.querySelector('[name="description"]').value = '';

        // Load existing expenses
        loadExpenses(bikeId);

        var modal = new bootstrap.Modal(document.getElementById('expenseModal'));
        modal.show();
    };

    function loadExpenses(bikeId) {
        var container = document.getElementById('expenseListContainer');
        container.innerHTML = '<div class="text-center text-muted py-2"><div class="spinner-border spinner-border-sm" role="status"></div> Loading...</div>';
        fetch(contextPath + '/inventory/Expense/getExpenses.jsp?bikeId=' + bikeId)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || data.length === 0) {
                    container.innerHTML = '<p class="text-muted small mb-0">No expenses recorded yet.</p>';
                    return;
                }
                var total = 0;
                var html = '<div class="table-responsive"><table class="table table-sm table-bordered mb-0">';
                html += '<thead class="table-light"><tr><th>#</th><th>Expense Name</th><th>Date</th><th>Cost</th><th>Description</th></tr></thead><tbody>';
                data.forEach(function(e, i) {
                    total += parseFloat(e.amount) || 0;
                    html += '<tr>';
                    html += '<td>' + (i + 1) + '</td>';
                    html += '<td>' + escHtml(e.content) + '</td>';
                    html += '<td>' + escHtml(e.exc_date_time || '-') + '</td>';
                    html += '<td>' + parseFloat(e.amount).toFixed(3) + '</td>';
                    html += '<td>' + escHtml(e.description || '-') + '</td>';
                    html += '</tr>';
                });
                html += '</tbody>';
                html += '<tfoot><tr><td colspan="3" class="text-end fw-bold">Total</td>';
                html += '<td class="fw-bold text-success">' + total.toFixed(3) + '</td><td></td></tr></tfoot>';
                html += '</table></div>';
                container.innerHTML = html;
            })
            .catch(function() {
                container.innerHTML = '<p class="text-danger small mb-0">Failed to load expenses.</p>';
            });
    }

    function escHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    <% if (openBikeId != null && !openBikeId.trim().isEmpty()) { %>
    window.addEventListener('load', function() {
        var btn = document.querySelector('[data-bike-id="<%=openBikeId%>"]');
        if (btn) btn.click();
    });
    <% } %>
    </script>
</body>
</html>

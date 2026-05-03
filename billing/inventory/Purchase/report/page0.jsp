<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
int supplierId = 0;
if (request.getParameter("supplierId") != null && request.getParameter("supplierId").trim().length() > 0) {
    supplierId = Integer.parseInt(request.getParameter("supplierId"));
}

Vector reportRows = new Vector();
String reportError = null;
try {
    reportRows = inv.getInventoryPurchaseReport(fromDate, toDate, supplierId);
} catch (Exception e) {
    reportError = e.getMessage();
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
    <script>var contextPath = '<%=contextPath%>';</script>

    <div class="container mt-4 mb-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
            <h3 class="mb-0">Bike Inventory Purchase Report</h3>
            <a href="<%=contextPath%>/inventory/Purchase/report/page.jsp" class="btn btn-secondary">Back</a>
        </div>

        <div class="mb-3">
            <span class="badge bg-light text-dark border">From: <%=fromDate%></span>
            <span class="badge bg-light text-dark border">To: <%=toDate%></span>
            <span class="badge bg-info text-dark">Supplier Filter: <%= (supplierId > 0 ? "Selected" : "All Suppliers") %></span>
        </div>

        <% if (reportError != null) { %>
            <div class="alert alert-danger">Error: <%=reportError%></div>
        <% } %>

        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Date</th>
                        <th>Supplier</th>
                        <th>File No</th>
                        <th>Name</th>
                        <th>Number</th>
                        <th>RC</th>
                        <th>Year</th>
                        <th>Purchase Cost</th>
                        <th>Remark</th>
                        <th>Created At</th>
                        <th>Expense</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    double totalCost = 0;
                    double totalExpense = 0;
                    if (reportRows != null && reportRows.size() > 0) {
                        for (int i = 0; i < reportRows.size(); i++) {
                            Vector row = (Vector) reportRows.get(i);
                            double cost = Double.parseDouble(row.elementAt(8).toString());
                            double expenseTotal = Double.parseDouble(row.elementAt(11).toString());
                            totalCost += cost;
                            totalExpense += expenseTotal;
                            int bikeId = Integer.parseInt(row.elementAt(0).toString());
                            String expCssClass = expenseTotal > 0 ? "text-danger fw-bold" : "";
                            String safeProductName = row.elementAt(4).toString().replace("'", "\\'");
                    %>
                    <tr>
                        <td><%=i + 1%></td>
                        <td><%=row.elementAt(1)%></td>
                        <td><%=row.elementAt(2)%></td>
                        <td><%=row.elementAt(3)%></td>
                        <td><%=row.elementAt(4)%></td>
                        <td><%=row.elementAt(5)%></td>
                        <td><%= "1".equals(row.elementAt(6).toString()) ? "Yes" : "No" %></td>
                        <td><%=row.elementAt(7)%></td>
                        <td><%=String.format("%.3f", cost)%></td>
                        <td><%=row.elementAt(9)%></td>
                        <td><%=row.elementAt(10)%></td>
                        <td class="<%=expCssClass%>"><%=String.format("%.3f", expenseTotal)%></td>
                        <td>
                            <button type="button" class="btn btn-outline-info btn-sm"
                                onclick="viewExpenses(<%=bikeId%>, '<%=safeProductName%>')">
                                <i class="fas fa-eye"></i> View
                            </button>
                        </td>
                    </tr>
                    <%  }
                    } else { %>
                    <tr>
                        <td colspan="11" class="text-center">No records found for selected filters.</td>
                    </tr>
                    <% } %>
                </tbody>
                <tfoot>
                    <tr>
                        <th colspan="8" class="text-end">Total</th>
                        <th><%=String.format("%.3f", totalCost)%></th>
                        <th></th>
                        <th></th>
                        <th class="text-danger"><%=String.format("%.3f", totalExpense)%></th>
                        <th></th>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

    <!-- Expense View Modal -->
    <div class="modal fade" id="expViewModal" tabindex="-1" aria-labelledby="expViewModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="expViewModalLabel">Expenses for <span id="expViewBikeName" class="text-primary"></span></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="expViewContainer">
                        <div class="text-center py-3">
                            <div class="spinner-border spinner-border-sm" role="status"></div> Loading...
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script>
    window.viewExpenses = function(bikeId, bikeName) {
        document.getElementById('expViewBikeName').textContent = bikeName;
        var container = document.getElementById('expViewContainer');
        container.innerHTML = '<div class="text-center py-3"><div class="spinner-border spinner-border-sm" role="status"></div> Loading...</div>';
        new bootstrap.Modal(document.getElementById('expViewModal')).show();

        fetch(contextPath + '/inventory/Expense/getExpenses.jsp?bikeId=' + bikeId)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data || data.length === 0) {
                    container.innerHTML = '<p class="text-muted">No expenses recorded for this bike.</p>';
                    return;
                }
                var total = 0;
                var html = '<div class="table-responsive"><table class="table table-sm table-bordered mb-0">';
                html += '<thead class="table-light"><tr><th>#</th><th>Expense Name</th><th>Date</th><th>Cost</th><th>Description</th></tr></thead><tbody>';
                data.forEach(function(e, i) {
                    total += parseFloat(e.amount) || 0;
                    html += '<tr><td>' + (i+1) + '</td><td>' + escH(e.content) + '</td><td>' + escH(e.exc_date_time||'-') + '</td>';
                    html += '<td>' + parseFloat(e.amount).toFixed(3) + '</td><td>' + escH(e.description||'-') + '</td></tr>';
                });
                html += '</tbody><tfoot><tr><td colspan="3" class="text-end fw-bold">Total</td>';
                html += '<td class="fw-bold text-danger">' + total.toFixed(3) + '</td><td></td></tr></tfoot></table></div>';
                container.innerHTML = html;
            })
            .catch(function() {
                container.innerHTML = '<p class="text-danger">Failed to load expenses.</p>';
            });
    };
    function escH(s) {
        if (!s) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    </script>
</body>
</html>

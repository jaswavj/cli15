<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
int supplierId  = 0;
if (request.getParameter("supplierId") != null && request.getParameter("supplierId").trim().length() > 0) {
    supplierId = Integer.parseInt(request.getParameter("supplierId"));
}
int storeId = 0;
if (request.getParameter("storeId") != null && request.getParameter("storeId").trim().length() > 0) {
    storeId = Integer.parseInt(request.getParameter("storeId"));
}

Vector reportRows = new Vector();
String reportError = null;
try {
    reportRows = inv.getInventorySaleReport(fromDate, toDate, supplierId, storeId);
} catch (Exception e) {
    reportError = e.getMessage();
}

double totalPurchase = 0;
double totalExpense  = 0;
double totalSale     = 0;
double totalProfit   = 0;
if (reportRows != null && reportRows.size() > 0) {
    for (int i = 0; i < reportRows.size(); i++) {
        Vector row = (Vector) reportRows.get(i);
        double purchaseCost = Double.parseDouble(row.elementAt(10).toString());
        double expenseTotal = Double.parseDouble(row.elementAt(11).toString());
        double saleAmount   = Double.parseDouble(row.elementAt(12).toString());
        double profit       = saleAmount - purchaseCost - expenseTotal;
        totalPurchase += purchaseCost;
        totalExpense  += expenseTotal;
        totalSale     += saleAmount;
        totalProfit   += profit;
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory Sale Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
    @media print {
        .no-print { display: none !important; }
        body * { visibility: hidden; }
        #reportTable, #reportTable * { visibility: visible; }
        #reportTable { position: absolute; left: 0; top: 0; width: 100%; }
    }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
    <script>var contextPath = '<%=contextPath%>';</script>

    <div class="container mt-4 mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3 no-print">
            <h3 class="mb-0">Bike Inventory Sale Report</h3>
            <div class="d-flex gap-2">
                <a href="<%=contextPath%>/inventory/Sale/report/page.jsp" class="btn btn-secondary btn-sm">Back</a>
                <button class="btn btn-primary btn-sm" onclick="window.print()">Print</button>
                <button class="btn btn-success btn-sm" onclick="exportTableToExcel('reportTable','Sale_Report')">Export Excel</button>
            </div>
        </div>

        <div class="mb-3">
            <span class="badge bg-light text-dark border">From: <%=fromDate%></span>
            <span class="badge bg-light text-dark border">To: <%=toDate%></span>
            <span class="badge bg-info text-dark">Supplier: <%= supplierId > 0 ? "Selected" : "All" %></span>
            <span class="badge bg-secondary text-white">Store: <%= storeId > 0 ? "Selected" : "All" %></span>
        </div>

        <% if (reportError != null) { %>
        <div class="alert alert-danger">Error: <%=reportError%></div>
        <% } %>

        <div class="row g-3 mb-3">
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="text-muted small">Total Purchase</div>
                        <div class="fs-5 fw-bold text-primary"><%=String.format("%.3f", totalPurchase)%></div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="text-muted small">Total Expense</div>
                        <div class="fs-5 fw-bold text-danger"><%=String.format("%.3f", totalExpense)%></div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="text-muted small">Total Sale</div>
                        <div class="fs-5 fw-bold text-success"><%=String.format("%.3f", totalSale)%></div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="text-muted small">Profit</div>
                        <div class="fs-5 fw-bold <%= totalProfit >= 0 ? "text-success" : "text-danger" %>"><%=String.format("%.3f", totalProfit)%></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <table id="reportTable" class="table table-hover mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Invoice Date</th>
                        <th>Sold Date</th>
                        <th>Supplier</th>
                        <th>Store</th>
                        <th>File No</th>
                        <th>Product Name</th>
                        <th>Vehicle Number</th>
                        <th>RC</th>
                        <th>Model Year</th>
                        <th>Purchase Cost</th>
                        <th>Total Expense</th>
                        <th>Sale Amount</th>
                        <th>Profit</th>
                        <th>Remark</th>
                        <th>Sold Entry Time</th>
                    </tr>
                </thead>
                <tbody>
                <%
                if (reportRows != null && reportRows.size() > 0) {
                    for (int i = 0; i < reportRows.size(); i++) {
                        Vector row = (Vector) reportRows.get(i);
                        double purchaseCost = Double.parseDouble(row.elementAt(10).toString());
                        double expenseTotal = Double.parseDouble(row.elementAt(11).toString());
                        double saleAmount   = Double.parseDouble(row.elementAt(12).toString());
                        double profit       = saleAmount - purchaseCost - expenseTotal;
                        int bikeId = Integer.parseInt(row.elementAt(0).toString());
                %>
                <tr>
                    <td><%=i + 1%></td>
                    <td><%=row.elementAt(1)%></td>
                    <td><%=row.elementAt(2)%></td>
                    <td><%=row.elementAt(3)%></td>
                    <td><%=row.elementAt(4)%></td>
                    <td><%=row.elementAt(5)%></td>
                    <td><%=row.elementAt(6)%></td>
                    <td><%=row.elementAt(7)%></td>
                    <td><%= "1".equals(row.elementAt(8).toString()) ? "Yes" : "No" %></td>
                    <td><%=row.elementAt(9)%></td>
                    <td><%=String.format("%.3f", purchaseCost)%></td>
                    <td class="<%=expenseTotal > 0 ? "text-danger fw-bold" : ""%>">
                        <%=String.format("%.3f", expenseTotal)%>
                        <button type="button" class="btn btn-outline-info btn-sm ms-1 btn-exp-details" data-bike-id="<%=bikeId%>">
                            <i class="fas fa-eye"></i>
                        </button>
                    </td>
                    <td><%=String.format("%.3f", saleAmount)%></td>
                    <td class="<%= profit >= 0 ? "text-success" : "text-danger" %> fw-bold"><%=String.format("%.3f", profit)%></td>
                    <td><%=row.elementAt(13)%></td>
                    <td><%=row.elementAt(14)%></td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="16" class="text-center text-muted py-3">No sold records found for selected filters.</td>
                </tr>
                <% } %>
                </tbody>
                <tfoot>
                    <tr class="fw-bold">
                        <td colspan="10" class="text-end">Total</td>
                        <td><%=String.format("%.3f", totalPurchase)%></td>
                        <td class="text-danger"><%=String.format("%.3f", totalExpense)%></td>
                        <td><%=String.format("%.3f", totalSale)%></td>
                        <td class="<%= totalProfit >= 0 ? "text-success" : "text-danger" %>"><%=String.format("%.3f", totalProfit)%></td>
                        <td colspan="2"></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

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
    window.viewExpenses = function(bikeId) {
        document.getElementById('expViewBikeName').textContent = 'Bike ID ' + bikeId;
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
    document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-exp-details');
        if (!btn) {
            return;
        }
        var bikeId = parseInt(btn.getAttribute('data-bike-id'), 10) || 0;
        if (bikeId > 0) {
            window.viewExpenses(bikeId);
        }
    });
    function escH(s) {
        if (!s) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }

    function exportTableToExcel(tableID, filename) {
        var table = document.getElementById(tableID);
        if (!table) { alert('Table not found!'); return; }
        var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">'
                 + '<head><meta charset="UTF-8"><style>td,th{border:1px solid black;padding:5px;}</style></head>'
                 + '<body><table border="1">' + table.innerHTML + '</table></body></html>';
        var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = (filename || 'export') + '.xls';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }
    </script>
</body>
</html>

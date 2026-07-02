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
    reportRows = inv.getSoldReturnReport(fromDate, toDate, supplierId, storeId);
} catch (Exception e) {
    reportError = e.getMessage();
}

double totalOldSale = 0;
if (reportRows != null && reportRows.size() > 0) {
    for (int i = 0; i < reportRows.size(); i++) {
        Vector row = (Vector) reportRows.get(i);
        totalOldSale += Double.parseDouble(row.elementAt(2).toString());
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory Sold Return Report</title>
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

    <div class="container mt-4 mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3 no-print">
            <h3 class="mb-0">Bike Inventory Sold Return Report</h3>
            <div class="d-flex gap-2">
                <a href="<%=contextPath%>/inventory/SoldReturn/report/page.jsp" class="btn btn-secondary btn-sm">Back</a>
                <button class="btn btn-primary btn-sm" onclick="window.print()">Print</button>
                <button class="btn btn-success btn-sm" onclick="exportTableToExcel('reportTable','Sold_Return_Report')">Export Excel</button>
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
                        <div class="text-muted small">Total Returns</div>
                        <div class="fs-5 fw-bold text-primary"><%=reportRows != null ? reportRows.size() : 0%></div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <div class="text-muted small">Total Old Sale Amount</div>
                        <div class="fs-5 fw-bold text-danger"><%=String.format("%.3f", totalOldSale)%></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <table id="reportTable" class="table table-hover mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Return Date Time</th>
                        <th>Invoice Date</th>
                        <th>Supplier</th>
                        <th>Store</th>
                        <th>File No</th>
                        <th>Product Name</th>
                        <th>Vehicle Number</th>
                        <th>Model Year</th>
                        <th>Old Sale Amount</th>
                        <th>Old Sold Date</th>
                        <th>Old Sale Remark</th>
                        <th>Return Reason</th>
                        <th>Returned By</th>
                    </tr>
                </thead>
                <tbody>
                <%
                if (reportRows != null && reportRows.size() > 0) {
                    for (int i = 0; i < reportRows.size(); i++) {
                        Vector row = (Vector) reportRows.get(i);
                        double oldSaleAmount = Double.parseDouble(row.elementAt(2).toString());
                %>
                <tr>
                    <td><%=i + 1%></td>
                    <td><%=row.elementAt(1)%></td>
                    <td><%=row.elementAt(6)%></td>
                    <td><%=row.elementAt(7)%></td>
                    <td><%=row.elementAt(8)%></td>
                    <td><%=row.elementAt(9)%></td>
                    <td><%=row.elementAt(10)%></td>
                    <td><%=row.elementAt(11)%></td>
                    <td><%=row.elementAt(12)%></td>
                    <td><%=String.format("%.3f", oldSaleAmount)%></td>
                    <td><%=row.elementAt(3)%></td>
                    <td><%=row.elementAt(4)%></td>
                    <td><%=row.elementAt(5)%></td>
                    <td><%=row.elementAt(13)%></td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="14" class="text-center text-muted py-3">No sold return records found for selected filters.</td>
                </tr>
                <% } %>
                </tbody>
                <tfoot>
                    <tr class="fw-bold">
                        <td colspan="9" class="text-end">Total</td>
                        <td><%=String.format("%.3f", totalOldSale)%></td>
                        <td colspan="4"></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

    <script>
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

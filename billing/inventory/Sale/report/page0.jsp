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

Vector reportRows = new Vector();
String reportError = null;
try {
    reportRows = inv.getInventorySaleReport(fromDate, toDate, supplierId);
} catch (Exception e) {
    reportError = e.getMessage();
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
        </div>

        <% if (reportError != null) { %>
        <div class="alert alert-danger">Error: <%=reportError%></div>
        <% } %>

        <div class="table-responsive">
            <table id="reportTable" class="table table-hover mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Invoice Date</th>
                        <th>Sold Date</th>
                        <th>Supplier</th>
                        <th>File No</th>
                        <th>Product Name</th>
                        <th>Vehicle Number</th>
                        <th>RC</th>
                        <th>Model Year</th>
                        <th>Purchase Cost</th>
                        <th>Sale Amount</th>
                        <th>Profit</th>
                        <th>Remark</th>
                        <th>Sold Entry Time</th>
                    </tr>
                </thead>
                <tbody>
                <%
                double totalPurchase = 0;
                double totalSale     = 0;
                double totalProfit   = 0;

                if (reportRows != null && reportRows.size() > 0) {
                    for (int i = 0; i < reportRows.size(); i++) {
                        Vector row = (Vector) reportRows.get(i);
                        double purchaseCost = Double.parseDouble(row.elementAt(9).toString());
                        double saleAmount   = Double.parseDouble(row.elementAt(10).toString());
                        double profit       = saleAmount - purchaseCost;
                        totalPurchase += purchaseCost;
                        totalSale     += saleAmount;
                        totalProfit   += profit;
                %>
                <tr>
                    <td><%=i + 1%></td>
                    <td><%=row.elementAt(1)%></td>
                    <td><%=row.elementAt(2)%></td>
                    <td><%=row.elementAt(3)%></td>
                    <td><%=row.elementAt(4)%></td>
                    <td><%=row.elementAt(5)%></td>
                    <td><%=row.elementAt(6)%></td>
                    <td><%= "1".equals(row.elementAt(7).toString()) ? "Yes" : "No" %></td>
                    <td><%=row.elementAt(8)%></td>
                    <td><%=String.format("%.3f", purchaseCost)%></td>
                    <td><%=String.format("%.3f", saleAmount)%></td>
                    <td class="<%= profit >= 0 ? "text-success" : "text-danger" %> fw-bold"><%=String.format("%.3f", profit)%></td>
                    <td><%=row.elementAt(11)%></td>
                    <td><%=row.elementAt(12)%></td>
                </tr>
                <%  }
                } else { %>
                <tr>
                    <td colspan="14" class="text-center text-muted py-3">No sold records found for selected filters.</td>
                </tr>
                <% } %>
                </tbody>
                <tfoot>
                    <tr class="fw-bold">
                        <td colspan="9" class="text-end">Total</td>
                        <td><%=String.format("%.3f", totalPurchase)%></td>
                        <td><%=String.format("%.3f", totalSale)%></td>
                        <td class="<%= totalProfit >= 0 ? "text-success" : "text-danger" %>"><%=String.format("%.3f", totalProfit)%></td>
                        <td colspan="2"></td>
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

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
int storeId = 0;
if (request.getParameter("storeId") != null && request.getParameter("storeId").trim().length() > 0) {
    try {
        storeId = Integer.parseInt(request.getParameter("storeId"));
    } catch (Exception e) {
        storeId = 0;
    }
}

// Load all dashboard data
Vector stores = new Vector();
Vector stats = new Vector();
Vector recentSales = new Vector();
Vector monthlyData = new Vector();
Vector topSuppliers = new Vector();
String dashError = null;
double stockValue = 0;

try {
    stores       = inv.getActiveInvStores();
    stats        = inv.getDashboardStats(storeId);
    recentSales  = inv.getRecentSales(8, storeId);
    monthlyData  = inv.getMonthlyData(storeId);
    topSuppliers = inv.getTopSuppliers(storeId);
    stockValue   = inv.getUnsoldStockValue(storeId);
} catch (Exception e) {
    dashError = e.getMessage();
}

int totalUnsold = 0, totalSold = 0, todaySold = 0, thisMonthPurchased = 0, totalSuppliers = 0;
double totalPurchaseCost = 0, totalSaleAmount = 0, totalExpenses = 0;

if (stats.size() > 0) {
    totalUnsold         = Integer.parseInt(stats.elementAt(0).toString());
    totalSold           = Integer.parseInt(stats.elementAt(1).toString());
    totalPurchaseCost   = Double.parseDouble(stats.elementAt(2).toString());
    totalSaleAmount     = Double.parseDouble(stats.elementAt(3).toString());
    totalExpenses       = Double.parseDouble(stats.elementAt(4).toString());
    todaySold           = Integer.parseInt(stats.elementAt(5).toString());
    thisMonthPurchased  = Integer.parseInt(stats.elementAt(6).toString());
    totalSuppliers      = Integer.parseInt(stats.elementAt(7).toString());
}

// Net profit = sale_amount - purchase_cost (sold bikes only approximation)
double netProfit = totalSaleAmount - totalExpenses;

// Build chart data JSON arrays from monthlyData
StringBuilder chartLabels = new StringBuilder("[");
StringBuilder chartPurchaseCount = new StringBuilder("[");
StringBuilder chartSoldCount = new StringBuilder("[");
StringBuilder chartSaleAmt = new StringBuilder("[");
StringBuilder chartPurchaseCostArr = new StringBuilder("[");

for (int i = 0; i < monthlyData.size(); i++) {
    Vector mrow = (Vector) monthlyData.get(i);
    if (i > 0) {
        chartLabels.append(",");
        chartPurchaseCount.append(",");
        chartSoldCount.append(",");
        chartSaleAmt.append(",");
        chartPurchaseCostArr.append(",");
    }
    chartLabels.append("\"").append(mrow.elementAt(0)).append("\"");
    chartPurchaseCount.append(mrow.elementAt(1) != null ? mrow.elementAt(1) : "0");
    chartSoldCount.append(mrow.elementAt(2) != null ? mrow.elementAt(2) : "0");
    chartSaleAmt.append(mrow.elementAt(3) != null ? String.format("%.2f", Double.parseDouble(mrow.elementAt(3).toString())) : "0");
    chartPurchaseCostArr.append(mrow.elementAt(4) != null ? String.format("%.2f", Double.parseDouble(mrow.elementAt(4).toString())) : "0");
}
chartLabels.append("]");
chartPurchaseCount.append("]");
chartSoldCount.append("]");
chartSaleAmt.append("]");
chartPurchaseCostArr.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .kpi-card {
            border: none;
            border-radius: 12px;
            transition: transform 0.2s, box-shadow 0.2s;
            overflow: hidden;
        }
        .kpi-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.13) !important;
        }
        .kpi-icon {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
        }
        .kpi-value {
            font-size: 1.75rem;
            font-weight: 700;
            line-height: 1.1;
        }
        .kpi-label {
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #6c757d;
        }
        .section-title {
            font-size: 1rem;
            font-weight: 600;
            color: #344054;
            border-left: 4px solid #0d6efd;
            padding-left: 10px;
            margin-bottom: 1rem;
        }
        .chart-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.07);
        }
        .table-sm td, .table-sm th { vertical-align: middle; }
        .badge-stock { background: #e8f5e9; color: #2e7d32; }
        .badge-sold  { background: #e3f2fd; color: #1565c0; }
        .profit-pos  { color: #198754; font-weight: 600; }
        .profit-neg  { color: #dc3545; font-weight: 600; }
        .supplier-bar {
            height: 8px;
            border-radius: 4px;
            background: #e9ecef;
        }
        .supplier-bar-fill {
            height: 8px;
            border-radius: 4px;
            background: linear-gradient(90deg, #0d6efd, #6ea8fe);
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid p-4">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="mb-0 fw-bold">Bike Inventory Dashboard</h3>
                <small class="text-muted">Overview of purchases, sales, expenses and stock status</small>
            </div>
            <div class="d-flex gap-2 align-items-end">
                <form method="get" action="<%=contextPath%>/inventory/dashboard.jsp" class="d-flex align-items-end gap-2">
                    <div>
                        <label class="form-label form-label-sm mb-1">Store</label>
                        <select name="storeId" class="form-select form-select-sm" onchange="this.form.submit()">
                            <option value="0" <%=storeId == 0 ? "selected" : ""%>>All Stores</option>
                            <% for (int i = 0; i < stores.size(); i++) {
                                Vector srow = (Vector) stores.get(i);
                                int sid = Integer.parseInt(srow.elementAt(0).toString());
                            %>
                                <option value="<%=sid%>" <%=storeId == sid ? "selected" : ""%>><%=srow.elementAt(1)%></option>
                            <% } %>
                        </select>
                    </div>
                    <noscript><button type="submit" class="btn btn-outline-secondary btn-sm">Apply</button></noscript>
                </form>
                <a href="<%=contextPath%>/inventory/Purchase/page.jsp" class="btn btn-primary btn-sm">
                    <i class="fas fa-plus"></i> Add Purchase
                </a>
                <a href="<%=contextPath%>/inventory/Sale/page.jsp" class="btn btn-success btn-sm">
                    <i class="fas fa-tag"></i> Sold Entry
                </a>
            </div>
        </div>

        <% if (dashError != null) { %>
        <div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i>Error: <%=dashError%></div>
        <% } %>

        <!-- ── KPI CARDS ── -->
        <div class="row g-3 mb-4">

            <!-- Total Stock (Unsold) -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">In Stock</div>
                            <div class="kpi-value text-primary"><%=totalUnsold%></div>
                            <small class="text-muted">unsold bikes</small>
                        </div>
                        <div class="kpi-icon" style="background:#e3f2fd">
                            <i class="fas fa-motorcycle text-primary"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Sold -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">Total Sold</div>
                            <div class="kpi-value text-success"><%=totalSold%></div>
                            <small class="text-success fw-semibold">Today: <%=todaySold%></small>
                        </div>
                        <div class="kpi-icon" style="background:#e8f5e9">
                            <i class="fas fa-check-circle text-success"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Purchase Cost -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">Total Purchase</div>
                            <div class="kpi-value text-warning" style="font-size:1.35rem"><%=String.format("%.2f", totalPurchaseCost)%></div>
                            <small class="text-muted">This month: <%=thisMonthPurchased%> bikes</small>
                        </div>
                        <div class="kpi-icon" style="background:#fff3e0">
                            <i class="fas fa-shopping-cart text-warning"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Sale Revenue -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">Sale Revenue</div>
                            <div class="kpi-value text-info" style="font-size:1.35rem"><%=String.format("%.2f", totalSaleAmount)%></div>
                            <small class="text-muted">from <%=totalSold%> sold</small>
                        </div>
                        <div class="kpi-icon" style="background:#e0f7fa">
                            <i class="fas fa-coins text-info"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Expenses -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">Total Expenses</div>
                            <div class="kpi-value text-danger" style="font-size:1.35rem"><%=String.format("%.2f", totalExpenses)%></div>
                            <small class="text-muted">all bike expenses</small>
                        </div>
                        <div class="kpi-icon" style="background:#fce4ec">
                            <i class="fas fa-receipt text-danger"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Net Profit -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">Net Revenue</div>
                            <div class="kpi-value <%=netProfit >= 0 ? "text-success" : "text-danger"%>" style="font-size:1.35rem">
                                <%=String.format("%.2f", netProfit)%>
                            </div>
                            <small class="text-muted">sale &minus; expenses</small>
                        </div>
                        <div class="kpi-icon" style="background:<%=netProfit >= 0 ? "#e8f5e9" : "#fce4ec"%>">
                            <i class="fas fa-chart-line <%=netProfit >= 0 ? "text-success" : "text-danger"%>"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Active Suppliers -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">Suppliers</div>
                            <div class="kpi-value text-secondary"><%=totalSuppliers%></div>
                            <small class="text-muted">active suppliers</small>
                        </div>
                        <div class="kpi-icon" style="background:#f3e5f5">
                            <i class="fas fa-truck text-secondary"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Stock Value (unsold purchase cost) -->
            <div class="col-6 col-md-3">
                <div class="card kpi-card shadow-sm h-100 p-3">
                    <div class="d-flex align-items-start justify-content-between">
                        <div>
                            <div class="kpi-label mb-1">Stock Value</div>
                            <div class="kpi-value text-primary" style="font-size:1.35rem"><%=String.format("%.2f", stockValue)%></div>
                            <small class="text-muted">unsold bikes cost</small>
                        </div>
                        <div class="kpi-icon" style="background:#e8eaf6">
                            <i class="fas fa-warehouse" style="color:#5c6bc0"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── CHARTS ROW ── -->
        <div class="row g-3 mb-4">
            <!-- Monthly Bike Count Bar Chart -->
            <div class="col-md-7">
                <div class="card chart-card p-3 h-100">
                    <div class="section-title">Monthly Purchases vs Sales (last 6 months)</div>
                    <canvas id="chartCount" height="130"></canvas>
                </div>
            </div>

            <!-- Monthly Revenue Bar Chart -->
            <div class="col-md-5">
                <div class="card chart-card p-3 h-100">
                    <div class="section-title">Monthly Revenue vs Cost</div>
                    <canvas id="chartRevenue" height="130"></canvas>
                </div>
            </div>
        </div>

        <!-- ── TABLES ROW ── -->
        <div class="row g-3">

            <!-- Recent Sales -->
            <div class="col-md-7">
                <div class="card chart-card p-3 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <div class="section-title mb-0">Recent Sales</div>
                        <a href="<%=contextPath%>/inventory/Sale/report/page.jsp" class="btn btn-outline-success btn-sm">View All</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-sm table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>#</th>
                                    <th>Sold Date</th>
                                    <th>Product</th>
                                    <th>Vehicle No</th>
                                    <th>Purchase</th>
                                    <th>Sale</th>
                                    <th>Profit</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (recentSales.size() == 0) { %>
                                <tr><td colspan="7" class="text-center text-muted py-3">No sales yet.</td></tr>
                            <% }
                            for (int i = 0; i < recentSales.size(); i++) {
                                Vector rs2 = (Vector) recentSales.get(i);
                                double saleAmt = Double.parseDouble(rs2.elementAt(4).toString());
                                double purCost  = Double.parseDouble(rs2.elementAt(6).toString());
                                double profit   = saleAmt - purCost;
                            %>
                                <tr>
                                    <td><%=i+1%></td>
                                    <td><small><%=rs2.elementAt(1)%></small></td>
                                    <td><%=rs2.elementAt(2)%></td>
                                    <td><span class="badge bg-light text-dark border"><%=rs2.elementAt(3)%></span></td>
                                    <td><%=String.format("%.2f", purCost)%></td>
                                    <td class="text-success fw-semibold"><%=String.format("%.2f", saleAmt)%></td>
                                    <td class="<%=profit >= 0 ? "profit-pos" : "profit-neg"%>"><%=String.format("%.2f", profit)%></td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Top Suppliers -->
            <div class="col-md-5">
                <div class="card chart-card p-3 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <div class="section-title mb-0">Top Suppliers</div>
                        <a href="<%=contextPath%>/inventory/Supplier/page.jsp" class="btn btn-outline-secondary btn-sm">Manage</a>
                    </div>
                    <%
                    int maxBikes = 1;
                    for (int i = 0; i < topSuppliers.size(); i++) {
                        Vector sr = (Vector) topSuppliers.get(i);
                        int tb = Integer.parseInt(sr.elementAt(1).toString());
                        if (tb > maxBikes) maxBikes = tb;
                    }
                    %>
                    <% if (topSuppliers.size() == 0) { %>
                        <p class="text-muted text-center py-3">No supplier data.</p>
                    <% } %>
                    <% for (int i = 0; i < topSuppliers.size(); i++) {
                        Vector sr = (Vector) topSuppliers.get(i);
                        int totalB  = Integer.parseInt(sr.elementAt(1).toString());
                        int soldB   = Integer.parseInt(sr.elementAt(2).toString());
                        int unsoldB = Integer.parseInt(sr.elementAt(3).toString());
                        int pct = (int)((totalB * 100.0) / maxBikes);
                    %>
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="fw-semibold" style="font-size:.9rem"><%=sr.elementAt(0)%></span>
                            <span class="text-muted" style="font-size:.8rem"><%=totalB%> bikes</span>
                        </div>
                        <div class="supplier-bar">
                            <div class="supplier-bar-fill" style="width:<%=pct%>%"></div>
                        </div>
                        <div class="d-flex gap-2 mt-1">
                            <span class="badge badge-sold" style="font-size:.72rem"><i class="fas fa-check-circle me-1"></i>Sold: <%=soldB%></span>
                            <span class="badge badge-stock" style="font-size:.72rem"><i class="fas fa-motorcycle me-1"></i>In Stock: <%=unsoldB%></span>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- ── QUICK LINKS ── -->
        <div class="row g-2 mt-3">
            <div class="col-12">
                <div class="card chart-card p-3">
                    <div class="section-title">Quick Actions</div>
                    <div class="d-flex flex-wrap gap-2">
                        <a href="<%=contextPath%>/inventory/Supplier/page.jsp" class="btn btn-outline-secondary btn-sm"><i class="fas fa-truck me-1"></i>Suppliers</a>
                        <a href="<%=contextPath%>/inventory/Purchase/page.jsp" class="btn btn-outline-primary btn-sm"><i class="fas fa-plus-circle me-1"></i>New Purchase</a>
                        <a href="<%=contextPath%>/inventory/Purchase/report/page.jsp" class="btn btn-outline-primary btn-sm"><i class="fas fa-file-alt me-1"></i>Purchase Report</a>
                        <a href="<%=contextPath%>/inventory/Sale/page.jsp" class="btn btn-outline-success btn-sm"><i class="fas fa-tag me-1"></i>Sold Entry</a>
                        <a href="<%=contextPath%>/inventory/Sale/report/page.jsp" class="btn btn-outline-success btn-sm"><i class="fas fa-chart-bar me-1"></i>Sale Report</a>
                        <a href="<%=contextPath%>/inventory/Expense/page.jsp" class="btn btn-outline-warning btn-sm"><i class="fas fa-receipt me-1"></i>Expense Entry</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
    var chartLabels = <%=chartLabels%>;
    var chartPurchaseCount = <%=chartPurchaseCount%>;
    var chartSoldCount = <%=chartSoldCount%>;
    var chartSaleAmt = <%=chartSaleAmt%>;
    var chartPurchaseCost = <%=chartPurchaseCostArr%>;

    // Chart 1: Bike count (purchased vs sold per month)
    new Chart(document.getElementById('chartCount'), {
        type: 'bar',
        data: {
            labels: chartLabels,
            datasets: [
                {
                    label: 'Purchased',
                    data: chartPurchaseCount,
                    backgroundColor: 'rgba(13, 110, 253, 0.75)',
                    borderRadius: 5
                },
                {
                    label: 'Sold',
                    data: chartSoldCount,
                    backgroundColor: 'rgba(25, 135, 84, 0.75)',
                    borderRadius: 5
                }
            ]
        },
        options: {
            responsive: true,
            plugins: { legend: { position: 'top' } },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { precision: 0 },
                    grid: { color: 'rgba(0,0,0,0.05)' }
                },
                x: { grid: { display: false } }
            }
        }
    });

    // Chart 2: Revenue vs Cost line chart
    new Chart(document.getElementById('chartRevenue'), {
        type: 'line',
        data: {
            labels: chartLabels,
            datasets: [
                {
                    label: 'Sale Revenue',
                    data: chartSaleAmt,
                    borderColor: '#198754',
                    backgroundColor: 'rgba(25,135,84,0.1)',
                    fill: true,
                    tension: 0.4,
                    pointRadius: 4
                },
                {
                    label: 'Purchase Cost',
                    data: chartPurchaseCost,
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13,110,253,0.08)',
                    fill: true,
                    tension: 0.4,
                    pointRadius: 4
                }
            ]
        },
        options: {
            responsive: true,
            plugins: { legend: { position: 'top' } },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: 'rgba(0,0,0,0.05)' }
                },
                x: { grid: { display: false } }
            }
        }
    });
    </script>
</body>
</html>

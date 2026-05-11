<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");

int fromStoreId = 0;
if (request.getParameter("fromStoreId") != null && request.getParameter("fromStoreId").trim().length() > 0) {
    try {
        fromStoreId = Integer.parseInt(request.getParameter("fromStoreId"));
    } catch (Exception e) {
        fromStoreId = 0;
    }
}

Vector stores = new Vector();
Vector unsoldBikes = new Vector();
Vector transferHistory = new Vector();
String pageError = null;

try {
    stores = inv.getActiveInvStores();
    if (fromStoreId > 0) {
        unsoldBikes = inv.getUnsoldInventoryByStore(fromStoreId);
    }
    transferHistory = inv.getInvStoreTransferHistory(50);
} catch (Exception e) {
    pageError = e.getMessage();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Store Transfer</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4 mb-4">
        <h3 class="mb-3">Unsold Bike Transfer</h3>

        <% if (msg != null) { %>
        <div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show" role="alert">
            <%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <% if (pageError != null) { %>
        <div class="alert alert-danger">Error: <%=pageError%></div>
        <% } %>

        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="<%=contextPath%>/inventory/Transfer/page.jsp" class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label">From Store</label>
                        <select name="fromStoreId" class="form-select" required>
                            <option value="">Select Store</option>
                            <% for (int i = 0; i < stores.size(); i++) {
                                Vector s = (Vector) stores.get(i);
                                int sid = Integer.parseInt(s.elementAt(0).toString());
                            %>
                                <option value="<%=sid%>" <%= fromStoreId == sid ? "selected" : "" %>><%=s.elementAt(1)%> (<%=s.elementAt(2)%>)</option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">Load Unsold</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h5 class="mb-0">Unsold Bikes in Selected Store</h5>
                    <% if (fromStoreId > 0) { %>
                    <span class="badge bg-light text-dark border"><%=unsoldBikes.size()%> bikes</span>
                    <% } %>
                </div>

                <% if (fromStoreId <= 0) { %>
                    <p class="text-muted mb-0">Choose a From Store and click Load Unsold.</p>
                <% } else if (unsoldBikes.size() == 0) { %>
                    <p class="text-muted mb-0">No unsold bikes in selected store.</p>
                <% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>File No</th>
                                <th>Product</th>
                                <th>Vehicle No</th>
                                <th>Model</th>
                                <th>Purchase Cost</th>
                                <th>To Store</th>
                                <th>Remark</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < unsoldBikes.size(); i++) {
                                Vector row = (Vector) unsoldBikes.get(i);
                            %>
                            <tr>
                                <td><%=row.elementAt(3)%></td>
                                <td><%=row.elementAt(4)%></td>
                                <td><%=row.elementAt(5)%></td>
                                <td><%=row.elementAt(7)%></td>
                                <td><%=row.elementAt(8)%></td>
                                <td>
                                    <form method="post" action="<%=contextPath%>/inventory/Transfer/save.jsp" class="d-flex gap-2 align-items-center mb-0">
                                        <input type="hidden" name="bikeId" value="<%=row.elementAt(0)%>">
                                        <input type="hidden" name="fromStoreId" value="<%=fromStoreId%>">
                                        <select name="toStoreId" class="form-select form-select-sm" required>
                                            <option value="">Select</option>
                                            <% for (int j = 0; j < stores.size(); j++) {
                                                Vector s = (Vector) stores.get(j);
                                                int toStore = Integer.parseInt(s.elementAt(0).toString());
                                                if (toStore == fromStoreId) {
                                                    continue;
                                                }
                                            %>
                                                <option value="<%=toStore%>"><%=s.elementAt(1)%></option>
                                            <% } %>
                                        </select>
                                </td>
                                <td>
                                        <input type="text" name="remark" class="form-control form-control-sm" placeholder="Optional">
                                </td>
                                <td>
                                        <button type="submit" class="btn btn-warning btn-sm">Transfer</button>
                                    </form>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <h5 class="mb-3">Recent Transfer History</h5>
                <% if (transferHistory.size() == 0) { %>
                    <p class="text-muted mb-0">No transfer history yet.</p>
                <% } else { %>
                <div class="table-responsive">
                    <table class="table table-sm table-bordered mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Date Time</th>
                                <th>Bike</th>
                                <th>From</th>
                                <th>To</th>
                                <th>Remark</th>
                                <th>By</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < transferHistory.size(); i++) {
                                Vector h = (Vector) transferHistory.get(i);
                            %>
                            <tr>
                                <td><%=i + 1%></td>
                                <td><%=h.elementAt(1)%></td>
                                <td>
                                    File: <%=h.elementAt(3)%><br>
                                    <small class="text-muted"><%=h.elementAt(4)%></small>
                                </td>
                                <td><%=h.elementAt(5)%></td>
                                <td><%=h.elementAt(6)%></td>
                                <td><%=h.elementAt(7)%></td>
                                <td><%=h.elementAt(8)%></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>

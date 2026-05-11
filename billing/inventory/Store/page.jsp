<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bike Inventory Store Master</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3>Bike Inventory Store Master</h3>

        <% if (msg != null) { %>
        <div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show" role="alert">
            <%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/inventory/Store/page1.jsp" method="post" class="row g-3">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="name" class="form-control" required>
                        <label>Store Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="text" name="code" class="form-control" required>
                        <label>Store Code</label>
                    </div>
                    <div class="col-md-12 input-outline">
                        <textarea name="address" placeholder="Address"></textarea>
                    </div>
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Add Store</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <h5>Store List</h5>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Name</th>
                                <th>Code</th>
                                <th>Address</th>
                                <th>Functions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        Vector vec = inv.getInvStoreDetails();
                        for (int i = 0; i < vec.size(); i++) {
                            Vector row = (Vector) vec.get(i);
                            int id = Integer.parseInt(row.elementAt(0).toString());
                            String name = row.elementAt(1).toString();
                            String code = row.elementAt(2).toString();
                            String address = row.elementAt(3).toString();
                        %>
                            <tr>
                                <td><%=i + 1%></td>
                                <td><%=name%></td>
                                <td><%=code%></td>
                                <td><%=address%></td>
                                <td>
                                    <a href="<%=contextPath%>/inventory/Store/edit.jsp?id=<%=id%>&name=<%=java.net.URLEncoder.encode(name, "UTF-8")%>&code=<%=java.net.URLEncoder.encode(code, "UTF-8")%>&address=<%=java.net.URLEncoder.encode(address, "UTF-8")%>" class="btn btn-warning btn-sm">Edit</a>
                                </td>
                            </tr>
                        <%
                        }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

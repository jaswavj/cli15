<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String id = request.getParameter("id");
String name = request.getParameter("name") != null ? request.getParameter("name") : "";
String code = request.getParameter("code") != null ? request.getParameter("code") : "";
String address = request.getParameter("address") != null ? request.getParameter("address") : "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Bike Inventory Store</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3>Edit Store</h3>
        <div class="card">
            <div class="card-body">
                <form action="<%=contextPath%>/inventory/Store/edit1.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=id%>">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="name" class="form-control" value="<%=name%>" required>
                        <label>Store Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="text" name="code" class="form-control" value="<%=code%>" required>
                        <label>Store Code</label>
                    </div>
                    <div class="col-md-12 input-outline">
                        <textarea name="address" placeholder="Address"><%=address%></textarea>
                    </div>
                    <div class="col-md-12">
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="block" name="block">
                            <label class="form-check-label" for="block">Block Store</label>
                        </div>
                        <button type="submit" class="btn btn-primary">Update Store</button>
                        <a href="<%=contextPath%>/inventory/Store/page.jsp" class="btn btn-secondary">Back</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>

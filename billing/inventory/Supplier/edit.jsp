<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String id = request.getParameter("id");
String name = request.getParameter("name") != null ? request.getParameter("name") : "";
String phone = request.getParameter("phone") != null ? request.getParameter("phone") : "";
String description = request.getParameter("description") != null ? request.getParameter("description") : "";
String gstin = request.getParameter("gstin") != null ? request.getParameter("gstin") : "";
int isGst = 0;
if (request.getParameter("isGst") != null) {
    isGst = Integer.parseInt(request.getParameter("isGst"));
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Bike Inventory Supplier</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3>Edit Supplier</h3>
        <div class="card">
            <div class="card-body">
                <form action="<%=contextPath%>/inventory/Supplier/edit1.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=id%>">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="name" class="form-control" value="<%=name%>" required>
                        <label>Supplier Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="number" name="phoneNumber" class="form-control" value="<%=phone%>">
                        <label>Phone Number</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <textarea name="description" placeholder="Description"><%=description%></textarea>
                    </div>
                    <div class="col-md-6">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="isGst" name="isGst" <%= (isGst == 1) ? "checked" : "" %> onchange="toggleGstin()">
                            <label class="form-check-label" for="isGst">GST Registered</label>
                        </div>
                        <div class="input-outline">
                            <input type="text" name="gstin" id="gstin" class="form-control" value="<%=gstin%>" maxlength="15" <%= (isGst == 1) ? "" : "disabled" %>>
                            <label>GSTIN</label>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="block" name="block">
                            <label class="form-check-label" for="block">Block Supplier</label>
                        </div>
                        <button type="submit" class="btn btn-primary">Update Supplier</button>
                        <a href="<%=contextPath%>/inventory/Supplier/page.jsp" class="btn btn-secondary">Back</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
    function toggleGstin() {
        var isGstChecked = document.getElementById('isGst').checked;
        var gstinField = document.getElementById('gstin');
        gstinField.disabled = !isGstChecked;
        if (!isGstChecked) {
            gstinField.value = '';
        }
    }
    </script>
</body>
</html>

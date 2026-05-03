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
    <title>Bike Inventory Supplier</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3>Bike Inventory Supplier</h3>

        <% if (msg != null) { %>
        <div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show" role="alert">
            <%= msg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <% } %>

        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/inventory/Supplier/page1.jsp" method="post" class="row g-3">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="name" class="form-control" required>
                        <label>Supplier Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="number" name="phoneNumber" class="form-control">
                        <label>Phone Number</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <textarea name="description" placeholder="Description"></textarea>
                    </div>
                    <div class="col-md-6">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="isGst" name="isGst" onchange="toggleGstin()">
                            <label class="form-check-label" for="isGst">GST Registered</label>
                        </div>
                        <div class="input-outline">
                            <input type="text" name="gstin" id="gstin" class="form-control" maxlength="15" disabled>
                            <label>GSTIN <span class="text-danger" id="gstinRequired" style="display:none;">*</span></label>
                            <small id="gstinError" class="text-danger" style="display:none;">GSTIN must be exactly 15 characters</small>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Add Supplier</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <h5>Supplier List</h5>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Name</th>
                                <th>Phone Number</th>
                                <th>GST Status</th>
                                <th>GSTIN</th>
                                <th>Description</th>
                                <th>Functions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        Vector vec = inv.getInvSupplierDetails();
                        for (int i = 0; i < vec.size(); i++) {
                            Vector row = (Vector) vec.get(i);
                            String supplierName = row.elementAt(0).toString();
                            int id = Integer.parseInt(row.elementAt(1).toString());
                            String description = row.elementAt(2).toString();
                            String phone = row.elementAt(3).toString();
                            String gstin = row.elementAt(4).toString();
                            int isGst = Integer.parseInt(row.elementAt(5).toString());
                        %>
                            <tr>
                                <td><%=i + 1%></td>
                                <td><%=supplierName%></td>
                                <td><%=phone%></td>
                                <td>
                                    <% if (isGst == 1) { %>
                                        <span class="badge bg-success">Registered</span>
                                    <% } else { %>
                                        <span class="badge bg-secondary">Not Registered</span>
                                    <% } %>
                                </td>
                                <td><%=gstin%></td>
                                <td><%=description%></td>
                                <td>
                                    <a href="<%=contextPath%>/inventory/Supplier/edit.jsp?id=<%=id%>&name=<%=java.net.URLEncoder.encode(supplierName, "UTF-8")%>&phone=<%=java.net.URLEncoder.encode(phone, "UTF-8")%>&description=<%=java.net.URLEncoder.encode(description, "UTF-8")%>&gstin=<%=java.net.URLEncoder.encode(gstin, "UTF-8")%>&isGst=<%=isGst%>" class="btn btn-warning btn-sm">Edit</a>
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

    <script>
    function toggleGstin() {
        var isGstChecked = document.getElementById('isGst').checked;
        var gstinField = document.getElementById('gstin');
        var gstinRequired = document.getElementById('gstinRequired');
        var gstinError = document.getElementById('gstinError');

        if (isGstChecked) {
            gstinField.disabled = false;
            gstinField.required = true;
            gstinRequired.style.display = 'inline';
            gstinField.focus();
        } else {
            gstinField.disabled = true;
            gstinField.required = false;
            gstinField.value = '';
            gstinRequired.style.display = 'none';
            gstinError.style.display = 'none';
            gstinField.style.borderColor = '';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        var gstinField = document.getElementById('gstin');
        var gstinError = document.getElementById('gstinError');
        var isGstCheckbox = document.getElementById('isGst');
        var form = document.querySelector('form');

        gstinField.addEventListener('input', function() {
            if (isGstCheckbox.checked) {
                if (this.value.length > 0 && this.value.length !== 15) {
                    this.style.borderColor = '#dc3545';
                    gstinError.style.display = 'block';
                } else {
                    this.style.borderColor = '';
                    gstinError.style.display = 'none';
                }
            }
        });

        form.addEventListener('submit', function(e) {
            if (isGstCheckbox.checked && gstinField.value.trim().length !== 15) {
                e.preventDefault();
                gstinField.focus();
                gstinField.style.borderColor = '#dc3545';
                gstinError.style.display = 'block';
            }
        });
    });
    </script>
</body>
</html>

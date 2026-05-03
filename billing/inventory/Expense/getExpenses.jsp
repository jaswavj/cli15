<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="inv" class="inventory.inventoryBean" />
<%
response.setHeader("Cache-Control", "no-cache, no-store");
response.setHeader("Content-Type", "application/json; charset=UTF-8");

String bikeIdStr = request.getParameter("bikeId");
if (bikeIdStr == null || bikeIdStr.trim().length() == 0) {
    out.print("[]");
    return;
}

try {
    int bikeId = Integer.parseInt(bikeIdStr.trim());
    Vector expenses = inv.getExpensesByBikeId(bikeId);

    StringBuilder sb = new StringBuilder("[");
    for (int i = 0; i < expenses.size(); i++) {
        Vector row = (Vector) expenses.get(i);
        if (i > 0) sb.append(",");
        sb.append("{");
        sb.append("\"id\":").append(row.elementAt(0));
        sb.append(",\"content\":\"").append(ej(row.elementAt(1).toString())).append("\"");
        sb.append(",\"amount\":\"").append(row.elementAt(2)).append("\"");
        sb.append(",\"description\":\"").append(ej(row.elementAt(3).toString())).append("\"");
        sb.append(",\"exc_date_time\":\"").append(ej(row.elementAt(4).toString())).append("\"");
        sb.append("}");
    }
    sb.append("]");
    out.print(sb.toString());
} catch (Exception e) {
    out.print("[]");
}
%>
<%!
private String ej(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\r", "")
            .replace("\n", "\\n");
}
%>

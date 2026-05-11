package inventory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;

public class inventoryBean {

    public inventoryBean() {
    }

    public Connection check() throws SQLException {
        return util.DBConnectionManager.getConnectionFromPool();
    }

    public int checkInvSupplierNameExist(String name) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        con = util.DBConnectionManager.getConnectionFromPool();
        try {
            int supplierId = 0;
            pt = con.prepareStatement("SELECT id FROM inv_supplier WHERE name = ?");
            pt.setString(1, name);
            rs = pt.executeQuery();
            if (rs.next()) {
                supplierId = rs.getInt(1);
            }
            return supplierId;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public int checkInvSupplierNameExistForEdit(String name, int id) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        con = util.DBConnectionManager.getConnectionFromPool();
        try {
            int supplierId = 0;
            pt = con.prepareStatement("SELECT id FROM inv_supplier WHERE name = ? AND id != ?");
            pt.setString(1, name);
            pt.setInt(2, id);
            rs = pt.executeQuery();
            if (rs.next()) {
                supplierId = rs.getInt(1);
            }
            return supplierId;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public void addInvSupplier(String name, String phoneNumber, String description, String gstin, int isGst) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            String sql = "INSERT INTO inv_supplier(name, phone_number, description, date, time, is_active, gstin, is_gst) VALUES (?, ?, ?, NOW(), NOW(), 1, ?, ?)";
            pt = con.prepareStatement(sql);
            pt.setString(1, name);
            pt.setString(2, phoneNumber);
            pt.setString(3, description);
            pt.setString(4, gstin);
            pt.setInt(5, isGst);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public void editInvSupplier(int id, String name, String phoneNumber, String description, String gstin, int isGst) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            pt = con.prepareStatement("UPDATE inv_supplier SET name=?, phone_number=?, description=?, gstin=?, is_gst=? WHERE id=?");
            pt.setString(1, name);
            pt.setString(2, phoneNumber);
            pt.setString(3, description);
            pt.setString(4, gstin);
            pt.setInt(5, isGst);
            pt.setInt(6, id);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public void blockInvSupplier(int id) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            pt = con.prepareStatement("UPDATE inv_supplier SET is_active=0 WHERE id=?");
            pt.setInt(1, id);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public Vector getInvSupplierDetails() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();

            String sql = "SELECT name, id, "
                    + "CASE WHEN description = '' OR description IS NULL THEN '-' ELSE description END AS description, "
                    + "CASE WHEN phone_number = '' OR phone_number IS NULL THEN '-' ELSE phone_number END AS phone_number, "
                    + "CASE WHEN gstin = '' OR gstin IS NULL THEN '-' ELSE gstin END AS gstin, "
                    + "COALESCE(is_gst, 0) AS is_gst "
                    + "FROM inv_supplier WHERE is_active = 1 ORDER BY id DESC";
            pt = con.prepareStatement(sql);
            rs = pt.executeQuery();

            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                major.addElement(row);
            }

            return major;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public Vector getActiveInvSuppliers() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();
            pt = con.prepareStatement("SELECT id, name FROM inv_supplier WHERE is_active = 1 ORDER BY name");
            rs = pt.executeQuery();

            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                major.addElement(row);
            }
            return major;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public int checkInvStoreNameExist(String name) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        con = util.DBConnectionManager.getConnectionFromPool();
        try {
            int storeId = 0;
            pt = con.prepareStatement("SELECT id FROM inv_stores WHERE name = ?");
            pt.setString(1, name);
            rs = pt.executeQuery();
            if (rs.next()) {
                storeId = rs.getInt(1);
            }
            return storeId;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public int checkInvStoreNameExistForEdit(String name, int id) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        con = util.DBConnectionManager.getConnectionFromPool();
        try {
            int storeId = 0;
            pt = con.prepareStatement("SELECT id FROM inv_stores WHERE name = ? AND id != ?");
            pt.setString(1, name);
            pt.setInt(2, id);
            rs = pt.executeQuery();
            if (rs.next()) {
                storeId = rs.getInt(1);
            }
            return storeId;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public int checkInvStoreCodeExist(String code) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        con = util.DBConnectionManager.getConnectionFromPool();
        try {
            int storeId = 0;
            pt = con.prepareStatement("SELECT id FROM inv_stores WHERE code = ?");
            pt.setString(1, code);
            rs = pt.executeQuery();
            if (rs.next()) {
                storeId = rs.getInt(1);
            }
            return storeId;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public int checkInvStoreCodeExistForEdit(String code, int id) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        con = util.DBConnectionManager.getConnectionFromPool();
        try {
            int storeId = 0;
            pt = con.prepareStatement("SELECT id FROM inv_stores WHERE code = ? AND id != ?");
            pt.setString(1, code);
            pt.setInt(2, id);
            rs = pt.executeQuery();
            if (rs.next()) {
                storeId = rs.getInt(1);
            }
            return storeId;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public void addInvStore(String name, String code, String address) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            String sql = "INSERT INTO inv_stores(name, code, address, is_active) VALUES (?, ?, ?, 1)";
            pt = con.prepareStatement(sql);
            pt.setString(1, name);
            pt.setString(2, code);
            pt.setString(3, address);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public void editInvStore(int id, String name, String code, String address) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            pt = con.prepareStatement("UPDATE inv_stores SET name=?, code=?, address=? WHERE id=?");
            pt.setString(1, name);
            pt.setString(2, code);
            pt.setString(3, address);
            pt.setInt(4, id);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public void blockInvStore(int id) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            pt = con.prepareStatement("UPDATE inv_stores SET is_active=0 WHERE id=?");
            pt.setInt(1, id);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public Vector getInvStoreDetails() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();

            String sql = "SELECT id, name, code, CASE WHEN address = '' OR address IS NULL THEN '-' ELSE address END AS address "
                    + "FROM inv_stores WHERE is_active = 1 ORDER BY id DESC";
            pt = con.prepareStatement(sql);
            rs = pt.executeQuery();

            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                major.addElement(row);
            }

            return major;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public Vector getActiveInvStores() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();
            pt = con.prepareStatement("SELECT id, name, code FROM inv_stores WHERE is_active = 1 ORDER BY name");
            rs = pt.executeQuery();

            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                major.addElement(row);
            }
            return major;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public void addInventoryPurchaseItems(String invDate, int storeId, int supplierId, String purchaseRemark, int uid,
                                          String[] fileIds, String[] productNames, String[] vehicleNumbers,
                                          String[] isRcValues, String[] modelYears, String[] purchaseCosts) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

                String sql = "INSERT INTO inventory(file_id, product_name, vehicle_number, is_rc, model, purchase_cost, inv_date, dateTime, purchase_remark, uid, is_sold, sale_amount, sold_date, sale_remark, supplier_id, store_id) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?, 0, 0, NULL, NULL, ?, ?)";
            pt = con.prepareStatement(sql);

            for (int i = 0; i < fileIds.length; i++) {
                String fileIdRaw = fileIds[i] != null ? fileIds[i].trim() : "";
                String productName = productNames[i] != null ? productNames[i].trim() : "";
                String vehicleNo = vehicleNumbers[i] != null ? vehicleNumbers[i].trim() : "";

                if (fileIdRaw.length() == 0 && productName.length() == 0 && vehicleNo.length() == 0) {
                    continue;
                }

                if (fileIdRaw.length() == 0 || productName.length() == 0 || vehicleNo.length() == 0) {
                    throw new Exception("File No, Product Name and Vehicle Number are required for each row.");
                }

                int fileId = Integer.parseInt(fileIdRaw);
                int isRc = 0;
                if (isRcValues != null && i < isRcValues.length && isRcValues[i] != null && isRcValues[i].trim().equals("1")) {
                    isRc = 1;
                }

                String modelYear = (modelYears != null && i < modelYears.length && modelYears[i] != null)
                        ? modelYears[i].trim() : "";
                String purchaseCostRaw = (purchaseCosts != null && i < purchaseCosts.length && purchaseCosts[i] != null)
                        ? purchaseCosts[i].trim() : "0";
                double purchaseCost = 0;
                if (purchaseCostRaw.length() > 0) {
                    purchaseCost = Double.parseDouble(purchaseCostRaw);
                }

                pt.setInt(1, fileId);
                pt.setString(2, productName);
                pt.setString(3, vehicleNo);
                pt.setInt(4, isRc);
                pt.setString(5, modelYear);
                pt.setDouble(6, purchaseCost);
                pt.setString(7, invDate);
                pt.setString(8, purchaseRemark);
                pt.setInt(9, uid);
                pt.setInt(10, supplierId);
                pt.setInt(11, storeId);
                pt.addBatch();
            }

            pt.executeBatch();
            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public Vector getInventoryPurchases() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();

            String sql = "SELECT i.id, i.inv_date, COALESCE(s.name, '-') AS supplier_name, i.file_id, i.product_name, i.vehicle_number, "
                    + "COALESCE(i.is_rc, 0) AS is_rc, COALESCE(i.model, '-') AS model_year, COALESCE(i.purchase_cost, 0) AS purchase_cost, "
                    + "COALESCE(i.purchase_remark, '-') AS purchase_remark, COALESCE(i.supplier_id, 0) AS supplier_id "
                    + "FROM inventory i "
                    + "LEFT JOIN inv_supplier s ON s.id = i.supplier_id "
                    + "ORDER BY i.id DESC";

            pt = con.prepareStatement(sql);
            rs = pt.executeQuery();

            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                row.addElement(rs.getString(7));
                row.addElement(rs.getString(8));
                row.addElement(rs.getString(9));
                row.addElement(rs.getString(10));
                row.addElement(rs.getString(11));
                major.addElement(row);
            }

            return major;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public Vector getInventoryPurchaseById(int id) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector row = new Vector();

            String sql = "SELECT id, inv_date, COALESCE(supplier_id, 0), file_id, product_name, vehicle_number, COALESCE(is_rc, 0), "
                    + "COALESCE(model, ''), COALESCE(purchase_cost, 0), COALESCE(purchase_remark, '') "
                    + "FROM inventory WHERE id = ?";
            pt = con.prepareStatement(sql);
            pt.setInt(1, id);
            rs = pt.executeQuery();

            if (rs.next()) {
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                row.addElement(rs.getString(7));
                row.addElement(rs.getString(8));
                row.addElement(rs.getString(9));
                row.addElement(rs.getString(10));
            }
            return row;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public void editInventoryPurchase(int id, String invDate, int supplierId, int fileId, String productName,
                                      String vehicleNumber, int isRc, String modelYear,
                                      double purchaseCost, String purchaseRemark) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            String sql = "UPDATE inventory SET inv_date=?, supplier_id=?, file_id=?, product_name=?, vehicle_number=?, is_rc=?, model=?, purchase_cost=?, purchase_remark=? WHERE id=?";
            pt = con.prepareStatement(sql);
            pt.setString(1, invDate);
            pt.setInt(2, supplierId);
            pt.setInt(3, fileId);
            pt.setString(4, productName);
            pt.setString(5, vehicleNumber);
            pt.setInt(6, isRc);
            pt.setString(7, modelYear);
            pt.setDouble(8, purchaseCost);
            pt.setString(9, purchaseRemark);
            pt.setInt(10, id);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }

    public Vector getInventoryPurchaseReport(String fromDate, String toDate, int supplierId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();

            String sql = "SELECT i.id, i.inv_date, COALESCE(s.name, '-') AS supplier_name, i.file_id, i.product_name, i.vehicle_number, "
                    + "COALESCE(i.is_rc, 0) AS is_rc, COALESCE(i.model, '-') AS model_year, COALESCE(i.purchase_cost, 0) AS purchase_cost, "
                    + "COALESCE(i.purchase_remark, '-') AS purchase_remark, i.dateTime, "
                    + "COALESCE((SELECT SUM(e.amount) FROM inv_expense_entry e WHERE e.bike_id = i.id AND e.is_active = 1), 0) AS expense_total "
                    + "FROM inventory i "
                    + "LEFT JOIN inv_supplier s ON s.id = i.supplier_id "
                    + "WHERE i.inv_date BETWEEN ? AND ? ";

            if (supplierId > 0) {
                sql += "AND i.supplier_id = ? ";
            }

            sql += "ORDER BY i.inv_date DESC, i.id DESC";

            pt = con.prepareStatement(sql);
            pt.setString(1, fromDate);
            pt.setString(2, toDate);
            if (supplierId > 0) {
                pt.setInt(3, supplierId);
            }

            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                row.addElement(rs.getString(7));
                row.addElement(rs.getString(8));
                row.addElement(rs.getString(9));
                row.addElement(rs.getString(10));
                row.addElement(rs.getString(11));
                row.addElement(rs.getString(12));
                major.addElement(row);
            }

            return major;
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
                con = null;
            }
        }
    }

    public Vector getUnsoldInventory() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();

            String sql = "SELECT i.id, i.inv_date, COALESCE(s.name, '-') AS supplier_name, i.file_id, i.product_name, "
                    + "i.vehicle_number, COALESCE(i.is_rc, 0) AS is_rc, COALESCE(i.model, '-') AS model_year, "
                    + "COALESCE(i.purchase_cost, 0) AS purchase_cost, COALESCE(i.store_id, 0) AS store_id, "
                    + "COALESCE(st.name, '-') AS store_name "
                    + "FROM inventory i "
                    + "LEFT JOIN inv_supplier s ON s.id = i.supplier_id "
                    + "LEFT JOIN inv_stores st ON st.id = i.store_id "
                    + "WHERE (i.is_sold = 0 OR i.is_sold IS NULL) "
                    + "ORDER BY i.inv_date DESC, i.id DESC";

            pt = con.prepareStatement(sql);
            rs = pt.executeQuery();

            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                row.addElement(rs.getString(7));
                row.addElement(rs.getString(8));
                row.addElement(rs.getString(9));
                row.addElement(rs.getString(10));
                row.addElement(rs.getString(11));
                major.addElement(row);
            }

            return major;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }

    public void markAsSold(int id, double saleAmount, String soldDate, String saleRemark, int soldUid) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            String sql = "UPDATE inventory SET is_sold=1, sale_amount=?, sold_date=?, sold_entry_datetime=NOW(), sold_uid=?, sale_remark=? WHERE id=?";
            pt = con.prepareStatement(sql);
            pt.setDouble(1, saleAmount);
            pt.setString(2, soldDate);
            pt.setInt(3, soldUid);
            pt.setString(4, saleRemark);
            pt.setInt(5, id);
            pt.executeUpdate();

            con.commit();
        } catch (Exception e) {
            if (con != null) { con.rollback(); }
            throw e;
        } finally {
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } }
            if (con != null) { try { con.close(); } catch (Exception e) { } }
        }
    }

    public Vector getInventorySaleReport(String fromDate, String toDate, int supplierId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;

        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();

            String sql = "SELECT i.id, i.inv_date, i.sold_date, COALESCE(s.name, '-') AS supplier_name, i.file_id, "
                    + "i.product_name, i.vehicle_number, COALESCE(i.is_rc, 0) AS is_rc, COALESCE(i.model, '-') AS model_year, "
                    + "COALESCE(i.purchase_cost, 0) AS purchase_cost, COALESCE(i.sale_amount, 0) AS sale_amount, "
                    + "COALESCE(i.sale_remark, '-') AS sale_remark, i.sold_entry_datetime "
                    + "FROM inventory i "
                    + "LEFT JOIN inv_supplier s ON s.id = i.supplier_id "
                    + "WHERE i.is_sold = 1 AND i.sold_date BETWEEN ? AND ? ";

            if (supplierId > 0) {
                sql += "AND i.supplier_id = ? ";
            }

            sql += "ORDER BY i.sold_date DESC, i.id DESC";

            pt = con.prepareStatement(sql);
            pt.setString(1, fromDate);
            pt.setString(2, toDate);
            if (supplierId > 0) {
                pt.setInt(3, supplierId);
            }

            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                row.addElement(rs.getString(7));
                row.addElement(rs.getString(8));
                row.addElement(rs.getString(9));
                row.addElement(rs.getString(10));
                row.addElement(rs.getString(11));
                row.addElement(rs.getString(12));
                row.addElement(rs.getString(13));
                major.addElement(row);
            }

            return major;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }

    public Vector getDashboardStats() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql =
                "SELECT " +
                "  (SELECT COUNT(*) FROM inventory WHERE (is_sold = 0 OR is_sold IS NULL)) AS total_unsold, " +
                "  (SELECT COUNT(*) FROM inventory WHERE is_sold = 1) AS total_sold, " +
                "  (SELECT COALESCE(SUM(purchase_cost),0) FROM inventory) AS total_purchase_cost, " +
                "  (SELECT COALESCE(SUM(sale_amount),0) FROM inventory WHERE is_sold = 1) AS total_sale_amount, " +
                "  (SELECT COALESCE(SUM(amount),0) FROM inv_expense_entry WHERE is_active = 1) AS total_expenses, " +
                "  (SELECT COUNT(*) FROM inventory WHERE is_sold = 1 AND DATE(sold_date) = CURDATE()) AS today_sold, " +
                "  (SELECT COUNT(*) FROM inventory WHERE YEAR(inv_date) = YEAR(CURDATE()) AND MONTH(inv_date) = MONTH(CURDATE())) AS this_month_purchased, " +
                "  (SELECT COUNT(*) FROM inv_supplier WHERE is_active = 1) AS total_suppliers";
            pt = con.prepareStatement(sql);
            rs = pt.executeQuery();
            Vector row = new Vector();
            if (rs.next()) {
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                row.addElement(rs.getString(7));
                row.addElement(rs.getString(8));
            }
            return row;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }

    public Vector getRecentSales(int limit) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();
            String sql =
                "SELECT i.id, i.sold_date, i.product_name, i.vehicle_number, " +
                "COALESCE(i.sale_amount, 0), COALESCE(s.name, '-'), COALESCE(i.purchase_cost, 0) " +
                "FROM inventory i " +
                "LEFT JOIN inv_supplier s ON s.id = i.supplier_id " +
                "WHERE i.is_sold = 1 ORDER BY i.sold_date DESC, i.id DESC LIMIT ?";
            pt = con.prepareStatement(sql);
            pt.setInt(1, limit);
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                row.addElement(rs.getString(6));
                row.addElement(rs.getString(7));
                major.addElement(row);
            }
            return major;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }

    public Vector getMonthlyData() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();
            String sql =
                "SELECT DATE_FORMAT(m.month_date, '%b %Y') AS month_label, " +
                "  COALESCE(p.purchase_count, 0), " +
                "  COALESCE(s.sold_count, 0), " +
                "  COALESCE(s.sale_amount, 0), " +
                "  COALESCE(p.purchase_cost, 0) " +
                "FROM ( " +
                "  SELECT DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL n MONTH), '%Y-%m-01') AS month_date " +
                "  FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) nums " +
                ") m " +
                "LEFT JOIN ( " +
                "  SELECT DATE_FORMAT(inv_date, '%Y-%m-01') AS mo, COUNT(*) AS purchase_count, SUM(purchase_cost) AS purchase_cost " +
                "  FROM inventory GROUP BY mo " +
                ") p ON p.mo = m.month_date " +
                "LEFT JOIN ( " +
                "  SELECT DATE_FORMAT(sold_date, '%Y-%m-01') AS mo, COUNT(*) AS sold_count, SUM(sale_amount) AS sale_amount " +
                "  FROM inventory WHERE is_sold = 1 GROUP BY mo " +
                ") s ON s.mo = m.month_date " +
                "ORDER BY m.month_date ASC";
            pt = con.prepareStatement(sql);
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                major.addElement(row);
            }
            return major;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }

    public Vector getTopSuppliers() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();
            String sql =
                "SELECT s.name, " +
                "  COUNT(i.id) AS total_bikes, " +
                "  SUM(CASE WHEN i.is_sold = 1 THEN 1 ELSE 0 END) AS sold_bikes, " +
                "  SUM(CASE WHEN (i.is_sold = 0 OR i.is_sold IS NULL) THEN 1 ELSE 0 END) AS unsold_bikes, " +
                "  COALESCE(SUM(i.purchase_cost), 0) AS total_purchase " +
                "FROM inv_supplier s " +
                "LEFT JOIN inventory i ON i.supplier_id = s.id " +
                "WHERE s.is_active = 1 " +
                "GROUP BY s.id, s.name " +
                "ORDER BY total_bikes DESC LIMIT 8";
            pt = con.prepareStatement(sql);
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                major.addElement(row);
            }
            return major;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }

    public double getUnsoldStockValue() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            pt = con.prepareStatement(
                "SELECT COALESCE(SUM(purchase_cost), 0) FROM inventory WHERE (is_sold = 0 OR is_sold IS NULL)");
            rs = pt.executeQuery();
            if (rs.next()) return Double.parseDouble(rs.getString(1));
            return 0;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }

    public void addExpenseEntry(int bikeId, String content, double amount, String description, String excDateTime, int uid) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            String sql = "INSERT INTO inv_expense_entry(bike_id, content, amount, description, exc_date_time, entry_date_time, is_active, uid) VALUES (?, ?, ?, ?, ?, NOW(), 1, ?)";
            pt = con.prepareStatement(sql);
            pt.setInt(1, bikeId);
            pt.setString(2, content);
            pt.setDouble(3, amount);
            pt.setString(4, description);
            if (excDateTime != null && excDateTime.trim().length() > 0) {
                pt.setString(5, excDateTime);
            } else {
                pt.setNull(5, java.sql.Types.TIMESTAMP);
            }
            pt.setInt(6, uid);
            pt.executeUpdate();
            con.commit();
        } catch (Exception e) {
            if (con != null) { con.rollback(); }
            throw e;
        } finally {
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } }
            if (con != null) { try { con.close(); } catch (Exception e) { } }
        }
    }

    public Vector getExpensesByBikeId(int bikeId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector major = new Vector();
            pt = con.prepareStatement(
                "SELECT id, content, amount, COALESCE(description, '') AS description, " +
                "COALESCE(exc_date_time, '') AS exc_date_time " +
                "FROM inv_expense_entry WHERE bike_id = ? AND is_active = 1 ORDER BY id DESC");
            pt.setInt(1, bikeId);
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));
                row.addElement(rs.getString(2));
                row.addElement(rs.getString(3));
                row.addElement(rs.getString(4));
                row.addElement(rs.getString(5));
                major.addElement(row);
            }
            return major;
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) { } rs = null; }
            if (pt != null) { try { pt.close(); } catch (SQLException e) { } pt = null; }
            if (con != null) { try { con.close(); } catch (Exception e) { } con = null; }
        }
    }
}

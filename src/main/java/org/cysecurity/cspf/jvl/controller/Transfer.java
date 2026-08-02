package org.cysecurity.cspf.jvl.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.cysecurity.cspf.jvl.model.DBConnect;

/**
 * Wallet transfer between accounts.
 *
 * VULNERABLE (A10 Mishandling of Exceptional Conditions - CWE-460, CWE-703):
 * the recipient is credited first, then the sender is debited to settle, with no
 * transaction and no rollback. When settlement fails (insufficient funds), the code
 * throws to abort, but the already-committed credit is never rolled back, so money is
 * created out of nothing and the ledger is left in a corrupt, inconsistent state.
 */
public class Transfer extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String ctx = request.getContextPath();
        try {
            HttpSession session = request.getSession();
            String from = (String) session.getAttribute("user");
            String to = request.getParameter("to");
            String amountStr = request.getParameter("amount");

            if (from == null || to == null || amountStr == null || request.getParameter("send") == null) {
                response.sendRedirect(ctx + "/vulnerability/transfer/index.jsp");
                return;
            }

            int amount = Integer.parseInt(amountStr);
            Connection con = new DBConnect().connect(getServletContext().getRealPath("/WEB-INF/config.properties"));
            if (con != null && !con.isClosed()) {
                // The recipient is credited instantly, then the transfer is "settled" by
                // debiting the sender. There is NO transaction wrapping the two steps and
                // NO rollback, so a failed settlement leaves the credit standing.

                // Step 1: credit the recipient -- commits immediately (auto-commit is on)
                PreparedStatement credit = con.prepareStatement(
                        "UPDATE users SET balance = balance + ? WHERE username = ?");
                credit.setInt(1, amount);
                credit.setString(2, to);
                credit.executeUpdate();

                // Step 2: settle by debiting the sender, only if the funds are there
                PreparedStatement debit = con.prepareStatement(
                        "UPDATE users SET balance = balance - ? WHERE username = ? AND balance >= ?");
                debit.setInt(1, amount);
                debit.setString(2, from);
                debit.setInt(3, amount);
                if (debit.executeUpdate() != 1) {
                    // Settlement failed (insufficient funds). The code detects it and aborts,
                    // but the credit in Step 1 already committed and is never rolled back.
                    throw new IllegalStateException("settlement failed: insufficient funds");
                }

                con.close();
            }
            response.sendRedirect(ctx + "/vulnerability/transfer/index.jsp");
        } catch (Exception ex) {
            response.sendRedirect(ctx + "/vulnerability/transfer/index.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Wallet transfer (A10 incomplete-rollback demo)";
    }
}

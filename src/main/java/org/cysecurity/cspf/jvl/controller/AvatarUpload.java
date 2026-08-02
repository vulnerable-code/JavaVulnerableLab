package org.cysecurity.cspf.jvl.controller;

import java.io.File;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * A06 Insecure Design (CWE-434): a "profile picture" upload whose design never
 * restricts the file type, size, or destination. Any file, including an
 * executable JSP, is written under the web root with its original name, so it
 * can be requested and run as a web shell.
 */
public class AvatarUpload extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("isLoggedIn") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String uploadDir = getServletContext().getRealPath("/uploads");
        new File(uploadDir).mkdirs();

        String message = "No file received.";
        try {
            ServletFileUpload upload = new ServletFileUpload(new DiskFileItemFactory());
            List<FileItem> items = upload.parseRequest(request);
            for (FileItem item : items) {
                if (!item.isFormField() && item.getName() != null && !item.getName().isEmpty()) {
                    // VULNERABLE BY DESIGN: the client filename and extension are
                    // trusted as-is. No type / extension / content validation.
                    String fileName = new File(item.getName()).getName();
                    File stored = new File(uploadDir, fileName);
                    item.write(stored);
                    message = "Uploaded to " + request.getContextPath() + "/uploads/" + fileName;
                }
            }
        } catch (Exception e) {
            message = "Upload failed: " + e.getMessage();
        }
        request.setAttribute("uploadMessage", message);
        request.getRequestDispatcher("/vulnerability/upload/avatar.jsp").forward(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/vulnerability/upload/avatar.jsp").forward(request, response);
    }
}

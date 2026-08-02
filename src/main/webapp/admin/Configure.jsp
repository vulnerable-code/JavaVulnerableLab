 <%@page import="java.io.FileOutputStream"%>
<%@ include file="/header.jsp" %>
 <%
 if(session.getAttribute("isLoggedIn")!=null)
{

 %> 
<%
     Properties current=new Properties();
     FileInputStream currentIn=new FileInputStream(configPath);
     current.load(currentIn);
     currentIn.close();
     boolean debugOn="true".equalsIgnoreCase(current.getProperty("debug","false"));
 %>
  <form action="Configure.jsp" method="POST">
<table>
    <tr><td>Website Title:</td> <td><input type="text" name="siteTitle" value="<%= current.getProperty("siteTitle","") %>"/></td></tr>
    <tr><td>Debug mode:</td> <td><input type="checkbox" name="debug" value="true"<%= debugOn ? " checked=\"checked\"" : "" %>/>
        show developer error pages to users (Django <code>DEBUG</code> / Laravel <code>APP_DEBUG</code>)</td></tr>
    <tr><td></td><td><input type="submit" name="save" value="save"/></td></tr>
</table>
</form>

 <%
     if(request.getParameter("save")!=null)
    {
        Properties props=new Properties();

        props.load(new FileInputStream(configPath));
        props.setProperty("siteTitle",request.getParameter("siteTitle"));
        props.setProperty("debug", request.getParameter("debug")!=null ? "true" : "false");
        FileOutputStream fileout = new FileOutputStream(configPath);
        props.store(fileout, null);
        fileout.close();
        out.print("<b class='success'> Configuration saved </b>");
    }
  }
 else
 {
     out.print("<b style='color:red'> x You Are not Authorized to view this Page x </b>");
 }
 %>
 <%@ include file="/footer.jsp" %>
<%--
    WidgetSource.jsp  -  demo control for the third-party promo widget
    [supports the A08 / CWE-830 demo in vulnerability/integrity/checkout.jsp]

    THIS SCREEN IS NOT THE VULNERABILITY. It is an admin-only setting that
    writes the widget's script URL (and its optional Subresource Integrity
    hash) into WEB-INF/config.properties, so a presenter can repoint the
    checkout page at another host without redeploying the application.

    In a real application there is no such screen: a developer pastes the
    vendor's <script src="https://cdn.example/widget.js"> into the page once,
    during development, and the browser then executes whatever that host
    serves for as long as the page exists. This form only compresses that
    timeline into something you can show in two minutes.
--%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.util.Properties"%>
<%@ include file="/WEB-INF/widget-source.jspf" %>
<%
    boolean isAdmin = session.getAttribute("privilege") != null
            && session.getAttribute("privilege").equals("admin");
    String saveMessage = null;

    if (isAdmin && (request.getParameter("save") != null || request.getParameter("reset") != null)) {
        String propsPath = getServletContext().getRealPath("/WEB-INF/config.properties");
        Properties stored = new Properties();
        FileInputStream propsIn = new FileInputStream(propsPath);
        stored.load(propsIn);
        propsIn.close();

        // Empty means "derive from the host the browser used", so Restore
        // default clears both settings rather than pinning today's URL.
        String newUrl = "";
        String newSri = "";
        if (request.getParameter("reset") == null) {
            String urlParam = request.getParameter("scriptUrl");
            String sriParam = request.getParameter("integrity");
            if (urlParam != null) {
                newUrl = urlParam.trim();
            }
            if (sriParam != null) {
                newSri = sriParam.trim();
            }
        }
        stored.setProperty(WIDGET_URL_KEY, newUrl);
        stored.setProperty(WIDGET_SRI_KEY, newSri);

        FileOutputStream propsOut = new FileOutputStream(propsPath);
        stored.store(propsOut, null);
        propsOut.close();

        saveMessage = "Widget source saved. Reload the checkout page to load it.";
    }
%>
<%@ include file="/header.jsp" %>
<%
    // header.jsp re-reads config.properties on every request, so this is the value
    // the checkout page will use from now on.
    String currentUrl = widgetSetting(properties, WIDGET_URL_KEY, defaultWidgetUrl(request));
    String currentSri = widgetSetting(properties, WIDGET_SRI_KEY, "");
    String propsFile = getServletContext().getRealPath("/WEB-INF/config.properties");

    // Raw, exactly as checkout.jsp emits it; escaped once where it is printed.
    String renderedTag = "<script src=\"" + currentUrl + "\"";
    if (currentSri.length() > 0) {
        renderedTag += " integrity=\"" + currentSri + "\" crossorigin=\"anonymous\"";
    }
    renderedTag += "></" + "script>";

    if (!isAdmin) {
        out.print("<b class='fail'> x You Are not Authorized to view this Page x </b>"
                + "<br/><br/>Log in at <a href='adminlogin.jsp'>adminlogin.jsp</a>"
                + " as <code>admin</code> / <code>admin</code> first.");
    } else {
%>

<h3>Promotions widget source</h3>
Which third-party script <a href="<%=path%>/vulnerability/integrity/checkout.jsp">Checkout</a>
loads, and whether the browser is told to verify it.<br/><br/>

<% if (saveMessage != null) { %>
    <b class="success"><%= esc(saveMessage) %></b><br/><br/>
<% } %>

<form action="WidgetSource.jsp" method="POST">
<table>
    <tr>
        <td>Script URL:</td>
        <td><input type="text" name="scriptUrl" size="60" value="<%= esc(currentUrl) %>"/><br/>
            <span class="smaller">empty = the demo widget server on this same host,
            <code><%= esc(defaultWidgetUrl(request)) %></code></span></td>
    </tr>
    <tr>
        <td>Subresource Integrity:</td>
        <td><input type="text" name="integrity" size="60" value="<%= esc(currentSri) %>"
                   placeholder="empty = no verification, e.g. sha384-..."/></td>
    </tr>
    <tr>
        <td></td>
        <td>
            <input type="submit" name="save" value="Save"/>
            <input type="submit" name="reset" value="Restore default"/>
        </td>
    </tr>
</table>
</form>
<br/>

<b>Checkout will render exactly this:</b>
<pre><%= esc(renderedTag) %></pre>
<a href="<%=path%>/vulnerability/integrity/checkout.jsp">Open Checkout &rarr;</a>

<div class="labnote">
<span class="labnote-title">Lab notes &middot; not part of the page</span>

<b class="fail">This page is not the vulnerability.</b> It exists so the script
source can be repointed live during the demo. The bug is in
<code>vulnerability/integrity/checkout.jsp</code>, which executes whatever that
URL returns without ever verifying it. In production the same tag is written
once by a developer and never revisited, and the owner of that host keeps the
ability to change what runs in your users' browsers.
<br/><br/>

Leave <b>Subresource Integrity</b> empty to see the attack. Fill it with the
<code>sha384-...</code> hash of the file you reviewed to see the browser refuse
a swapped one. The demo server prints that hash for whatever it is serving; by
hand it is the base64 of the file's SHA-384 digest:<br/>
<code>openssl dgst -sha384 -binary promo-widget.js | openssl base64 -A</code>
<br/>then prefix it with <code>sha384-</code>.
<br/><br/>

Both values live in <code><%= esc(propsFile) %></code> as
<code>widgetScriptUrl</code> / <code>widgetScriptIntegrity</code>. You never need
to open that file, this form is the only thing that writes it. To read it from
outside the container:<br/>
<code>docker exec &lt;jvl container&gt; cat <%= esc(propsFile) %></code>
</div>

<%
    }
%>
<%@ include file="/footer.jsp" %>

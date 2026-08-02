 <%@page import="java.io.FileInputStream"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.File"%>
<%
   String path = request.getContextPath();
   String configPath=getServletContext().getRealPath("/WEB-INF/config.properties");

    Properties properties=new Properties();
    properties.load(new FileInputStream(configPath));
    String siteTitle=properties.getProperty("siteTitle");
     %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title><%=siteTitle%></title>
	<link rel="icon" href="<%=path%>/favicon.svg" type="image/svg+xml" />
	<link rel="icon" href="<%=path%>/favicon.ico" sizes="any" />
	<link rel="apple-touch-icon" href="<%=path%>/apple-touch-icon.png" />
	<link rel="stylesheet" href="<%=path%>/style.css" type="text/css" charset="utf-8" />
           <% out.print("<script src=\""+path+"/jquery.min.js\" type=\"text/javascript\"></script>"); %>
</head>

<body>
<div id="container" >

     <div id="Menu">
		<ul id="menu-bar" style="margin-left: auto ;  margin-right: auto ;" >
			<%-- The main nav is built with response.encodeURL(), which is what an app
			     with URL session tracking enabled does everywhere. For a browser that
			     returns a cookie it is a no-op; for a client whose session id arrived
			     in the URL it re-appends ;jsessionid= so the session survives the click. --%>
			<li class="current"><a href="<%= response.encodeURL(path + "/") %>">Home</a></li>

			<li><a href="#">Vulnerability</a>
				<ul>
					<li><a href="#">A01- Broken Access Control</a>
						<ul>
							<li><a href="#">Insecure Direct Object Reference (IDOR)</a>
								<ul>
									<li><a href="<%=path%>/myprofile.jsp?id=<% if(session.getAttribute("userid")!=null){ out.print(session.getAttribute("userid"));} %>" title="Make sure you have logged in ">Viewing Details</a></li>
									<li><a href="<%=path%>/vulnerability/idor/change-email.jsp" title="Make sure you have logged in ">Modifying email ID</a></li>
								</ul>
							</li>
							<li><a href="<%=path%>/vulnerability/idor/download.jsp">Path Traversal: Download Document</a></li>
							<li><a href="#">Missing Function-Level Access Control</a>
								<ul>
									<li><a href="<%=path%>/admin/" title="Hint: Forced Browsing">Bypass Admin Login</a></li>
									<li><a href="<%=path%>/admin/AddPage.jsp">Add Page</a></li>
									<li><a href="<%=path%>/admin/Configure.jsp">Configure</a></li>
									<li><a href="<%=path%>/vulnerability/mfac/SearchEngines.jsp">Crawlers</a></li>
								</ul>
							</li>
							<li><a href="<%=path%>/vulnerability/baac/index.jsp" title="Make sure you have logged in">Privilege Escalation (JWT claim tampering)</a></li>
							<li><a href="<%=path%>/vulnerability/baasm/SiteTitle.jsp">Privilege Escalation (cookie)</a></li>
							<li><a href="#">Cross-Site Request Forgery (CSRF)</a>
								<ul>
									<li><a href="<%=path%>/vulnerability/csrf/change-info.jsp">CSRF (GET): Change Info</a></li>
									<li><a href="<%=path%>/vulnerability/csrf/changepassword.jsp">CSRF (POST): Change Password</a></li>
								</ul>
							</li>
							<li><a href="<%=path%>/vulnerability/ssrf/URLPreview.jsp">Server-Side Request Forgery (SSRF)</a></li>
							<li><a href="#">Unvalidated Redirect &amp; Forward</a>
								<ul>
									<li><a href="<%=path%>/vulnerability/unvalidated/OpenURL.jsp">Open Redirect</a></li>
									<li><a href="<%=path%>/vulnerability/unvalidated/OpenForward.jsp">Open Forward</a></li>
								</ul>
							</li>
						</ul>
					</li>

					<li><a href="#">A02- Security Misconfiguration</a>
						<ul>
							<li><a href="<%=path%>/install.jsp">Setup Page not removed</a></li>
							<li><a href="<%=path%>/admin/">Default Admin Credentials not changed</a></li>
							<li><a href="<%=path%>/backup/">Directory Listing (browse /backup/)</a></li>
							<li><a href="<%=path%>/vulnerability/debugmode/orders.jsp">Debug Mode Enabled in Production</a></li>
							<li><a href="<%=path%>/vulnerability/Injection/xxe.jsp">XML External Entity (XXE)</a></li>
						</ul>
					</li>

					<li><a href="#">A03- Software Supply Chain Failures</a>
						<ul>
							<li><a href="/VulnerableSpring/error.htm?msg=error.c403">Web Application using Spring Framework</a></li>
							<li><a href="<%=path%>/vulnerability/log4shell/Search.jsp">Log4Shell (Log4j CVE-2021-44228)</a></li>
						</ul>
					</li>

					<li><a href="#">A04- Cryptographic Failures</a>
						<ul>
							<li><a href="<%=path%>/changeCardDetails.jsp">Cleartext Transmission of Card Data</a></li>
							<li><a href="<%=path%>/ForgotPassword.jsp">Plaintext Password Storage</a></li>
							<li><a href="<%=path%>/login.jsp">Credentials Stored in a Cookie</a></li>
							<li><a href="<%=path%>/vulnerability/sde/hash.jsp">Weak Password Hashing (MD5)</a></li>
						</ul>
					</li>

					<li><a href="#">A05- Injection</a>
						<ul>
							<li><a href="#">SQL Injection</a>
								<ul>
									<li><a href="<%=path%>/vulnerability/forumposts.jsp?postid=1">SQL Injection 1</a></li>
									<li><a href="<%=path%>/login.jsp">Authentication Bypass</a></li>
									<li><a href="<%=path%>/vulnerability/sqli/download.jsp">Blind SQLi</a></li>
									<li><a href="<%=path%>/vulnerability/sqli/union2.jsp">Union-based</a></li>
								</ul>
							</li>
							<li><a href="<%=path%>/vulnerability/Injection/ping.jsp">OS Command Injection (Ping)</a></li>
							<li><a href="<%=path%>/vulnerability/Injection/xpath_login.jsp">XPath Injection</a></li>
							<li><a href="<%=path%>/vulnerability/Injection/xslt.jsp?style=1.xsl">XSLT Injection</a></li>
							<li><a href="<%=path%>/vulnerability/Injection/orm.jsp?id=1">ORM Injection</a></li>
							<li><a href="#">Cross-Site Scripting (XSS)</a>
								<ul>
									<li><a href="<%=path%>/vulnerability/xss/search.jsp">Reflected 1</a></li>
									<li><a href="<%=path%>/vulnerability/xss/xss4.jsp">Reflected 2</a></li>
									<li><a href="<%=path%>/vulnerability/xss/xss5.jsp">Reflected 3</a></li>
									<li><a href="<%=path%>/vulnerability/xss/flash/exss.jsp">Flash-based</a></li>
									<li><a href="<%=path%>/vulnerability/forum.jsp">Stored (Persistent)</a></li>
								</ul>
							</li>
						</ul>
					</li>

					<li><a href="#">A06- Insecure Design</a>
						<ul>
							<li><a href="<%=path%>/ForgotPassword.jsp">Credential Recovery via Security Question</a></li>
							<li><a href="<%=path%>/vulnerability/upload/avatar.jsp" title="Make sure you have logged in">Unrestricted File Upload</a></li>
								<li><a href="<%=path%>/vulnerability/otp/transfer.jsp" title="Make sure you have logged in">Client-Side Enforcement: OTP Step-Up Bypass</a></li>
						</ul>
					</li>

					<li><a href="#">A07- Authentication Failures</a>
						<ul>
							<li><a href="<%=path%>/login.jsp">Brute Force / No Lockout</a></li>
							<li><a href="<%=path%>/ForgotPassword.jsp">Username Enumeration</a></li>
							<li><a href="<%=path%>/vulnerability/csrf/changepassword.jsp" title="Make sure you have logged in">Unverified Password Change</a></li>
							<li><a href="<%=path%>/vulnerability/baasm/URLRewriting.jsp;jsessionid=<%=session.getId()%>">Session Fixation via URL Rewriting</a></li>
							<li><a href="<%=path%>/vulnerability/clientsecrets/integrations.jsp">Hard-coded API Keys in Front-end JS</a></li>
						</ul>
					</li>

					<li><a href="#">A08- Software &amp; Data Integrity Failures</a>
						<ul>
							<li><a href="<%=path%>/vulnerability/deserialize/preferences.jsp">Insecure Java Deserialization (RCE)</a></li>
							<li><a href="<%=path%>/vulnerability/integrity/checkout.jsp">Inclusion of Web Functionality from an Untrusted Source</a></li>
						</ul>
					</li>

					<li><a href="#">A09- Security Logging &amp; Alerting Failures</a>
						<ul>
							<li><a href="<%=path%>/vulnerability/loginjection/activity.jsp" title="Make sure you have logged in">Log Injection (frame another user)</a></li>
						</ul>
					</li>

					<li><a href="#">A10- Mishandling of Exceptional Conditions</a>
						<ul>
							<li><a href="<%=path%>/vulnerability/securitymisconfig/pages.jsp?id=1">Unhandled Exception: Stack Trace Leak</a></li>
								<li><a href="<%=path%>/vulnerability/failopen/report.jsp">Fail-Open Access Check (swallowed exception)</a></li>
								<li><a href="<%=path%>/vulnerability/transfer/index.jsp" title="Make sure you have logged in">Incomplete Rollback (corrupt balance)</a></li>						</ul>
					</li>

				</ul></li>
			<li><a href="<%= response.encodeURL(path + "/vulnerability/forum.jsp") %>">Forum</a></li>
				<%
                                if(session.getAttribute("isLoggedIn")!=null && session.getAttribute("isLoggedIn").equals("1"))
                                {
                                    if(session.getAttribute("privilege")!=null && session.getAttribute("privilege").equals("admin"))
                                    {
                                       out.print("<li><a href='"+response.encodeURL(path+"/admin/admin.jsp")+"'>Admin Panel</a></li>");
                                    }
                                    out.print("<li><a href='"+response.encodeURL(path+"/myprofile.jsp?id="+session.getAttribute("userid"))+"'>My Profile</a></li>");
                                     out.print("<li><a href='"+response.encodeURL(path+"/Logout")+"'>Logout</a></li>");
                                }
                                else
                                {
                                   out.print("<li><a href='"+response.encodeURL(path+"/login.jsp")+"'>LogIn</a></li>");
                                    out.print("<li><a href='"+response.encodeURL(path+"/Register.jsp")+"'>Register</a></li>");
                                }
                                %>
		</ul>
	</div>

	<div id="Main-Container">
	<div id="logo">

<h1><%=siteTitle%></h1>
</div>

			<div id="Main">


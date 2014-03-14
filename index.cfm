﻿<!---
/**
 * OWASP Enterprise Security API for ColdFusion/CFML (ESAPI4CF)
 *
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2011-2014, The OWASP Foundation
 *
 * The ESAPI is published by OWASP under the BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 */
--->
<cfscript>
	Version = createObject("component", "org.owasp.esapi.util.Version");

	serverVersion = "CF " & server.coldfusion.ProductVersion;
	if(structKeyExists(server, "railo")) {
		serverVersion = "Railo " & server.railo.version;
	}
</cfscript>

<cfoutput>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>#Version.getESAPI4CFName()# #Version.getESAPI4CFVersion()# [#serverVersion#]</title>
<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
</head>
<body>

<div class="container">

	<div class="page-header">
		<h1>#Version.getESAPI4CFName()# <small>ESAPI for ColdFusion/CFML</small></h1>
	</div>

	<div class="row">
		<div class="col-md-8">

			<h2>Documentation</h2>
			<p>Compatibility information, setup, tutorials, API reference, and links to latest download are available here: <a href="http://damonmiller.github.io/esapi4cf/">http://damonmiller.github.io/esapi4cf/</a></p>

			<h2>Release Notes</h2>
			<p>Information on bug fixes and improvements for each release are available here: <a href="https://github.com/damonmiller/esapi4cf/releases">https://github.com/damonmiller/esapi4cf/releases</a></p>

		</div>
		<div class="col-md-4">

			<div class="panel panel-success">
				<div class="panel-heading"><h4>Under The Hood...</h4></div>
				<div class="panel-body">
					<ul class="list-unstyled">
						<li><strong>CFML Server:</strong> #serverVersion#</li>
						<li><strong>#Version.getESAPI4CFName()# Version:</strong> #Version.getESAPI4CFVersion()#</li>
						<li><strong>ESAPI4J Version:</strong> #Version.getESAPI4JVersion()#</li>
					</ul>
				</div>
			</div>

		</div>
	</div>

	<h2>Issues</h2>
	<p>You can find known issues or report new issues here: <a href="https://github.com/damonmiller/esapi4cf/issues">https://github.com/damonmiller/esapi4cf/issues</a></p>

	<h2>Demos</h2>
	<dl>
		<dt><a href="demo/basic/">Basic Application</a> <span class="label label-info">CF8+</span></dt>
		<dd>This demo application covers usage and testing of the entire ESAPI4CF library.</dd>
	</dl>

	<h2>Tests</h2>
	<dl>
		<dt><a href="test/unit/TestSuite.cfm">Unit Tests</a> <span class="label label-info">CF8+</span></dt>
		<dd>The #Version.getESAPI4CFName()# Unit TestSuite using <a href="http://mxunit.org/">MXUnit</a> (not included).</dd>
	</dl>
	<form class="form-inline" role="form" method="get" action="test/automation/TestSuite.cfm">
		<fieldset>
			<legend>Automation Tests</legend>
			<p>Automated testing against the #Version.getESAPI4CFName()# demo app courtesy of <a href="https://github.com/bobsilverberg/CFSelenium">CFSelenium</a> (not included) and <a href="http://mxunit.org/">MXUnit</a> (not included).</p>
			<div class="form-group">
				<label class="control-label" for="engine">CFML Engine</label>
				<select class="form-control" id="engine" name="engine">
					<option value="railo">Railo</option>
				</select>
			</div>
			<div class="form-group">
				<label class="control-label" for="browser">Browser</label>
				<select class="form-control" id="browser" name="browser">
					<option value="chrome">Chrome</option>
				</select>
			</div>
			<button type="submit" class="btn btn-primary">Run Test</button>
		</fieldset>
	</form>

	<h2>Utilities</h2>
	<dl>
		<dt><a href="utilities/DefaultEncryptedProperties.cfm">Encrypted Properties files</a> <span class="label label-info">CF8+</span></dt>
		<dd>Loads encrypted properties file based on the location passed in args then prompts the user to input key-value pairs.</dd>
		<dt><a href="utilities/FileBasedAuthenticator.cfm">Fail safe main program to add or update an account in an emergency</a> <span class="label label-info">CF8+</span></dt>
		<dd>WARNING: this method does not perform the level of validation and checks generally required in #Version.getESAPI4CFName()#, and can therefore be used to create a username and password that do not comply with the username and password strength requirements.</dd>
	</dl>

</div>

<script src="//code.jquery.com/jquery-2.1.0.min.js"></script>
<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
</body>
</html>
</cfoutput>
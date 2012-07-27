<!---
 * OWASP Enterprise Security API (ESAPI)
 *
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2007 - The OWASP Foundation
 *
 * The ESAPI is published by OWASP under the BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 *
 * @author Jeff Williams <a href="http://www.aspectsecurity.com">Aspect Security</a>
 * @created 2007
 --->
<!---
 * Reference implementation of the User interface. This implementation is serialized into a flat file in a simple format.
 *
 * @author Jeff Williams (jeff.williams .at. aspectsecurity.com) <a
 *         href="http://www.aspectsecurity.com">Aspect Security</a>
 * @since June 1, 2007
 * @see org.owasp.esapi.User
 --->
<cfcomponent implements="cfesapi.org.owasp.esapi.User" extends="cfesapi.org.owasp.esapi.util.Object" output="false">

	<cfscript>
		instance.ESAPI = "";

		/** The idle timeout length specified in the ESAPI config file. */
		instance.IDLE_TIMEOUT_LENGTH = 20;

		/** The absolute timeout length specified in the ESAPI config file. */
		instance.ABSOLUTE_TIMEOUT_LENGTH = 120;

		/** The logger used by the class. */
		instance.logger = "";

		/** This user's account id. */
		this.accountId = 0;

		/** This user's account name. */
		instance.accountName = "";

		/** This user's screen name (account name alias). */
		instance.screenName = "";

		/** This user's CSRF token. */
		instance.csrfToken = "";

		/** This user's assigned roles. */
		instance.roles = [];

		/** Whether this user's account is locked. */
		instance.locked = false;

		/** Whether this user is logged in. */
		instance.loggedIn = true;

		/** Whether this user's account is enabled. */
		instance.enabled = false;

		/** The last host address used by this user. */
		instance.lastHostAddress = "";

		/** The last password change time for this user. */
		instance.lastPasswordChangeTime = getJava( "java.util.Date" ).init( javaCast( "long", 0 ) );

		/** The last login time for this user. */
		instance.lastLoginTime = getJava( "java.util.Date" ).init( javaCast( "long", 0 ) );

		/** The last failed login time for this user. */
		instance.lastFailedLoginTime = getJava( "java.util.Date" ).init( javaCast( "long", 0 ) );

		/** The expiration date/time for this user's account. */
		instance.expirationTime = getJava( "java.util.Date" ).init( javaCast( "long", getJava( "java.lang.Long" ).MAX_VALUE ) );

		/** The session's this user is associated with */
		instance.sessions = [];

		/* A flag to indicate that the password must be changed before the account can be used. */
		// instance.requiresPasswordChange = true;
		/** The failed login count for this user's account. */
		instance.failedLoginCount = 0;

		instance.MAX_ROLE_LENGTH = 250;
	</cfscript>

	<cffunction access="public" returntype="DefaultUser" name="init" output="false"
	            hint="Instantiates a new user.">
		<cfargument required="true" type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI"/>
		<cfargument required="true" type="String" name="accountName" hint="The name of this user's account."/>

		<cfscript>
			var local = {};

			instance.ESAPI = arguments.ESAPI;
			instance.IDLE_TIMEOUT_LENGTH = instance.ESAPI.securityConfiguration().getSessionIdleTimeoutLength();
			instance.ABSOLUTE_TIMEOUT_LENGTH = instance.ESAPI.securityConfiguration().getSessionAbsoluteTimeoutLength();
			instance.logger = instance.ESAPI.getLogger( "DefaultUser" );

			setAccountName( arguments.accountName );
			while(true) {
				local.id = javaCast( "long", abs( instance.ESAPI.randomizer().getRandomLong() ) );
				if(!isObject( instance.ESAPI.authenticator().getUserByAccountId( local.id ) ) && local.id != 0) {
					setAccountId( local.id );
					break;
				}
			}

			return this;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="addRole" output="false">
		<cfargument required="true" type="String" name="role"/>

		<cfscript>
			var local = {};

			local.roleName = arguments.role.toLowerCase();
			if(instance.ESAPI.validator().isValidInput( "addRole", local.roleName, "RoleName", instance.MAX_ROLE_LENGTH, false )) {
				instance.roles.add( local.roleName );
				instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Role " & local.roleName & " added to " & getAccountName() );
			}
			else {
				throwException( createObject( "component", "cfesapi.org.owasp.esapi.errors.AuthenticationAccountsException" ).init( instance.ESAPI, "Add role failed", "Attempt to add invalid role " & local.roleName & " to " & getAccountName() ) );
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="addRoles" output="false">
		<cfargument required="true" type="Array" name="newRoles"/>

		<cfscript>
			var local = {};

			for(local.i = 1; local.i <= arrayLen( arguments.newRoles ); local.i++) {
				addRole( arguments.newRoles[local.i] );
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="changePassword" output="false">
		<cfargument required="true" type="String" name="oldPassword"/>
		<cfargument required="true" type="String" name="newPassword1"/>
		<cfargument required="true" type="String" name="newPassword2"/>

		<cfscript>
			instance.ESAPI.authenticator().changePassword( this, arguments.oldPassword, arguments.newPassword1, arguments.newPassword2 );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="disable" output="false">

		<cfscript>
			instance.enabled = false;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Account disabled: " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="enable" output="false">

		<cfscript>
			instance.enabled = true;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Account enabled: " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getAccountId" output="false">

		<cfscript>
			return duplicate( this.accountId );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getAccountName" output="false">

		<cfscript>
			return duplicate( instance.accountName );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getCSRFToken" output="false">

		<cfscript>
			return duplicate( instance.csrfToken );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="Date" name="getExpirationTime" output="false">

		<cfscript>
			return duplicate( instance.expirationTime );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="numeric" name="getFailedLoginCount" output="false">

		<cfscript>
			return duplicate( instance.failedLoginCount );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setFailedLoginCount" output="false"
	            hint="Set the failed login count">
		<cfargument required="true" type="numeric" name="count" hint="the number of failed logins"/>

		<cfscript>
			instance.failedLoginCount = arguments.count;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="Date" name="getLastFailedLoginTime" output="false">

		<cfscript>
			return duplicate( instance.lastFailedLoginTime );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getLastHostAddress" output="false">

		<cfscript>
			if(instance.lastHostAddress == "") {
				return "local";
			}
			return duplicate( instance.lastHostAddress );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="Date" name="getLastLoginTime" output="false">

		<cfscript>
			return duplicate( instance.lastLoginTime );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="Date" name="getLastPasswordChangeTime" output="false">

		<cfscript>
			return duplicate( instance.lastPasswordChangeTime );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getName" output="false">

		<cfscript>
			return getAccountName();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="Array" name="getRoles" output="false">

		<cfscript>
			return duplicate( instance.roles );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="getScreenName" output="false">

		<cfscript>
			return duplicate( instance.screenName );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="addSession" output="false">
		<cfargument required="true" name="s"/>

		<cfscript>
			if(isInstanceOf( arguments.s, "cfesapi.org.owasp.esapi.HttpSession" )) {
				instance.sessions.add( arguments.s );
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="removeSession" output="false">
		<cfargument required="true" name="s"/>

		<cfscript>
			if(isInstanceOf( arguments.s, "cfesapi.org.owasp.esapi.HttpSession" )) {
				instance.sessions.remove( arguments.s );
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="Array" name="getSessions" output="false">

		<cfscript>
			return duplicate( instance.sessions );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="incrementFailedLoginCount" output="false">

		<cfscript>
			instance.failedLoginCount++;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isAnonymous" output="false">

		<cfscript>
			// User cannot be anonymous, since we have a special User.ANONYMOUS instance for the anonymous user
			return false;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isEnabled" output="false">

		<cfscript>
			return instance.enabled;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isExpired" output="false">

		<cfscript>
			return getExpirationTime().before( getJava( "java.util.Date" ).init() );

			// If expiration should happen automatically or based on lastPasswordChangeTime?
			//long from = lastPasswordChangeTime.getTime();
			//long to = getJava("java.util.Date").init().getTime();
			//double difference = to - from;
			//long days = Math.round((difference / (1000 * 60 * 60 * 24)));
			//return days > 60;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isInRole" output="false">
		<cfargument required="true" type="String" name="role"/>

		<cfscript>
			return instance.roles.contains( arguments.role.toLowerCase() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isLocked" output="false">

		<cfscript>
			return instance.locked;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isLoggedIn" output="false">

		<cfscript>
			return instance.loggedIn;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isSessionAbsoluteTimeout" output="false">

		<cfscript>
			var local = {};

			local.session = instance.ESAPI.httpUtilities().getCurrentRequest().getSession( false );
			if(!isObject( local.session ))
				return true;
			local.deadline = getJava( "java.util.Date" ).init( javaCast( "long", local.session.getCreationTime() + instance.ABSOLUTE_TIMEOUT_LENGTH ) );
			local.now = getJava( "java.util.Date" ).init();
			return local.now.after( local.deadline );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="isSessionTimeout" output="false">

		<cfscript>
			var local = {};

			local.session = instance.ESAPI.httpUtilities().getCurrentRequest().getSession( false );
			if(!isObject( local.session ))
				return true;
			local.deadline = getJava( "java.util.Date" ).init( javaCast( "long", local.session.getLastAccessedTime() + instance.IDLE_TIMEOUT_LENGTH ) );
			local.now = getJava( "java.util.Date" ).init();
			return local.now.after( local.deadline );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="lock" output="false">

		<cfscript>
			instance.locked = true;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Account locked: " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="loginWithPassword" output="false">
		<cfargument required="true" type="String" name="password"/>

		<cfscript>
			if(arguments.password == "" || arguments.password.equals( "" )) {
				setLastFailedLoginTime( getJava( "java.util.Date" ).init() );
				incrementFailedLoginCount();
				throwException( createObject( "component", "cfesapi.org.owasp.esapi.errors.AuthenticationLoginException" ).init( instance.ESAPI, "Login failed", "Missing password: " & instance.accountName ) );
			}

			// don't let disabled users log in
			if(!isEnabled()) {
				setLastFailedLoginTime( getJava( "java.util.Date" ).init() );
				incrementFailedLoginCount();
				throwException( createObject( "component", "cfesapi.org.owasp.esapi.errors.AuthenticationLoginException" ).init( instance.ESAPI, "Login failed", "Disabled user attempt to login: " & instance.accountName ) );
			}

			// don't let locked users log in
			if(isLocked()) {
				setLastFailedLoginTime( getJava( "java.util.Date" ).init() );
				incrementFailedLoginCount();
				throwException( createObject( "component", "cfesapi.org.owasp.esapi.errors.AuthenticationLoginException" ).init( instance.ESAPI, "Login failed", "Locked user attempt to login: " & instance.accountName ) );
			}

			// don't let expired users log in
			if(isExpired()) {
				setLastFailedLoginTime( getJava( "java.util.Date" ).init() );
				incrementFailedLoginCount();
				throwException( createObject( "component", "cfesapi.org.owasp.esapi.errors.AuthenticationLoginException" ).init( instance.ESAPI, "Login failed", "Expired user attempt to login: " & instance.accountName ) );
			}

			logout();

			if(verifyPassword( arguments.password )) {
				instance.loggedIn = true;
				instance.ESAPI.httpUtilities().changeSessionIdentifier( instance.ESAPI.currentRequest() );
				instance.ESAPI.authenticator().setCurrentUser( this );
				setLastLoginTime( getJava( "java.util.Date" ).init() );
				setLastHostAddress( instance.ESAPI.httpUtilities().getCurrentRequest().getRemoteHost() );
				instance.logger.trace( getSecurity("SECURITY_SUCCESS"), true, "User logged in: " & instance.accountName );
			}
			else {
				instance.loggedIn = false;
				setLastFailedLoginTime( getJava( "java.util.Date" ).init() );
				incrementFailedLoginCount();
				if(getFailedLoginCount() >= instance.ESAPI.securityConfiguration().getAllowedLoginAttempts()) {
					this.lock();
				}
				throwException( createObject( "component", "cfesapi.org.owasp.esapi.errors.AuthenticationLoginException" ).init( instance.ESAPI, "Login failed", "Incorrect password provided for " & getAccountName() ) );
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="logout" output="false">

		<cfscript>
			var local = {};

			instance.ESAPI.httpUtilities().killCookie( instance.ESAPI.currentRequest(), instance.ESAPI.currentResponse(), instance.ESAPI.httpUtilities().REMEMBER_TOKEN_COOKIE_NAME );

			local.session = instance.ESAPI.currentRequest().getSession( false );
			if(isObject( local.session )) {
				removeSession( local.session );
				local.session.invalidate();
			}
			instance.ESAPI.httpUtilities().killCookie( instance.ESAPI.currentRequest(), instance.ESAPI.currentResponse(), "JSESSIONID" );
			instance.loggedIn = false;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Logout successful" );
			instance.ESAPI.authenticator().setCurrentUser( createObject( "component", "cfesapi.org.owasp.esapi.User$ANONYMOUS" ).init( instance.ESAPI ) );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="removeRole" output="false">
		<cfargument required="true" type="String" name="role"/>

		<cfscript>
			instance.roles.remove( arguments.role.toLowerCase() );
			instance.logger.trace( getSecurity("SECURITY_SUCCESS"), true, "Role " & arguments.role & " removed from " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="resetCSRFToken" output="false"
	            hint="In this implementation, we have chosen to use a random token that is stored in the User object. Note that it is possible to avoid the use of server side state by using either the hash of the users's session id or an encrypted token that includes a timestamp and the user's IP address. user's IP address. A relatively short 8 character string has been chosen because this token will appear in all links and forms.">

		<cfscript>
			// user.csrfToken = instance.ESAPI.encryptor().hash( session.getId(),user.name );
			// user.csrfToken = instance.ESAPI.encryptor().encrypt( address & ":" & instance.ESAPI.encryptor().getTimeStamp();
			instance.csrfToken = instance.ESAPI.randomizer().getRandomString( 8, getJava( "org.owasp.esapi.reference.DefaultEncoder" ).CHAR_ALPHANUMERICS );
			return instance.csrfToken;
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="void" name="setAccountId" output="false">
		<cfargument required="true" type="numeric" name="accountId"/>

		<cfscript>
			this.accountId = arguments.accountId;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setAccountName" output="false">
		<cfargument required="true" type="String" name="accountName"/>

		<cfscript>
			var local = {};

			local.old = getAccountName();
			instance.accountName = arguments.accountName.toLowerCase();
			if(local.old != "")
				instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Account name changed from " & local.old & " to " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setExpirationTime" output="false">
		<cfargument required="true" type="Date" name="expirationTime"/>

		<cfscript>
			instance.expirationTime = getJava( "java.util.Date" ).init( javaCast( "long", arguments.expirationTime.getTime() ) );
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Account expiration time set to " & arguments.expirationTime & " for " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setLastFailedLoginTime" output="false">
		<cfargument required="true" type="Date" name="lastFailedLoginTime"/>

		<cfscript>
			instance.lastFailedLoginTime = arguments.lastFailedLoginTime;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Set last failed login time to " & arguments.lastFailedLoginTime & " for " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setLastHostAddress" output="false">
		<cfargument required="true" type="String" name="remoteHost"/>

		<cfscript>
			if(instance.lastHostAddress != "" && !instance.lastHostAddress.equals( arguments.remoteHost )) {
				// returning remote address not remote hostname to prevent DNS lookup
				createObject( "component", "cfesapi.org.owasp.esapi.errors.AuthenticationHostException" ).init( instance.ESAPI, "Host change", "User session just jumped from " & instance.lastHostAddress & " to " & arguments.remoteHost );
			}
			instance.lastHostAddress = arguments.remoteHost;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setLastLoginTime" output="false">
		<cfargument required="true" type="Date" name="lastLoginTime"/>

		<cfscript>
			instance.lastLoginTime = arguments.lastLoginTime;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Set last successful login time to " & arguments.lastLoginTime & " for " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setLastPasswordChangeTime" output="false">
		<cfargument required="true" type="Date" name="lastPasswordChangeTime"/>

		<cfscript>
			instance.lastPasswordChangeTime = arguments.lastPasswordChangeTime;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Set last password change time to " & arguments.lastPasswordChangeTime & " for " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setRoles" output="false">
		<cfargument required="true" type="Array" name="roles"/>

		<cfscript>
			instance.roles = [];
			addRoles( arguments.roles );
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Adding roles " & arrayToList( arguments.roles ) & " to " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setScreenName" output="false">
		<cfargument required="true" type="String" name="screenName"/>

		<cfscript>
			instance.screenName = arguments.screenName;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "ScreenName changed to " & arguments.screenName & " for " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="toStringData" output="false">

		<cfscript>
			return "USER:" & instance.accountName;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="unlock" output="false">

		<cfscript>
			instance.locked = false;
			instance.failedLoginCount = 0;
			instance.logger.info( getSecurity("SECURITY_SUCCESS"), true, "Account unlocked: " & getAccountName() );
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="verifyPassword" output="false">
		<cfargument required="true" type="String" name="password"/>

		<cfscript>
			return instance.ESAPI.authenticator().verifyPassword( this, arguments.password );
		</cfscript>

	</cffunction>

	<cffunction access="public" name="clone" output="false" hint="Override clone and make final to prevent duplicate user objects.">

		<cfscript>
			throwException( getJava( "java.lang.CloneNotSupportedException" ).init() );
		</cfscript>

	</cffunction>

</cfcomponent>
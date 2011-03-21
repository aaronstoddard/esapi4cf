<cfinterface hint="The User interface represents an application user or user account. There is quite a lot of information that an application must store for each user in order to enforce security properly. There are also many rules that govern authentication and identity management. A user account can be in one of several states. When first created, a User should be disabled, not expired, and unlocked. To start using the account, an administrator should enable the account. The account can be locked for a number of reasons, most commonly because they have failed login for too many times. Finally, the account can expire after the expiration date has been reached. The User must be enabled, not expired, and unlocked in order to pass authentication.">

	<cffunction access="public" returntype="any" name="getLocale" output="false" hint="java.util.Locale: the locale">
	</cffunction>


	<cffunction access="public" returntype="void" name="setLocale" output="false">
		<cfargument type="any" name="locale" required="true" hint="java.util.Locale: the locale to set">
	</cffunction>


	<cffunction access="public" returntype="void" name="addRole" output="false" hint="Adds a role to this user's account.">
		<cfargument type="String" name="role" required="true" hint="the role to add">
	</cffunction>


	<cffunction access="public" returntype="void" name="addRoles" output="false" hint="Adds a set of roles to this user's account.">
		<cfargument type="Array" name="newRoles" required="true" hint="the new roles to add">
	</cffunction>


	<cffunction access="public" returntype="void" name="changePassword" output="false" hint="Sets the user's password, performing a verification of the user's old password, the equality of the two new passwords, and the strength of the new password.">
		<cfargument type="String" name="oldPassword" required="true" hint="the old password">
		<cfargument type="String" name="newPassword1" required="true" hint="the new password">
		<cfargument type="String" name="newPassword2" required="true" hint="the new password - used to verify that the new password was typed correctly">
	</cffunction>


	<cffunction access="public" returntype="void" name="disable" output="false" hint="Disable this user's account.">
	</cffunction>


	<cffunction access="public" returntype="void" name="enable" output="false" hint="Enable this user's account.">
	</cffunction>


	<cffunction access="public" returntype="numeric" name="getAccountId" output="false" hint="Gets this user's account id number.">
	</cffunction>


	<cffunction access="public" returntype="String" name="getAccountName" output="false" hint="Gets this user's account name.">
	</cffunction>


	<cffunction access="public" returntype="String" name="getCSRFToken" output="false" hint="Gets the CSRF token for this user's current sessions.">
	</cffunction>


	<cffunction access="public" returntype="any" name="getExpirationTime" output="false" hint="Returns the date that this user's account will expire.">
	</cffunction>


	<cffunction access="public" returntype="numeric" name="getFailedLoginCount" output="false" hint="Returns the number of failed login attempts since the last successful login for an account. This method is intended to be used as a part of the account lockout feature, to help protect against brute force attacks. However, the implementor should be aware that lockouts can be used to prevent access to an application by a legitimate user, and should consider the risk of denial of service.">
	</cffunction>


	<cffunction access="public" returntype="String" name="getLastHostAddress" output="false" hint="Returns the last host address used by the user. This will be used in any log messages generated by the processing of this request.">
	</cffunction>


	<cffunction access="public" returntype="any" name="getLastFailedLoginTime" output="false" hint="Returns the date of the last failed login time for a user. This date should be used in a message to users after a successful login, to notify them of potential attack activity on their account.">
	</cffunction>


	<cffunction access="public" returntype="any" name="getLastLoginTime" output="false" hint="Returns the date of the last successful login time for a user. This date should be used in a message to users after a successful login, to notify them of potential attack activity on their account.">
	</cffunction>


	<cffunction access="public" returntype="any" name="getLastPasswordChangeTime" output="false" hint="Gets the date of user's last password change.">
	</cffunction>


	<cffunction access="public" returntype="Array" name="getRoles" output="false" hint="Gets the roles assigned to a particular account.">
	</cffunction>


	<cffunction access="public" returntype="String" name="getScreenName" output="false" hint="Gets the screen name (alias) for the current user.">
	</cffunction>


	<cffunction access="public" returntype="void" name="addSession" output="false" hint="Adds a session for this User.">
		<cfargument type="cfesapi.org.owasp.esapi.HttpSession" name="s" required="true" hint="The session to associate with this user.">
	</cffunction>


	<cffunction access="public" returntype="void" name="removeSession" output="false" hint="Removes a session for this User.">
		<cfargument type="cfesapi.org.owasp.esapi.HttpSession" name="s" required="true" hint="The session to remove from being associated with this user.">
	</cffunction>


	<cffunction access="public" returntype="Array" name="getSessions" output="false" hint="Returns the list of sessions associated with this User.">
	</cffunction>


	<cffunction access="public" returntype="void" name="incrementFailedLoginCount" output="false" hint="Increment failed login count.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isAnonymous" output="false" hint="Checks if user is anonymous.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isEnabled" output="false" hint="Checks if this user's account is currently enabled.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isExpired" output="false" hint="Checks if this user's account is expired.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isInRole" output="false" hint="Checks if this user's account is assigned a particular role.">
		<cfargument type="String" name="role" required="true" hint="the role for which to check">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isLocked" output="false" hint="Checks if this user's account is locked.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isLoggedIn" output="false" hint="Tests to see if the user is currently logged in.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isSessionAbsoluteTimeout" output="false" hint="Tests to see if this user's session has exceeded the absolute time out based on ESAPI's configuration settings.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="isSessionTimeout" output="false" hint="Tests to see if the user's session has timed out from inactivity based on ESAPI's configuration settings. A session may timeout prior to ESAPI's configuration setting due to the ColdFusion setting for session-timeout in the CFAdmin or the application settings.">
	</cffunction>


	<cffunction access="public" returntype="void" name="lock" output="false" hint="Lock this user's account.">
	</cffunction>


	<cffunction access="public" returntype="void" name="loginWithPassword" output="false" hint="Login with password.">
		<cfargument type="String" name="password" required="true" hint="the password">
	</cffunction>


	<cffunction access="public" returntype="void" name="logout" output="false" hint="Logout this user.">
	</cffunction>


	<cffunction access="public" returntype="void" name="removeRole" output="false" hint="Removes a role from this user's account.">
		<cfargument type="String" name="role" required="true" hint="the role to remove">
	</cffunction>


	<cffunction access="public" returntype="String" name="resetCSRFToken" output="false" hint="Returns a token to be used as a prevention against CSRF attacks. This token should be added to all links and forms. The application should verify that all requests contain the token, or they may have been generated by a CSRF attack. It is generally best to perform the check in a centralized location, either a filter or controller. See the verifyCSRFToken method.">
	</cffunction>


	<cffunction access="public" returntype="void" name="setAccountName" output="false" hint="Sets this user's account name.">
		<cfargument type="String" name="accountName" required="true" hint="the new account name">
	</cffunction>


	<cffunction access="public" returntype="void" name="setExpirationTime" output="false" hint="Sets the date and time when this user's account will expire.">
		<cfargument type="Date" name="expirationTime" required="true" hint="the new expiration time">
	</cffunction>


	<cffunction access="public" returntype="void" name="setRoles" output="false" hint="Sets the roles for this account.">
		<cfargument type="Array" name="roles" required="true" hint="the new roles">
	</cffunction>


	<cffunction access="public" returntype="void" name="setScreenName" output="false" hint="Sets the screen name (username alias) for this user.">
		<cfargument type="String" name="screenName" required="true" hint="the new screen name">
	</cffunction>


	<cffunction access="public" returntype="void" name="unlock" output="false" hint="Unlock this user's account.">
	</cffunction>


	<cffunction access="public" returntype="boolean" name="verifyPassword" output="false" hint="Verify that the supplied password matches the password for this user. This method is typically used for 'reauthentication' for the most sensitive functions, such as transactions, changing email address, and changing other account information.">
		<cfargument type="String" name="password" required="true" hint="the password that the user entered">
	</cffunction>


	<cffunction access="public" returntype="void" name="setLastFailedLoginTime" output="false" hint="Set the time of the last failed login for this user.">
		<cfargument type="Date" name="lastFailedLoginTime" required="true" hint="the date and time when the user just failed to login correctly.">
	</cffunction>


	<cffunction access="public" returntype="void" name="setLastHostAddress" output="false" hint="Set the last remote host address used by this user.">
		<cfargument type="String" name="remoteHost" required="true" hint="The address of the user's current source host.">
	</cffunction>


	<cffunction access="public" returntype="void" name="setLastLoginTime" output="false" hint="Set the time of the last successful login for this user.">
		<cfargument type="Date" name="lastLoginTime" required="true" hint="the date and time when the user just successfully logged in.">
	</cffunction>


	<cffunction access="public" returntype="void" name="setLastPasswordChangeTime" output="false" hint="Set the time of the last password change for this user.">
		<cfargument type="Date" name="lastPasswordChangeTime" required="true" hint="the date and time when the user just successfully changed his/her password.">
	</cffunction>


	<cffunction access="public" returntype="Struct" name="getEventMap" output="false" hint="Returns the hashmap used to store security events for this user. Used by the IntrusionDetector.">
	</cffunction>

</cfinterface>
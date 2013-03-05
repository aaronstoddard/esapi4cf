﻿<cfinterface>

	<cffunction access="public" name="getAttribute" output="false">
		<cfargument required="true" type="String" name="name"/>

	</cffunction>

	<cffunction access="public" returntype="Array" name="getAttributeNames" output="false">
	</cffunction>

	<cffunction access="public" returntype="numeric" name="getCreationTime" output="false">
	</cffunction>

	<cffunction access="public" returntype="String" name="getId" output="false">
	</cffunction>

	<cffunction access="public" returntype="numeric" name="getLastAccessedTime" output="false">
	</cffunction>

	<cffunction access="public" returntype="numeric" name="getMaxInactiveInterval" output="false">
	</cffunction>

	<cffunction access="public" name="getServletContext" output="false">
	</cffunction>

	<cffunction access="public" name="getSessionContext" output="false" hint="Deprecated. No replacement.">
	</cffunction>

	<cffunction access="public" name="getValue" output="false" hint="Deprecated in favor of getAttribute(name).">
		<cfargument required="true" type="String" name="name"/>

	</cffunction>

	<cffunction access="public" returntype="Array" name="getValueNames" output="false"
	            hint="Deprecated in favor of getAttributeNames().">
	</cffunction>

	<cffunction access="public" returntype="void" name="invalidate" output="false">
	</cffunction>

	<cffunction access="public" returntype="boolean" name="isNew" output="false">
	</cffunction>

	<cffunction access="public" returntype="void" name="putValue" output="false"
	            hint="Deprecated in favor of setAttribute(name, value).">
		<cfargument required="true" type="String" name="name"/>
		<cfargument required="true" name="value"/>

	</cffunction>

	<cffunction access="public" returntype="void" name="removeAttribute" output="false">
		<cfargument required="true" type="String" name="name"/>

	</cffunction>

	<cffunction access="public" returntype="void" name="removeValue" output="false"
	            hint="Deprecated in favor of removeAttribute(name).">
		<cfargument required="true" type="String" name="name"/>

	</cffunction>

	<cffunction access="public" returntype="void" name="setAttribute" output="false">
		<cfargument required="true" type="String" name="name"/>
		<cfargument required="true" name="value"/>

	</cffunction>

	<cffunction access="public" returntype="void" name="setMaxInactiveInterval" output="false">
		<cfargument required="true" type="numeric" name="interval"/>

	</cffunction>

</cfinterface>
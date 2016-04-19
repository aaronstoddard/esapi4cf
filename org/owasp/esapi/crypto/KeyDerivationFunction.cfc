/*
 * OWASP Enterprise Security API for ColdFusion/CFML (ESAPI4CF)
 *
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2011 - The OWASP Foundation
 *
 * The ESAPI is published by OWASP under the BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 */
import "org.owasp.esapi.util.Utils";

/**
 * This class implements a Key Derivation Function (KDF) and supporting methods.
 * A KDF is a function with which an input key (called the Key Derivation Key,
 * or KDK) and other input data are used to securely generate (i.e., derive)
 * keying material that can be employed by cryptographic algorithms.
 * <p>
 * <b>Acknowledgments</b>:
 * ESAPI's KDF is patterned after suggestions first made by cryptographer
 * Dr. David A. Wagner and later extended to follow KDF in counter mode
 * as specified by section 5.1 of NIST SP 800-108. Jeffrey Walton and the NSA
 * also made valuable suggestions regarding the modeling of the method,
 * {@link #computeDerivedKey(SecretKey, int, String)}.
 */
component extends="org.owasp.esapi.util.Object" {
	/**
	 * Used to support backward compatibility. {@code kdfVersion} is used as the
	 * version for the serialized encrypted ciphertext on all the "encrypt"
	 * operations. This static field should be the same as
	 * {@link CipherText#cipherTextVersion} and
	 * {@link CipherTextSerializer#cipherTextSerializerVersion} to make sure
	 * that these classes are all kept in-sync in order to support backward
	 * compatibility of previously encrypted data.
	 * <pre>
	 * Previous versions:	20110203 - Original version (ESAPI releases 2.0 & 2.0.1)
	 *					    20130830 - Fix to issue #306 (release 2.1.0)
	 * </pre>
	 * @see CipherTextSerializer#asSerializedByteArray()
	 * @see CipherText#asPortableSerializedByteArray()
	 * @see CipherText#fromPortableSerializedBytes(byte[])
	 */
	this.originalVersion  = 20110203;	 // First version. Do not change. EVER!
	this.kdfVersion       = 20130830;   // Current version. Format: YYYYMMDD, max is 99991231.
	variables.serialVersionUID = this.kdfVersion; // Format: YYYYMMDD

    // Pseudo-random function algorithms suitable for NIST KDF in counter mode.
	// Note that HmacMD5 is intentionally omitted here!!!
    this.PRF_ALGORITHMS = {
    	// SHA-1, 160-bits
        "HmacSHA1": new PRF_ALGORITHMS(0, 160, "HmacSHA1"),
        // SHA-2 candidates, 256-, 384-, and 512-bits
        "HmacSHA256": new PRF_ALGORITHMS(1, 256, "HmacSHA256"),
        "HmacSHA384": new PRF_ALGORITHMS(2, 384, "HmacSHA384"),
        "HmacSHA512": new PRF_ALGORITHMS(3, 512, "HmacSHA512")
    	// Reserved for SHA-3 winner, 224-, 256-, 384-, and 512-bits
    	// Names not yet known. Will use standard JCE alg names here.
    	//
    	// E.g., might be something like
    	//		HmacSHA3_224(4, 224, "HmacSHA3-224"),
    	//		HmacSHA3_256(5, 256, "HmacSHA3-256"),
    	//		HmacSHA3_384(6, 384, "HmacSHA3-385"),
    	//		HmacSHA3_512(7, 512, "HmacSHA3-512");
        // Reserved for future use -- values 8 through 15
        //  Most likely these might be some other strong contenders that
        //  were are based on HMACs from the NIST SHA-3 finalists.
    };

	variables.ESAPI = "";
	variables.logger = "";

	variables.prfAlg_ = "";
	variables.version_ = this.kdfVersion;
	variables.context_ = "";

	/**
	 * Construct a {@code KeyDerivationFunction}.
	 * @param prfAlg	Specifies a supported algorithm.
	 */
	public KeyDerivationFunction function init(required org.owasp.esapi.ESAPI ESAPI, prfAlg) {
		variables.ESAPI = arguments.ESAPI;
		variables.logger = variables.ESAPI.getLogger(getMetaData(this).fullName);

		if (structKeyExists(arguments, "prfAlg") && !isNull(arguments.prfAlg)) {
			variables.prfAlg_ = arguments.prfAlg.getAlgName();
		}
		else {
			var prfName = variables.ESAPI.securityConfiguration().getKDFPseudoRandomFunction();
			if (!variables.isValidPRF(prfName)) {
	    		throws(new ConfigurationException("Algorithm name " & prfName & " not a valid algorithm name for property " & DefaultSecurityConfiguration.KDF_PRF_ALG));
			}
			variables.prfAlg_ = prfName;
		}
		return this;
	}


	/**
	 * Return the name of the algorithm for the Pseudo Random Function (PRF)
	 * that is being used.
	 * @return	The PRF algorithm name.
	 */
	public string function getPRFAlgName() {
		return variables.prfAlg_;
	}

	/**
	 * Package level method for use by {@code CipherText} class to get default
	 *
	 */
	package numeric function getDefaultPRFSelection() {
		var prfName = variables.ESAPI.securityConfiguration().getKDFPseudoRandomFunction();
		for (var prf in this.PRF_ALGORITHMS) {
			if ( this.PRF_ALGORITHMS[prf].getAlgName() == prfName ) {
				return this.PRF_ALGORITHMS[prf].getValue();
			}
		}
		throws(new ConfigurationException("Algorithm name " & prfName & " not a valid algorithm name for property " & DefaultSecurityConfiguration.KDF_PRF_ALG));
	}

	/**
	 * Set version so backward compatibility can be supported. Used to set the
	 * version to some previous version so that previously encrypted data can
	 * be decrypted.
	 * @param version	Date as a integer, in format of YYYYMMDD. Maximum
	 * 					version date is 99991231 (December 31, 9999).
	 * @throws	IllegalArgumentException	If {@code version} is not within
	 * 					the valid range of [20110203, 99991231].
	 */
	public void function setVersion(required numeric version) {
		new CryptoHelper(variables.ESAPI).isValidKDFVersion(arguments.version, false, true);
		variables.version_ = arguments.version;
	}

	/**
	 * Return the version used for backward compatibility.
	 * @return	The KDF version #, in format YYYYMMDD, used for supporting
	 * 			backward compatibility.
	 */
	public numeric function getVersion() {
		return variables.version_;
	}


	// TODO: IMPORTANT NOTE: In a future release (hopefully starting in 2.1.1),
	// we will be using the 'context' to mix in some additional things. At a
	// minimum, we will be using the KDF version (version_) so that downgrade version
	// attacks are not possible. Other candidates are the cipher xform and
	// the timestamp.
	/**
	 * Set the 'context' as specified by NIST Special Publication 800-108. NIST
	 * defines 'context' as "A binary string containing the information related
	 * to the derived keying material. It may include identities of parties who
	 * are deriving and/or using the derived keying material and, optionally, a
	 * once known by the parties who derive the keys." NIST SP 800-108 seems to
	 * imply that while 'context' is recommended, that it is optional. In section
	 * 7.6 of NIST 800-108, NIST uses "SHOULD" rather than "MUST":
	 * <blockquote>
	 * "Derived keying material should be bound to all relying
	 * entities and other information to identify the derived
	 * keying material. This is called context binding.
	 * In particular, the identity (or identifier, as the term
	 * is defined in [NIST SP 800-56A , sic] and [NIST SP
	 * 800-56B , sic]) of each entity that will access (meaning
	 * derive, hold, use, and/or distribute) any segment of
	 * the keying material should be included in the Context
	 * string input to the KDF, provided that this information
	 * is known by each entity who derives the keying material."
	 * </blockquote>
	 * The ISO/IEC's KDF2 uses a similar construction for their KDF and there
	 * 'context' data is not specified at all. Therefore, ESAPI 2.0's
	 * reference implementation, {@code JavaEncryptor}, chooses not to use
	 * 'context' at all.
	 *
	 * @param context	Optional binary string containing information related to
	 * 					the derived keying material. By default (if this method
	 * 					is never called), the empty string is used. May have any
	 * 					value but {@code null}.
	 */
	public void function setContext(required string context) {
		if (isNull(arguments.context)) {
			throws(new IllegalArgumentException("Context may not be null."));
		}
		variables.context_ = arguments.context;
	}

	/**
	 * Return the optional 'context' that typically contains information
	 * related to the keying material, such as the identities of the message
	 * sender and recipient.
	 * @see #setContext(String)
	 * @return The 'context' is returned.
	 */
	public string function getContext() {
		return variables.context_;
	}

	/**
	 * The method is ESAPI's Key Derivation Function (KDF) that computes a
	 * derived key from the {@code keyDerivationKey} for either
	 * encryption / decryption or for authentication.
	 * <p>
	 * <b>CAUTION:</b> If this algorithm for computing derived keys from the
	 * key derivation key is <i>ever</i> changed, we risk breaking backward compatibility of being
	 * able to decrypt data previously encrypted with earlier / different versions
	 * of this method. Therefore, do not change this unless you are 100% certain that
	 * what you are doing will NOT change either of the derived keys for
	 * ANY "key derivation key" AT ALL!!!
	 * <p>
	 * <b>NOTE:</b> This method is generally not intended to be called separately.
	 * It is used by ESAPI's reference crypto implementation class {@code JavaEncryptor}
	 * and might be useful for someone implementing their own replacement class, but
	 * generally it is not something that is useful to application client code.
	 *
	 * @param keyDerivationKey  A key used as an input to a key derivation function
	 *                          to derive other keys. This is the key that generally
	 *                          is created using some key generation mechanism such as
	 *                          {@link CryptoHelper#generateSecretKey(String, int)}. The
	 *                          "input" key from which the other keys are derived.
	 * 							The derived key will have the same algorithm type
	 * 							as this key. This KDK cannot be null.
	 * @param keySize		The cipher's key size (in bits) for the {@code keyDerivationKey}.
	 * 						Must have a minimum size of 56 bits and be an integral multiple of 8-bits.
	 * 						<b>Note:</b> The derived key will have the same size as this.
	 * @param purpose		The purpose for the derived key. For the ESAPI reference implementation,
	 * 						{@code JavaEncryptor}, this <i>must</i> be either the string "encryption" or
	 * 						"authenticity", where "encryption" is used for creating a derived key to use
	 * 						for confidentiality, and "authenticity" is used for creating a derived key to
	 * 						use with a MAC to ensure message authenticity. However, since parameter serves
	 * 						the same purpose as the "Label" in section 5.1 of NIST SP 800-108, it really can
	 * 						be set to anything other than {@code null} or an empty string when called outside
	 * 						of {@code JavaEncryptor}.
	 * @return				The derived {@code SecretKey} to be used according
	 * 						to the specified purpose.
	 * @throws NoSuchAlgorithmException		The {@code keyDerivationKey} has an unsupported
	 * 						encryption algorithm or no current JCE provider supports
	 * 						"HmacSHA1".
	 * @throws EncryptionException		If "UTF-8" is not supported as an encoding, then
	 * 						this is thrown with the original {@code UnsupportedEncodingException}
	 * 						as the cause. (NOTE: This should never happen as "UTF-8" is supposed to
	 * 						be a common encoding supported by all Java implementations. Support
	 * 					    for it is usually in rt.jar.)
	 * @throws InvalidKeyException 	Likely indicates a coding error. Should not happen.
	 * @throws EncryptionException  Throw for some precondition violations.
	 */
	public function computeDerivedKey(required keyDerivationKey, required numeric keySize, required string purpose) {
		// Acknowledgments: David Wagner first suggested this approach, I (Kevin Wall)
		//				    stumbled upon NIST SP 800-108 and used it as a basis to
		//				    extend it. Later it was changed that conforms more closely
		//					to section 5.1 of NIST SP 800-108 based on feedback from
		//					Jeffrey Walton.
		//
        // These probably should be turned into actual runtime checks and an
        // IllegalArgumentException should be thrown if they are violated.
		if (isNull(arguments.keyDerivationKey)) throws("Key derivation key cannot be null.");
			// We would choose a larger minimum key size, but we want to be
			// able to accept DES for legacy encryption needs.
		if (arguments.keySize < 56) throws("Key has size of " & arguments.keySize & ", which is less than minimum of 56-bits.");
		if ((arguments.keySize % 8) != 0) throws("Key size (" & arguments.keySize & ") must be a even multiple of 8-bits.");
		if (isNull(arguments.purpose) || arguments.purpose == "") throws("Purpose may not be null or empty.");

		arguments.keySize = calcKeySize( arguments.keySize );	// Safely convert to whole # of bytes.
		var derivedKey = new Utils().newByte(arguments.keySize);
		var label = "";				    	// Same purpose as NIST SP 800-108's "label" in section 5.1.
		var context = "";						// See setContext() for details.
		try {
			label = arguments.purpose.getBytes("UTF-8");
			context = variables.context_.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e) {
			throws(new EncryptionException("Encryption failure (internal encoding error: UTF-8)", "UTF-8 encoding is NOT supported as a standard byte encoding: " & e.getMessage(), e));
		}

			// Note that keyDerivationKey is going to be some SecretKey like an AES or
			// DESede key, but not an HmacSHA1 key. That means it is not likely
			// going to be 20 bytes but something different. Experiments show
			// that doesn't really matter though as the SecretKeySpec CTOR on
			// the following line still returns the appropriate sized key for
			// HmacSHA1. So, if keyDerivationKey was originally (say) a 56-bit
            // DES key, then there is apparently some key-stretching going on here
            // under the hood to create 'sk' so that it is 20 bytes. I cannot vouch
            // for how secure this key-stretching is. Worse, it might not be specified
            // as to *how* it is done and left to each JCE provider.
		var sk = createObject("java", "javax.crypto.spec.SecretKeySpec").init(arguments.keyDerivationKey.getEncoded(), "HmacSHA1");
		var mac = "";

		try {
			mac = createObject("java", "javax.crypto.Mac").getInstance("HmacSHA1");
			mac.init(sk);
		} catch( InvalidKeyException ex ) {
			variables.logger.error(Logger.SECURITY_FAILURE, "Created HmacSHA1 Mac but SecretKey sk has alg " & sk.getAlgorithm(), ex);
			throws(ex);
		}

		// Repeatedly call of HmacSHA1 hash until we've collected enough bits
		// for the derived key. The first time through, we calculate the HmacSHA1
		// on the "purpose" string, but subsequent calculations are performed
		// on the previous result.
		var ctr = 1;		// Iteration counter for NIST 800-108
		var totalCopied = 0;
		var destPos = 0;
		var len = 0;
		var tmpKey = "";	// Do not declare inside do-while loop!!!
		do {
			//
			// This is to make our KDF more along the line of NIST's.
			// NIST's Special Publication 800-108 performs the following in
            // the iterative loop of Section 5.1:
            //       n := number of blocks required to fulfill request
            //       for i = 1 to n, do
            //           K(i) := PRF(KDK, [i]2 || Label || 0x00 || Context || [L]2)
            //           result(i) := result(i-1) || K(i)
            //       end
            // where '||' is represents bit string concatenation, and PRF is
            // an NIST approved pseudo-random function (such as an HMAC),
            // KDK is the key derivation key, [i]2 is the big-endian binary
            // representation of the iteration, and [L]2 is the bits
            // requested by the caller, and 0x00 represents a null byte
            // used as a separation indicator.  However, other sections of this
            // document (Section 7.6) implies that Context is to be an
            // optional field (based on NIST's use of the word SHOULD
            // rather than MUST)
            //
			mac.update( createObject("java", "org.owasp.esapi.util.ByteConversionUtil").fromInt( ctr++ ) );
			mac.update(label);
			mac.update(toBinary(javaCast("null", "")));
			mac.update(context); // This is problematic for us. See Jeff Walton's
								  // analysis of ESAPI 2.0's KDF for details.
								  // Maybe for 2.1, we'll see; 2.0 too close to GA.

	            // According to the Javadoc for Mac.doFinal(byte[]),
	            // "A call to this method resets this Mac object to the state it was
	            // in when previously initialized via a call to init(Key) or
	            // init(Key, AlgorithmParameterSpec). That is, the object is reset
	            // and available to generate another MAC from the same key, if
	            // desired, via new calls to update and doFinal." Therefore, we do
	            // not do an explicit reset().
			tmpKey = mac.doFinal( createObject("java", "org.owasp.esapi.util.ByteConversionUtil").fromInt( arguments.keySize ) );

			if ( arrayLen(tmpKey) >= arguments.keySize ) {
				len = arguments.keySize;
			} else {
				len = min(arrayLen(tmpKey), arguments.keySize - totalCopied);
			}
			createObject("java", "java.lang.System").arraycopy(tmpKey, 0, derivedKey, destPos, len);
			label = tmpKey;
			totalCopied += arrayLen(tmpKey);
			destPos += len;
		} while( totalCopied < arguments.keySize );

		// Don't leave remnants of the partial key in memory. (Note: we could
		// not do this if tmpKey were declared in the do-while loop.
		/* ERROR: invalid index [1] for Native Array, can't expand Native Arrays
		for ( var i = 1; i <= arrayLen(tmpKey); i++ ) {
			tmpKey[i] = javaCast("null", "");
		}*/
		structDelete(local, "tmpKey");	// Make it immediately eligible for GC.

        // Convert it back into a SecretKey of the appropriate type.
		return createObject("java", "javax.crypto.spec.SecretKeySpec").init(derivedKey, arguments.keyDerivationKey.getAlgorithm());
	}

	/**
	 * Check if specified algorithm name is a valid PRF that can be used.
	 * @param prfAlgName	Name of the PRF algorithm; e.g., "HmacSHA1", "HmacSHA384", etc.
	 * @return	True if {@code prfAlgName} is supported, otherwise false.
	 */
	public boolean function isValidPRF(required string prfAlgName) {
		for (var prf in this.PRF_ALGORITHMS) {
			if (this.PRF_ALGORITHMS[prf].getAlgName() == arguments.prfAlgName) {
				return true;
			}
		}
		return false;
	}

	public function convertNameToPRF(required string prfAlgName) {
		for (var prf in this.PRF_ALGORITHMS) {
			if (this.PRF_ALGORITHMS[prf].getAlgName() == arguments.prfAlgName) {
				return this.PRF_ALGORITHMS[prf];
			}
		}
		throws(new IllegalArgumentException("Algorithm name " & arguments.prfAlgName & " not a valid PRF algorithm name for the ESAPI KDF."));
	}

	public function convertIntToPRF(required numeric selection) {
		for (var prf in this.PRF_ALGORITHMS) {
			if (this.PRF_ALGORITHMS[prf].getValue() == arguments.selection) {
				return this.PRF_ALGORITHMS[prf];
			}
		}
		throws(new IllegalArgumentException("No KDF PRF algorithm found for value name " & arguments.selection));
	}

    /**
     * Calculate the size of a key. The key size is given in bits, but we
     * can only allocate them by octets (i.e., bytes), so make sure we
     * round up to the next whole number of octets to have room for all
     * the bits. For example, a key size of 9 bits would require 2 octets
     * to store it.
     *
     * @param ks    The key size, in bits.
     * @return      The key size, in octets, large enough to accommodate
     *              {@code ks} bits.
     */
    private numeric function calcKeySize(required numeric ks) {
        if (arguments.ks <= 0) throws("Key size must be > 0 bits.");
        var numBytes = 0;
        var n = arguments.ks/8;
        var rem = arguments.ks % 8;
        if ( rem == 0 ) {
            numBytes = n;
        } else {
            numBytes = n + 1;
        }
        return numBytes;
    }

}

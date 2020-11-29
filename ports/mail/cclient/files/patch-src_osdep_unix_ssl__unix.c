Description: Support OpenSSL 1.1
 When building with OpenSSL 1.1 and newer, use the new built-in
 hostname verification instead of code that doesn't compile due to
 structs having been made opaque.
Bug-Debian: https://bugs.debian.org/828589

Obtained from: https://sources.debian.org/data/main/u/uw-imap/8:2007f~dfsg-5/debian/patches/1006_openssl1.1_autoverify.patch
--- src/osdep/unix/ssl_unix.c.orig
+++ src/osdep/unix/ssl_unix.c
@@ -227,8 +227,16 @@ static char *ssl_start_work (SSLSTREAM *
 				/* disable certificate validation? */
   if (flags & NET_NOVALIDATECERT)
     SSL_CTX_set_verify (stream->context,SSL_VERIFY_NONE,NIL);
-  else SSL_CTX_set_verify (stream->context,SSL_VERIFY_PEER,ssl_open_verify);
+  else {
+#if OPENSSL_VERSION_NUMBER >= 0x10100000      
+      X509_VERIFY_PARAM *param = SSL_CTX_get0_param(stream->context);
+      X509_VERIFY_PARAM_set_hostflags(param, X509_CHECK_FLAG_NO_PARTIAL_WILDCARDS);
+      X509_VERIFY_PARAM_set1_host(param, host, 0);
+#endif
+
+      SSL_CTX_set_verify (stream->context,SSL_VERIFY_PEER,ssl_open_verify);
 				/* set default paths to CAs... */
+  }
   SSL_CTX_set_default_verify_paths (stream->context);
 				/* ...unless a non-standard path desired */
   if (s = (char *) mail_parameters (NIL,GET_SSLCAPATH,NIL))
@@ -266,6 +274,7 @@ static char *ssl_start_work (SSLSTREAM *
   if (SSL_write (stream->con,"",0) < 0)
     return ssl_last_error ? ssl_last_error : "SSL negotiation failed";
 				/* need to validate host names? */
+#if OPENSSL_VERSION_NUMBER < 0x10100000
   if (!(flags & NET_NOVALIDATECERT) &&
       (err = ssl_validate_cert (cert = SSL_get_peer_certificate (stream->con),
 				host))) {
@@ -275,6 +284,7 @@ static char *ssl_start_work (SSLSTREAM *
     sprintf (tmp,"*%.128s: %.255s",err,cert ? cert->name : "???");
     return ssl_last_error = cpystr (tmp);
   }
+#endif
   return NIL;
 }
 
@@ -313,6 +323,7 @@ static int ssl_open_verify (int ok,X509_
  * Returns: NIL if validated, else string of error message
  */
 
+#if OPENSSL_VERSION_NUMBER < 0x10100000
 static char *ssl_validate_cert (X509 *cert,char *host)
 {
   int i,n;
@@ -342,6 +353,7 @@ static char *ssl_validate_cert (X509 *ce
   else ret = "Unable to locate common name in certificate";
   return ret;
 }
+#endif
 
 /* Case-independent wildcard pattern match
  * Accepts: base string

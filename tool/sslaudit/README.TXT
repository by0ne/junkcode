Introduction:
=============

SSLAudit is a tool that verifies SSL certificate and supported protocols/ciphers of a SSL-enabled webserver. The result is graded according to SSLLabs SSL Server Rating Guide.

The tool is similar in function to SSLDigger from Foundstone and THCSSLCheck from The Hacker Choice but is different that it is open source and is easily modified to support new protocols and ciphers as they become available and the result is graded.

This project is sponsored by Omegapoint AB and was created to assist security assessments done according to OWASP Testing Guide.

Details:
========

Currently SSLAudit performs the following checks:

* SSL Protocol support detection
* SSL Cipher support detection
* Public cert PEM extraction
* Certificate timeframe validation (and warns if it is 30 days or less until the certificate expires)
* Grading of result according to SSLLabs SSL Server Rating Guide

Usage:
======

  sslaudit.pl host [port]

Example output:
===============

$ sslaudit.pl www.google.com

Connecting to www.google.com:443 - OK
Certificate CN: www.google.com == Hostname: www.google.com
Subject Name: /C=US/ST=California/L=Mountain View/O=Google Inc/CN=www.google.com
Issuer  Name: /C=ZA/O=Thawte Consulting (Pty) Ltd./CN=Thawte SGC CA

-----BEGIN CERTIFICATE-----
MIIDITCCAoqgAwIBAgIQL9+89q6RUm0PmqPfQDQ+mjANBgkqhkiG9w0BAQUFADBM
MQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkg
THRkLjEWMBQGA1UEAxMNVGhhd3RlIFNHQyBDQTAeFw0wOTEyMTgwMDAwMDBaFw0x
MTEyMTgyMzU5NTlaMGgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlh
MRYwFAYDVQQHFA1Nb3VudGFpbiBWaWV3MRMwEQYDVQQKFApHb29nbGUgSW5jMRcw
FQYDVQQDFA53d3cuZ29vZ2xlLmNvbTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkC
gYEA6PmGD5D6htffvXImttdEAoN4c9kCKO+IRTn7EOh8rqk41XXGOOsKFQebg+jN
gtXj9xVoRaELGYW84u+E593y17iYwqG7tcFR39SDAqc9BkJb4SLD3muFXxzW2k6L
05vuuWciKh0R73mkszeK9P4Y/bz5RiNQl/Os/CRGK1w7t0UCAwEAAaOB5zCB5DAM
BgNVHRMBAf8EAjAAMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwudGhhd3Rl
LmNvbS9UaGF3dGVTR0NDQS5jcmwwKAYDVR0lBCEwHwYIKwYBBQUHAwEGCCsGAQUF
BwMCBglghkgBhvhCBAEwcgYIKwYBBQUHAQEEZjBkMCIGCCsGAQUFBzABhhZodHRw
Oi8vb2NzcC50aGF3dGUuY29tMD4GCCsGAQUFBzAChjJodHRwOi8vd3d3LnRoYXd0
ZS5jb20vcmVwb3NpdG9yeS9UaGF3dGVfU0dDX0NBLmNydDANBgkqhkiG9w0BAQUF
AAOBgQCfQ89bxFApsb/isJr/aiEdLRLDLE5a+RLizrmCUi3nHX4adpaQedEkUjh5
u2ONgJd8IyAPkU0Wueru9G2Jysa9zCRo1kNbzipYvzwY4OA8Ys+WAi0oR1A04Se6
z5nRUP8pJcA2NhUzUnC+MY+f6H/nEQyNv4SgQhqAibAxWEEHXw==
-----END CERTIFICATE-----

Valid from: Dec 18 00:00:00 2009 GMT
Valid to:   Dec 18 23:59:59 2011 GMT
Certificate date valid


SSLv2 - DEFAULT - unsuccessfull
SSLv2 - RC4-MD5 - unsuccessfull
SSLv2 - EXP-RC4-MD5 - unsuccessfull
SSLv2 - RC2-MD5 - unsuccessfull
SSLv2 - EXP-RC2-MD5 - unsuccessfull
SSLv2 - IDEA-CBC-MD5 - unsuccessfull
SSLv2 - DES-CBC-MD5 - unsuccessfull
SSLv2 - DES-CBC3-MD5 - unsuccessfull


SSLv2 not supported by server


SSLv3 - DEFAULT - successfull - 80
SSLv3 - NULL-MD5 - unsuccessfull
SSLv3 - NULL-SHA - unsuccessfull
SSLv3 - EXP-RC4-MD5 - unsuccessfull
SSLv3 - RC4-MD5 - successfull - 80
SSLv3 - RC4-SHA - successfull - 80
SSLv3 - EXP-RC2-CBC-MD5 - unsuccessfull
SSLv3 - IDEA-CBC-SHA - unsuccessfull
SSLv3 - EXP-DES-CBC-SHA - unsuccessfull
SSLv3 - DES-CBC-SHA - unsuccessfull
SSLv3 - DES-CBC3-SHA - successfull - 80
SSLv3 - EXP-EDH-DSS-DES-CBC-SHA - unsuccessfull
SSLv3 - EDH-DSS-CBC-SHA - unsuccessfull
SSLv3 - EDH-DSS-DES-CBC3-SHA - unsuccessfull
SSLv3 - EXP-EDH-RSA-DES-CBC-SHA - unsuccessfull
SSLv3 - EDH-RSA-DES-CBC-SHA - unsuccessfull
SSLv3 - EDH-RSA-DES-CBC3-SHA - unsuccessfull
SSLv3 - EXP-ADH-RC4-MD5 - unsuccessfull
SSLv3 - ADH-RC4-MD5 - unsuccessfull
SSLv3 - EXP-ADH-DES-CBC-SHA - unsuccessfull
SSLv3 - ADH-DES-CBC-SHA - unsuccessfull
SSLv3 - ADH-DES-CBC3-SHA - unsuccessfull
SSLv3 - EXP1024-DES-CBC-SHA - unsuccessfull
SSLv3 - EXP1024-RC4-SHA - unsuccessfull
SSLv3 - EXP1024-DHE-DSS-DES-CBC-SHA - unsuccessfull
SSLv3 - EXP1024-DHE-DSS-RC4-SHA - unsuccessfull
SSLv3 - DHE-DSS-RC4-SHA - unsuccessfull


SSLv3 cipher score: 80 (A)


TLSv1 - DEFAULT - successfull - 90
TLSv1 - NULL-MD5 - unsuccessfull
TLSv1 - NULL-SHA - unsuccessfull
TLSv1 - EXP-RC4-MD5 - unsuccessfull
TLSv1 - RC4-MD5 - successfull - 80
TLSv1 - RC4-SHA - successfull - 80
TLSv1 - EXP-RC2-CBC-MD5 - unsuccessfull
TLSv1 - IDEA-CBC-SHA - unsuccessfull
TLSv1 - EXP-DES-CBC-SHA - unsuccessfull
TLSv1 - DES-CBC-SHA - unsuccessfull
TLSv1 - DES-CBC3-SHA - successfull - 80
TLSv1 - EXP-EDH-DSS-DES-CBC-SHA - unsuccessfull
TLSv1 - EDH-DSS-CBC-SHA - unsuccessfull
TLSv1 - EDH-DSS-DES-CBC3-SHA - unsuccessfull
TLSv1 - EXP-EDH-RSA-DES-CBC-SHA - unsuccessfull
TLSv1 - EDH-RSA-DES-CBC-SHA - unsuccessfull
TLSv1 - EDH-RSA-DES-CBC3-SHA - unsuccessfull
TLSv1 - EXP-ADH-RC4-MD5 - unsuccessfull
TLSv1 - ADH-RC4-MD5 - unsuccessfull
TLSv1 - EXP-ADH-DES-CBC-SHA - unsuccessfull
TLSv1 - ADH-DES-CBC-SHA - unsuccessfull
TLSv1 - ADH-DES-CBC3-SHA - unsuccessfull
TLSv1 - AES128-SHA - successfull - 80
TLSv1 - AES256-SHA - successfull - 100
TLSv1 - DHE-DSS-AES128-SHA - unsuccessfull
TLSv1 - DHE-DSS-AES256-SHA - unsuccessfull
TLSv1 - DHE-RSA-AES128-SHA - unsuccessfull
TLSv1 - DHE-RSA-AES256-SHA - unsuccessfull
TLSv1 - ADH-AES128-SHA - unsuccessfull
TLSv1 - ADH-AES256-SHA - unsuccessfull
TLSv1 - CAMELLIA128-SHA - unsuccessfull
TLSv1 - CAMELLIA256-SHA - unsuccessfull
TLSv1 - DHE-DSS-CAMELLIA128-SHA - unsuccessfull
TLSv1 - DHE-DSS-CAMELLIA256-SHA - unsuccessfull
TLSv1 - DHE-RSA-CAMELLIA128-SHA - unsuccessfull
TLSv1 - DHE-RSA-CAMELLIA256-SHA - unsuccessfull
TLSv1 - ADH-CAMELLIA128-SHA - unsuccessfull
TLSv1 - ADH-CAMELLIA256-SHA - unsuccessfull
TLSv1 - ADH-SEED-SHA - unsuccessfull


TLSv1 cipher score: 90 (A)


TLSv11 - DEFAULT - successfull - 95
TLSv11 - NULL-MD5 - unsuccessfull
TLSv11 - NULL-SHA - unsuccessfull
TLSv11 - EXP-RC4-MD5 - unsuccessfull
TLSv11 - RC4-MD5 - successfull - 80
TLSv11 - RC4-SHA - successfull - 80
TLSv11 - EXP-RC2-CBC-MD5 - unsuccessfull
TLSv11 - IDEA-CBC-SHA - unsuccessfull
TLSv11 - EXP-DES-CBC-SHA - unsuccessfull
TLSv11 - DES-CBC-SHA - unsuccessfull
TLSv11 - DES-CBC3-SHA - successfull - 80
TLSv11 - EXP-EDH-DSS-DES-CBC-SHA - unsuccessfull
TLSv11 - EDH-DSS-CBC-SHA - unsuccessfull
TLSv11 - EDH-DSS-DES-CBC3-SHA - unsuccessfull
TLSv11 - EXP-EDH-RSA-DES-CBC-SHA - unsuccessfull
TLSv11 - EDH-RSA-DES-CBC-SHA - unsuccessfull
TLSv11 - EDH-RSA-DES-CBC3-SHA - unsuccessfull
TLSv11 - EXP-ADH-RC4-MD5 - unsuccessfull
TLSv11 - ADH-RC4-MD5 - unsuccessfull
TLSv11 - EXP-ADH-DES-CBC-SHA - unsuccessfull
TLSv11 - ADH-DES-CBC-SHA - unsuccessfull
TLSv11 - ADH-DES-CBC3-SHA - unsuccessfull
TLSv11 - AES128-SHA - successfull - 80
TLSv11 - AES256-SHA - successfull - 100
TLSv11 - DHE-DSS-AES128-SHA - unsuccessfull
TLSv11 - DHE-DSS-AES256-SHA - unsuccessfull
TLSv11 - DHE-RSA-AES128-SHA - unsuccessfull
TLSv11 - DHE-RSA-AES256-SHA - unsuccessfull
TLSv11 - ADH-AES128-SHA - unsuccessfull
TLSv11 - ADH-AES256-SHA - unsuccessfull
TLSv11 - CAMELLIA128-SHA - unsuccessfull
TLSv11 - CAMELLIA256-SHA - unsuccessfull
TLSv11 - DHE-DSS-CAMELLIA128-SHA - unsuccessfull
TLSv11 - DHE-DSS-CAMELLIA256-SHA - unsuccessfull
TLSv11 - DHE-RSA-CAMELLIA128-SHA - unsuccessfull
TLSv11 - DHE-RSA-CAMELLIA256-SHA - unsuccessfull
TLSv11 - ADH-CAMELLIA128-SHA - unsuccessfull
TLSv11 - ADH-CAMELLIA256-SHA - unsuccessfull
TLSv11 - ADH-SEED-SHA - unsuccessfull


TLSv11 cipher score: 90 (A)


TLSv12 - DEFAULT - successfull - 100
TLSv12 - NULL-MD5 - unsuccessfull
TLSv12 - NULL-SHA - unsuccessfull
TLSv12 - EXP-RC4-MD5 - unsuccessfull
TLSv12 - RC4-MD5 - successfull - 80
TLSv12 - RC4-SHA - successfull - 80
TLSv12 - EXP-RC2-CBC-MD5 - unsuccessfull
TLSv12 - IDEA-CBC-SHA - unsuccessfull
TLSv12 - EXP-DES-CBC-SHA - unsuccessfull
TLSv12 - DES-CBC-SHA - unsuccessfull
TLSv12 - DES-CBC3-SHA - successfull - 80
TLSv12 - EXP-EDH-DSS-DES-CBC-SHA - unsuccessfull
TLSv12 - EDH-DSS-CBC-SHA - unsuccessfull
TLSv12 - EDH-DSS-DES-CBC3-SHA - unsuccessfull
TLSv12 - EXP-EDH-RSA-DES-CBC-SHA - unsuccessfull
TLSv12 - EDH-RSA-DES-CBC-SHA - unsuccessfull
TLSv12 - EDH-RSA-DES-CBC3-SHA - unsuccessfull
TLSv12 - EXP-ADH-RC4-MD5 - unsuccessfull
TLSv12 - ADH-RC4-MD5 - unsuccessfull
TLSv12 - EXP-ADH-DES-CBC-SHA - unsuccessfull
TLSv12 - ADH-DES-CBC-SHA - unsuccessfull
TLSv12 - ADH-DES-CBC3-SHA - unsuccessfull
TLSv12 - AES128-SHA - successfull - 80
TLSv12 - AES256-SHA - successfull - 100
TLSv12 - DHE-DSS-AES128-SHA - unsuccessfull
TLSv12 - DHE-DSS-AES256-SHA - unsuccessfull
TLSv12 - DHE-RSA-AES128-SHA - unsuccessfull
TLSv12 - DHE-RSA-AES256-SHA - unsuccessfull
TLSv12 - ADH-AES128-SHA - unsuccessfull
TLSv12 - ADH-AES256-SHA - unsuccessfull
TLSv12 - CAMELLIA128-SHA - unsuccessfull
TLSv12 - CAMELLIA256-SHA - unsuccessfull
TLSv12 - DHE-DSS-CAMELLIA128-SHA - unsuccessfull
TLSv12 - DHE-DSS-CAMELLIA256-SHA - unsuccessfull
TLSv12 - DHE-RSA-CAMELLIA128-SHA - unsuccessfull
TLSv12 - DHE-RSA-CAMELLIA256-SHA - unsuccessfull
TLSv12 - ADH-CAMELLIA128-SHA - unsuccessfull
TLSv12 - ADH-CAMELLIA256-SHA - unsuccessfull
TLSv12 - ADH-SEED-SHA - unsuccessfull


TLSv12 cipher score: 90 (A)


Protocol score: 90 (A)



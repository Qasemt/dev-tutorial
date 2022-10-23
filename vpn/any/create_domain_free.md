# Create Domain Name and VPS

Start by registering a domain name for your web site. We will use a free name from https://www.freenom.com, and the example domain name used in the rest of this post will be v2tor.cf.
Obtain a Debian 10 virtual private server (VPS). Some popular providers are Bandwagon Host (搬瓦工) and Google Compute Engine (GCE), but you can use a different VPS provider if you prefer.
Note down the server's IP address. We will use as an example the IP address 188.188.188.188.
Back at your domain name registrar, which for us is https://www.freenom.com, add a DNS A record pointing from your server host name (e.g. www, type A, time-to-live 3600 seconds) to your server IP address (e.g. 188.188.188.188). Save these changes.

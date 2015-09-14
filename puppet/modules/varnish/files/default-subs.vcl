# vcl_recv is called whenever a request is received
sub vcl_recv {
    # Serve objects up to 2 minutes past their expiry if the backend
    # is slow to respond.
    set req.grace = 120s;
    set req.http.X-Forwarded-For = client.ip;

    # Since we expose varnish on the default port (6081) we need to rewrite
    # requests that are generated using the default wiki port (8080)
    # This needs to be done early because it's needed for PURGE calls
    if (req.url ~ ":8080") {
        set req.url = regsub(req.url, "(.*):8080/(.*)", "\1:6081/\2");
    }

    # This uses the ACL action called "purge". Basically if a request to
    # PURGE the cache comes from anywhere other than localhost, ignore it.
    if (req.request == "PURGE") {
        if (!client.ip ~ purge) {
            error 405 "Not allowed.";
        }
        return(lookup);
    }

    # Pass any requests that Varnish does not understand straight to the backend.
    if (req.request != "GET" && req.request != "HEAD" &&
        req.request != "PUT" && req.request != "POST" &&
        req.request != "TRACE" && req.request != "OPTIONS" &&
        req.request != "DELETE") {
        return(pipe); /* Non-RFC2616 or CONNECT which is weird. */
    }

    # Pass anything other than GET and HEAD directly.
    if (req.request != "GET" && req.request != "HEAD") {
        return(pass);
    }

    # Pretend that image requests don't have cookie/auth, so that they get cached
    if (req.url ~ "^/images/") {
        unset req.http.Authorization;
        unset req.http.Cookie;
    }

    # Pass requests from logged-in users directly.
    if (req.http.Authorization || req.http.Cookie ~ "wikiUserID=") {
        return(pass);
    }

    # Pass any requests with the "If-None-Match" header directly.
    if (req.http.If-None-Match) {
        return(pass);
    }

    # Force lookup if the request is a no-cache request from the client.
    if (req.http.Cache-Control ~ "no-cache") {
        ban_url(req.url);
    }

    # Pass requests to potential non-plain reads on articles (eg. action=edit)
    if (req.url ~ "^/w/index\.php" || req.url ~ "^/\?title=") {
        return(pass);
    }

    # normalize Accept-Encoding to reduce vary
    if (req.http.Accept-Encoding) {
      if (req.http.User-Agent ~ "MSIE 6") {
        unset req.http.Accept-Encoding;
      } elsif (req.http.Accept-Encoding ~ "gzip") {
        set req.http.Accept-Encoding = "gzip";
      } elsif (req.http.Accept-Encoding ~ "deflate") {
        set req.http.Accept-Encoding = "deflate";
      } else {
        unset req.http.Accept-Encoding;
      }
    }

    return(lookup);
}

sub vcl_pipe {
    # Note that only the first request to the backend will have
    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
    # have it set for all requests, make sure to have:
    # set req.http.connection = "close";

    # This is otherwise not necessary if you do not do any request rewriting.

    set req.http.connection = "close";
}

# Called if the cache has a copy of the page.
sub vcl_hit {
    if (req.request == "PURGE") {
        ban_url(req.url);
        error 200 "Purged";
    }

    if (!obj.ttl > 0s) {
        return(pass);
    }
}

# Called if the cache does not have a copy of the page.
sub vcl_miss {
    if (req.request == "PURGE") {
        error 200 "Not in cache";
    }
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "hit (" + obj.hits + ")";
    } else {
        set resp.http.X-Cache = "miss (0)";
    }
}

# Called after a document has been successfully retrieved from the backend.
sub vcl_fetch {

    # set minimum timeouts to auto-discard stored objects
#       set beresp.prefetch = -30s;
    set beresp.grace = 120s;

    if (beresp.ttl < 48h) {
        set beresp.ttl = 48h;
    }

    if (!beresp.ttl > 0s) {
        return(hit_for_pass);
    }

    if (beresp.http.Set-Cookie) {
        return(hit_for_pass);
    }

#       if (beresp.http.Cache-Control ~ "(private|no-cache|no-store)")
#           {return(hit_for_pass);}

    if (req.http.Authorization && !beresp.http.Cache-Control ~ "public") {
        return(hit_for_pass);
    }
}

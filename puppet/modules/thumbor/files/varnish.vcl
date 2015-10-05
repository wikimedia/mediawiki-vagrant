vcl 4.0;

# vcl_recv is called whenever a request is received
# This is unfortunately a lot of copypasta from default-subs.vcl, because
# there is some default behaviour in there which we don't want (eg. If-None-Match)
# and the only way to avoid it is to run this overridden vcl_recv with a smaller order
# on the vcl
sub vcl_recv {
    set req.http.X-Forwarded-For = client.ip;

    # Copy the thumbnail URLs so that they create variants of the same object
    # By later adding X-Url to the Vary header
    if (req.url ~ "^/images/") {
        set req.http.X-Url = req.url;
    }

    # Since we expose varnish on the default port (6081) we need to rewrite
    # requests that are generated using the default wiki port (8080)
    # This needs to be done early because it's needed for PURGE calls
    if (req.url ~ ":8080") {
        set req.url = regsub(req.url, "(.*):8080/(.*)", "\1:6081/\2");
    }

    # This uses the ACL action called "purge". Basically if a request to
    # PURGE the cache comes from anywhere other than localhost, ignore it.
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return(synth(405, "This IP is not allowed to send PURGE requests."));
        }
        return(hash);
    }

    # Pass any requests that Varnish does not understand straight to the backend.
    if (req.method != "GET" && req.method != "HEAD" &&
        req.method != "PUT" && req.method != "POST" &&
        req.method != "TRACE" && req.method != "OPTIONS" &&
        req.method != "DELETE") {
        return(pipe); /* Non-RFC2616 or CONNECT which is weird. */
    }

    # Force lookup if the request is a no-cache request from the client.
    if (req.http.Cache-Control ~ "no-cache") {
        ban("req.url == " + req.url);
    }

    # qlow jpg thumbs
    if (req.url ~ "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(40):sharpen(0.6,0.01,false)/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\1");
        return (hash);
    # regular jpg thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(87):sharpen(0.6,0.01,false)/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\1");
        return (hash);
    # png thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.png") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\2") + "x/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\1");
        return (hash);
    }

    # Let things go to the default-subs.vcl vcl_recv
}

sub vcl_backend_response {
    if (bereq.http.X-Url) {
        set beresp.http.X-Url = bereq.http.X-Url;

        if (!beresp.http.Vary) {
            set beresp.http.Vary = "X-Url";
        } elsif (beresp.http.Vary !~ "(?i)X-Url") {
            set beresp.http.Vary = beresp.http.Vary + ", X-Url";
        }
    }
}

sub vcl_hash {
    # For thumbnails and originals we hash on the filename, to store them all under the same object. This will make purging any of them purge all of them.
    if (req.http.X-Url ~ "^/images/thumb/") {
        hash_data("Image-" + regsub(req.http.X-Url, "^/images/thumb/[^/]+/[^/]+/([^/]+)/[^/]+$", "\1"));
    } elsif (req.http.X-Url ~ "^/images/") {
        hash_data("Image-" + regsub(req.http.X-Url, "^/images/[^/]+/[^/]+/(.*)", "\1"));
    } elseif (req.http.X-Url) {
        hash_data(req.http.X-Url);
    } else {
        hash_data(req.url);
    }

    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (lookup);
}

vcl 4.0;
import xkey;

# vcl_recv is called whenever a request is received
# This is unfortunately a lot of copypasta from default-subs.vcl, because
# there is some default behaviour in there which we don't want (eg. If-None-Match)
# and the only way to avoid it is to run this overridden vcl_recv with a smaller order
# on the vcl
sub vcl_recv {
    set req.http.X-Forwarded-For = client.ip;

    # Save the original URL because we need to rewrite the request url for the backend
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
            return (synth(405, "This IP is not allowed to send PURGE requests."));
        }

        if (req.url ~ "^/images/thumb/") {
            set req.http.xkey-purge = "File:" + regsub(req.url, "^/images/thumb/[^/]+/[^/]+/([^/]+)/[^/]+$", "\1");
        } elsif (req.url ~ "^/images/") {
            set req.http.xkey-purge = "File:" + regsub(req.url, "^/images/[^/]+/[^/]+/(.*)", "\1");
        } else {
            # Not an identifiable file, regular purge
            return (hash);
        }

        if (xkey.purge(req.http.xkey-purge) != 0) {
            return (synth(200, "Purged"));
        } else {
            return (synth(404, "Key not found"));
        }
    }

    # Pass any requests that Varnish does not understand straight to the backend.
    if (req.method != "GET" && req.method != "HEAD" &&
        req.method != "PUT" && req.method != "POST" &&
        req.method != "TRACE" && req.method != "OPTIONS" &&
        req.method != "DELETE") {
        return (pipe); /* Non-RFC2616 or CONNECT which is weird. */
    }

    # Force lookup if the request is a no-cache request from the client.
    if (req.http.Cache-Control ~ "no-cache") {
        ban("req.url == " + req.url);
    }

    # qlow jpg thumbs
    if (req.url ~ "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(40):sharpen(0.6,0.01,false)/127.0.0.1/images/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\1");
        return (hash);
    # regular jpg thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(87):sharpen(0.6,0.01,false)/127.0.0.1/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\1");
        return (hash);
    # png thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.png") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\2") + "x/127.0.0.1/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\1");
        return (hash);
    }

    # Let things go to the default-subs.vcl vcl_recv
}

sub vcl_backend_response {
    if (bereq.http.X-Url) {
        # Expose the X-Url in the response for debugging purposes
        set beresp.http.X-Url = bereq.http.X-Url;
    }

    if (bereq.http.X-Url ~ "^/images/thumb/") {
        set beresp.http.xkey = "File:" + regsub(bereq.http.X-Url, "^/images/thumb/[^/]+/[^/]+/([^/]+)/[^/]+$", "\1");
    } elsif (bereq.http.X-Url ~ "^/images/") {
        set beresp.http.xkey = "File:" + regsub(bereq.http.X-Url, "^/images/[^/]+/[^/]+/(.*)", "\1");
    }

    # Allow CORS
    set beresp.http.Access-Control-Allow-Origin = "*";
}

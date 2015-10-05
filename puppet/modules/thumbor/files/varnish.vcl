vcl 4.0;

# vcl_recv is called whenever a request is received
sub vcl_recv {
    # Copy the thumbnail URLs so that they create variants of the same object
    # By later adding X-Url to the Vary header
    if (req.url ~ "^/images/") {
        set req.http.X-Url = req.url;
    }

    # Pass any requests with the "If-None-Match" header directly.
    if (req.http.If-None-Match && !req.url ~ "^/images/thumb/.*\.(jpeg|jpg|png)") {
        return(pass);
    }

    # qlow jpg thumbs
    if (req.url ~ "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(40):sharpen(0.6,0.01,false)/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\1");
    # regular jpg thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(87):sharpen(0.6,0.01,false)/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\1");
    # png thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.png") {
        set req.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\2") + "x/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\1");
    }
}

sub vcl_deliver {
    # Thumbor doesn't do fine-grained config for the headers it returns
    if (req.http.X-Url ~ "^/images/thumb/.*\.(jpeg|jpg|png)") {
        unset resp.http.Cache-Control;
        unset resp.http.Expires;
    }
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

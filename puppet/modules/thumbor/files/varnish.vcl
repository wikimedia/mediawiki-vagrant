# vcl_recv is called whenever a request is received
sub vcl_recv {
    # Pass any requests with the "If-None-Match" header directly.
    if (req.http.If-None-Match && !req.url ~ "^/images/thumb/.*\.(jpeg|jpg|png)") {
        return(pass);
    }
}

# Called if the cache does not have a copy of the page.
sub vcl_miss {
    # qlow jpg thumbs
    if (req.url ~ "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)") {
        set bereq.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(40):sharpen(0.6,0.01,false)/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/qlow-(\d+)px-.*\.(jpg|jpeg)", "\1");
    # regular jpg thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)") {
        set bereq.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\2") + "x/filters:quality(87):sharpen(0.6,0.01,false)/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.(jpg|jpeg)", "\1");
    # png thumbs
    } else if (req.url ~ "^/images/thumb/(.*)/(\d+)px-.*\.png") {
        set bereq.url = "/unsafe/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\2") + "x/http://127.0.0.1:8080/images/" + regsub(req.url, "^/images/thumb/(.*)/(\d+)px-.*\.png", "\1");
    }
}

sub vcl_deliver {
    # Thumbor doesn't even fine-grained config for the headers it returns
    if (req.url ~ "^/images/thumb/.*\.(jpeg|jpg|png)") {
        unset resp.http.Cache-Control;
        unset resp.http.Expires;
    }
}

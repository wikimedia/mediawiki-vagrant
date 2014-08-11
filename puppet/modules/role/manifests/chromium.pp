# == Class: role::chromium
#
# Chromium is the open source web browser project from which Google
# Chrome draws its source code. This role provisions a browser instance
# that runs in headless mode and that can be automated by various tools.
class role::chromium {
    include ::chromium
}

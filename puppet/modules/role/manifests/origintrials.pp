# == Class: role::origintrials
# Enables Origin Trials for https://dev.wiki.local.wmftest.net:4430

class role::origintrials {
    mediawiki::settings { 'origintrials':
        values => {
            wgOriginTrials            => [
                # Priority hints: Chrome 73-74, expires 2019-05-09 (renewable, trial ends 2019-05-29)

                'Agv0KONT+NWTohnCv2ck2+/VBAtBMqSpzeSq8i5WS0r90AzrfsVSw94pbEvWU76PMmav3Oh1q+In35ed4KiH+w8AAAB1eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiUHJpb3JpdHlIaW50cyIsImV4cGlyeSI6MTU1NzM4NDYwNSwiaXNTdWJkb21haW4iOnRydWV9',

                # Element Timing for Images: Chrome 73-76, expires 2019-05-09 (renewable, trial ends 2019-09-04)

                'AsU5Tm3NMistsEBeBRBZo7Aw7tX4wvx0pnvQuXdR4rpKqfiQls4uEUeqssCAFh3u8nsmJOpghcRiLXskErB3kQgAAAB7eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRWxlbWVudFRpbWluZ0ltYWdlcyIsImV4cGlyeSI6MTU1NzM4NDk4OSwiaXNTdWJkb21haW4iOnRydWV9',

                # Event Timing: Chrome 68-74, expires 2019-05-09 (renewable, trial ends 2019-05-29)

                'AqtgpahQBVtaEaHb3A9YCscb9qcK3csjM+X3p4L2wniQk2RIEhB0WkLf+cpUacr6S+rlVpg+DcQ+yvIczUDkOw8AAABzeyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRXZlbnRUaW1pbmciLCJleHBpcnkiOjE1NTczODQzMzUsImlzU3ViZG9tYWluIjp0cnVlfQ==',

                # Feature Policy Reporting: Chrome 73-75, expires 2019-05-09 (renewable, trial ends 2019-07-24)

                'AqjZKHUo2M8HsZKfmsBpdLKsO+wwMLL/9hwS4aAdiNlkP7g95eRBBCI4Ax1IMkZT6PQv4HYusQTwphwt6HkxxQ8AAAB+eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRmVhdHVyZVBvbGljeVJlcG9ydGluZyIsImV4cGlyeSI6MTU1NzM4NDkxMSwiaXNTdWJkb21haW4iOnRydWV9',

                # Layout Stability API: Chrome 73-76, expires 2019-04-03 (renewable, trial ends 2019-09-04)

                'AvLeOZtM3CEnULsc/RQgAos1beakf4baZYAvvUjBNcQwloLdxSjT13BrBpcqgYVt/mbazBPDqQhhCmuu3VuzYw4AAAB1eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiTGF5b3V0SmFua0FQSSIsImV4cGlyeSI6MTU1NDI5NDg3MywiaXNTdWJkb21haW4iOnRydWV9'
            ],
            wgReportToExpiry          => 60,
            wgReportToEndpoints       => [
                'https://reportingapi.tools/public/submit'
            ],
            wgFeaturePolicyReportOnly => [
                "sync-xhr 'none'"
            ],
            wgElementTiming           => true,
            wgPriorityHints           => true,
        }
    }
}

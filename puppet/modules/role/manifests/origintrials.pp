# == Class: role::origintrials
# Enables Origin Trials for https://dev.wiki.local.wmftest.net:4430

class role::origintrials {
    mediawiki::settings { 'origintrials':
        values => {
            wgOriginTrials            => [
                # Priority hints: Chrome 73-74, expires 2019-04-03 (renewable, trial ends 2019-05-29)

                'AhmgH5nrTnUNfg+JFm18dpkfm66m+iK/ueB8LPegI+RYQKhvGCtJcF9AGYlVL8LXg9eMQ83KBaz7SqgTPI0I+g8AAAB1eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiUHJpb3JpdHlIaW50cyIsImV4cGlyeSI6MTU1NDI5NDAxNCwiaXNTdWJkb21haW4iOnRydWV9',

                # Element Timing for Images: Chrome 73-76, expires 2019-04-03 (renewable, trial ends 2019-09-04)

                'AmezOgGPfeJI3Qy39Adxfrf65KUwKmcmkGQnPbZfwTePEGV4wb3flhrEkAb+bcTiQPq5hBW9qG5OPi8dtrqaPwUAAAB7eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRWxlbWVudFRpbWluZ0ltYWdlcyIsImV4cGlyeSI6MTU1NDI5NDYwMiwiaXNTdWJkb21haW4iOnRydWV9',

                # Event Timing: Chrome 68-74, expires 2019-04-03 (renewable, trial ends 2019-05-29)

                'ArjpY5YrvXSWN+sGIDlrNT6iC8bos8P57UbzyxZDosJfPnN1PV5oZ6vt/drg8R4L7vzIyBf8tCPeQZJFSm/4DAUAAABzeyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRXZlbnRUaW1pbmciLCJleHBpcnkiOjE1NTQyOTQ3MDcsImlzU3ViZG9tYWluIjp0cnVlfQ==',

                # Feature Policy Reporting: Chrome 73-75, expires 2019-04-03 (renewable, trial ends 2019-07-24)

                'AgU95qStuyOj7ABwOKC9SQR6hBSUheNpw7tpJFwOlUh7+x0eq2IwtX4Gb46mnEQd0E2OkiYb79tAqDcUJPhLsAoAAAB+eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRmVhdHVyZVBvbGljeVJlcG9ydGluZyIsImV4cGlyeSI6MTU1NDI5NDgwMSwiaXNTdWJkb21haW4iOnRydWV9',

                # Layout Stability API: Chrome 73-76, expires 2019-04-03 (renewable, trial ends 2019-09-04)

                'AvLeOZtM3CEnULsc/RQgAos1beakf4baZYAvvUjBNcQwloLdxSjT13BrBpcqgYVt/mbazBPDqQhhCmuu3VuzYw4AAAB1eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiTGF5b3V0SmFua0FQSSIsImV4cGlyeSI6MTU1NDI5NDg3MywiaXNTdWJkb21haW4iOnRydWV9',

                # Shape Detection API, expires 2019-03-06 (non-renewable, trial ends 2019-03-06)

                'AuTQbZFyhF6J7E62t7hkG/V7Gx2ANYFtrk1TbioE3p7Mrz7NfDOAKJKhG0exqmGZ8pgh9dTnhd3tnFi66xs8UQ0AAAB2eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiU2hhcGVEZXRlY3Rpb24iLCJleHBpcnkiOjE1NTE4MzAzOTksImlzU3ViZG9tYWluIjp0cnVlfQ=='
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

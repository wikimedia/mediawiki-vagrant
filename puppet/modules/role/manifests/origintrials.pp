# == Class: role::origintrials
# Enables Origin Trials for https://dev.wiki.local.wmftest.net:4430

class role::origintrials {
    mediawiki::settings { 'origintrials':
        values => {
            wgOriginTrials            => [
                # Priority hints: Chrome 73-76, expires 2019-06-23 (renewable, trial ends 2019-09-04)

                'ApOdp2cC5d/eRBFoDu9d0RUj71QUvXlBJ8ItzyE5bot75FnWQDr+vnOeRRTxNxqooTloH8DA9uCIznmHDeZkXQYAAAB1eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiUHJpb3JpdHlIaW50cyIsImV4cGlyeSI6MTU2MTI5MzY5OSwiaXNTdWJkb21haW4iOnRydWV9',

                # Element Timing for Images: Chrome 73-76, expires 2019-06-23 (renewable, trial ends 2019-09-04)

                'Al+C0/IkhHWWdx+Ibmms2HSVNDMo35sEa1H8cN1tK0PG1FMbLSOw77qTBweenVCvFIrB1rnOfvMYUjSsosSqOgMAAAB7eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRWxlbWVudFRpbWluZ0ltYWdlcyIsImV4cGlyeSI6MTU2MTI5MzMzNSwiaXNTdWJkb21haW4iOnRydWV9',

                # Event Timing: Chrome 68-75, expires 2019-06-23 (renewable, trial ends 2019-07-24)

                'Av00Dl155RJppzkab8TAvOblf9+lb4rwogba148hyvJ1SZSHOZGPlEMTCyYpO2C4jAajg1XdWRBrjrDilArDEgsAAABzeyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRXZlbnRUaW1pbmciLCJleHBpcnkiOjE1NjEyOTMzOTksImlzU3ViZG9tYWluIjp0cnVlfQ==',

                # Feature Policy Reporting: Chrome 73-75, expires 2019-06-23 (renewable, trial ends 2019-07-24)

                'AqIQhpBKHBEOcxAjNTt5vVGnlcFPS8vvpvpry5xp5HyHEpxguuOp/9r1qLFasuKDcmUHJMu+Vzm/HAE+mYUxTQsAAAB+eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiRmVhdHVyZVBvbGljeVJlcG9ydGluZyIsImV4cGlyeSI6MTU2MTI5MzQ0NywiaXNTdWJkb21haW4iOnRydWV9',

                # Layout Stability API: Chrome 73-76, expires 2019-06-23 (renewable, trial ends 2019-09-04)

                'ArjJjTh9z2qGTD2oyBTIwkh8m9p+KKszZD3oxvZiCUitIjNiw2CE+XENg4pNPaGFbyKSlKIZ67QyCuMPYDWloAMAAAB1eyJvcmlnaW4iOiJodHRwczovL2Rldi53aWtpLmxvY2FsLndtZnRlc3QubmV0OjQ0MzAiLCJmZWF0dXJlIjoiTGF5b3V0SmFua0FQSSIsImV4cGlyeSI6MTU2MTI5MzYyNiwiaXNTdWJkb21haW4iOnRydWV9'
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

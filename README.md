# `ledger-cli` reporting tools
This is a collection of utils to help with plotting and reporting on
the ledger transactions.

It is based on work found on (this blog post)[https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/].

You're welcome to fork and do your thing. You are not welcome to
request features. I might be bothered to pull but don't bet on it as
these are meant to be for my personal use.

The licensing here is ... permissive.

## Utils
### `monthly-income-vs-expenses` utility
This script facilities plotting of a ledger register report of
monthly expenses vs monthly income.

Examples of use:

    monthly-income-vs-expenses ledger.dat
    monthly-income-vs-expenses ledger.dat 2017
    monthly-income-vs-expenses ledger.dat "from 2016/01 to 2016/04"

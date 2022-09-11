# perf-benchmark-tool

Using perf for benchmark in an easier way.

Run `sudo bash get-valid-events.sh` first. Then run `sudo bash test-events.sh N M`, where *N* stands for the number of groups and *M* indicates how many number of repeats you wan to test for a single group.

The first script will collect all the valid events listed by `perf list` on your computer system (instead of all supported). The second script will help test how many (hardware and software) events can be run in a single test without inducing too much precision loss. 

A `exit 0` command was added in "test-events.sh" script in line 65. You will need to uncomment it to just run a test with this script rather then testing the whole set of perf_events for lots of hours.

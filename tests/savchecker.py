#!/usr/bin/env python3
# script for checking the SAV file after running the tester ROM
# script exits with code 1 if any test had a nonzero result, 0 otherwise.

import sys

if __name__ == "__main__":

    if len(sys.argv) != 2:
        print("usage: savchecker.py <sav file>")
        sys.exit(1)
    
    with open(sys.argv[1], "rb") as sav:
        data = sav.read()

        totalResults = data[0]

        exitcode = 0

        if totalResults == 0:
            print("No test results to report.")
        else:
            dataCounter = 1
            passCount = 0
            for i in range(data[0]):
                # test result
                result = data[dataCounter]
                dataCounter += 1
                # get the test name
                length = 0
                while data[dataCounter + length] != 0:
                    length += 1
                name = str(data[dataCounter : dataCounter + length], 'utf-8')
                dataCounter += length + 1

                print("{0:.<67}.${1:02X} ({2})".format(name, result, "Passed" if result == 0 else "Failed"))

                if result == 0:
                    passCount += 1
            print("({0}/{1}) tests passed".format(passCount, totalResults))
            if passCount != totalResults:
                exitcode = 1

    sys.exit(exitcode)

#!/usr/bin/env python
# Takes members-of-congress-raw.csv as STDIN, writes to STDOUT
import csv
import sys
import datetime

members = csv.DictReader(sys.stdin, delimiter=',', quotechar='"')

today = datetime.datetime.now().date()
def years_since(d):
    earlier = datetime.datetime.strptime(d, "%Y-%m-%d").date()
    diff = today - earlier
    approx_years = round(diff.days / 365.25, 2) # Leap years are tricky
    return approx_years

def convert_member(m):
    return {
        "lastname": m["person__lastname"],
        "firstname": m["person__firstname"],
        "nickname": m["person__nickname"],
        "role_type": m["role_type"],
        "senator_rank": m["senator_rank"],
        "state": m["state"],
        "party": m["party"],
        "is_republican": m["party"] == "Republican",
        "gender": m["person__gender"],
        "is_male": m["person__gender"] == "male",
        "age": years_since(m["person__birthday"])
    }

converted = map(convert_member, members)

fieldnames = [ "lastname", "firstname", "nickname", "role_type", "senator_rank", "state", "party", "is_republican", "gender", "is_male", "age" ] 

writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
writer.writeheader()
map(writer.writerow, converted)

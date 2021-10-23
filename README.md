# lastlocalcase-sg - Last Local COVID-19 Case in Singapore
A webpage showing the number of days since the last local COVID-19 case in Singapore.

**This project is no longer supported as Singapore is no longer aiming for 0 cases.**  


## Why did I make this?
I simply made it because I like streaks and there wasn't a easy place I could find that told me how many days we've had in Singapore since our last COVID-19 case.

## How does it work?
Unfortunately MoH doesn't have an API for their daily COVID-19 updates.  I simply scrape the data hourly from this site: https://www.moh.gov.sg/covid-19/past-updates

## Useful endpoints
I've included some useful endpoints in case you want to use the data yourself.

### Basic Text
A text based response with only the number of days since the last case.

URL:  https://lastlocalcase.sg/text

Usage:
```angular2html
curl https://lastlocalcase.sg/text
2
```

### Lightweight JSON
A lightweight JSON response with the number of days since the last case and when the last case was detected.

URL: https://lastlocalcase.sg/json 

Usage:
```angular2html
curl https://lastlocalcase.sg/json
{
    "streak": 2,
    "streak_start": "01 Apr 2021"
}
```

### Raw data
The raw JSON data used to populate the data on the site.

URL: https://lastlocalcase.sg/cases.json 

Usage:
```angular2html
curl https://lastlocalcase.sg/cases.json
{
    "cases": {
        "02 Apr 2021": 0,
        "01 Apr 2021": 0,
...snip...
    "lastupdated": "03 Apr 2021 14:27:49 UTC+8"
}%                      
```
import requests
import boto3
from botocore.exceptions import ClientError
from bs4 import BeautifulSoup
import datetime
import json
from collections import OrderedDict

updates_url = 'https://www.moh.gov.sg/covid-19/past-updates'


def upload_file(file_data, file_name, bucket, object_name=None):
    """Upload a file to an S3 bucket

    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """

    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = file_name

    # Upload the file
    s3_client = boto3.client('s3')
    try:
        response = s3_client.put_object(Body=file_data, Bucket=bucket, Key=object_name)

    except ClientError as e:
        print(e)
        return False
    return True


def find_streak(cases):
    firststreak = 0
    firststart = None
    firstend = None
    secondstreak = 0
    secondstart = None
    secondend = None
    on_to_the_second = False
    for casedate in cases['cases']:
        count = cases['cases'][casedate]
        if count == 0 and on_to_the_second == False:
            firststreak += 1
            firststart = casedate
            if firststreak == 1:
                firstend = casedate
        elif count > 0:
            if secondstreak > 0:
                break
            on_to_the_second = True
            continue
        elif count == 0 and firststreak > 0:
            secondstreak += 1
            secondstart = casedate
            if secondstreak == 1:
                secondend = casedate
        else:
            break
    cases['first_streak'] = firststreak
    cases['first_start'] = firststart
    cases['first_end'] = firstend
    cases['second_streak'] = secondstreak
    cases['second_start'] = secondstart
    cases['second_end'] = secondend
    return cases


def handler(event, context):
    casedict = OrderedDict()
    casedict['cases'] = OrderedDict()
    r = requests.get('https://www.moh.gov.sg/covid-19/past-updates')
    if r.status_code == 200:
        soup = BeautifulSoup(r.content, "html.parser")
        tables = soup.find_all("table")
        for table in tables:
            rows = table.find_all('tr')
            for row in rows:
                thedate = None
                cols = row.find_all('td')
                num = 1
                cases = None
                for col in cols:
                    data = col.span.text.strip()
                    if num == 1:
                        try:
                            thedate = datetime.datetime.strptime(data, '%d %b %Y')
                        except Exception as e:
                            continue
                        num += 1
                        continue
                    if num == 2:
                        if 'locally transmitted covid-19 infection' in data.lower():
                            case_str = data.lower().split(' ')[0]
                            if case_str == 'no':
                                cases = 0
                            if case_str.isdigit():
                                cases = int(case_str)
                    if cases != None and thedate != None:
                        if not thedate.strftime('%d %b %Y') in casedict['cases'].keys():
                            print(f'Adding {thedate.strftime("%d %b %Y")} {cases}')
                            casedict['cases'][thedate.strftime('%d %b %Y')] = cases
                    num = 1
                    break
    casedict = find_streak(casedict)
    c = json.dumps(casedict, indent=4)
    file_name = 'cases.json'
    upload_file(c, file_name, 'lastlocalcase.sg')
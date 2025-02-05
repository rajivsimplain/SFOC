import logging
import logging.config
import argparse
import configparser
import sqlite3
import requests
import json
import shutil
import os
from datetime import datetime

logging.config.fileConfig('logging.conf')
logger = logging.getLogger(__name__)

def createSession(url,storenum,file):

    path = 'CreateSession'
    sessionApi = url + path
    #'http://posdbsv01/api/FileProcessing/CreateSession'
    #sessionApi = 'https://36101.wiremockapi.cloud/api/FileProcessing/CreateSession'

    headers = {
        'Content-Type': 'application/json',
        'X-API-Key': '5ecc3b56-e437-4ed3-acdd-91e22b7c8570'
    }
    payload = {
        'storeId': storenum,
        'fileName': file
    }
    json_payload = json.dumps(payload)

    # Make the POST request
    response = requests.post(sessionApi, headers=headers, data=json_payload)

    # Check the response
    if response.status_code == 200:
        logger.debug('Request successful!')
        logger.debug(response.json())
        data = response.json()
        return data['sessionId']
    else:
        logger.debug('Request failed!')
        logger.debug(response.json())
        return None

def processFile(url,sessionId):
    #sessionApi = 'https://POSDBSV01:7244/api/FileProcessing/ProcessFile'
    #sessionApi = 'https://36101.wiremockapi.cloud/api/FileProcessing/ProcessFile'
    path = 'ProcessFile'
    sessionApi = url + path

    data = {
        'sessionId': sessionId
    }

    headers = {
        'Content-Type': 'application/json',
        'X-API-Key': '5ecc3b56-e437-4ed3-acdd-91e22b7c8570'
    }

    response = requests.post(sessionApi, params=data)
    if response.status_code == 200:
        logger.debug("Request successful!")
        logger.debug(response.text)
        data = response.json()
        return data['invoices']
    else:
        logger.debug("Request failed with status code:", response.status_code)

def insert_to_db(invoiceLst):
    connection = sqlite3.connect("DexDB.db")
    logger.debug(f"DB Connection : {connection.total_changes} ")

    cursor = connection.cursor()

    for invoice in invoiceLst:
        logger.debug(f"Writing Invoice Details to  the table for {invoice}")
        current_timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        retry = 0
        status = 0
        query = f'''INSERT INTO PROCESS_TABLE (SessionId,DateTime,InvoiceNum,Retry,Status) VALUES (\'{sessionId}\',\'{current_timestamp}\',\'{invoice}\',{retry},{status})'''
        cursor.execute(query)
    connection.commit()
    logger.debug(f"DB Handling complete")
    connection.close()

def move_or_copy_files(file_name, source_dir, destination_dir, action="move"):
    logger.debug(f"Source Folder {source_dir} Destination Folder: {destination_dir} File Name:{file_name}")

    source_file = os.path.join(source_dir, file_name)
    destination_file = r"" + destination_dir + file_name

    if os.path.isfile(source_file):
        if action == "move":
            shutil.move(source_file, destination_file)
            logger.debug(f"Moved {source_file} to {destination_file}")
        elif action == "copy":
            shutil.copy(source_file, destination_file)
            logger.debug(f"Copied {source_file} to {destination_file}")
        else:
            raise ValueError("Invalid action. Must be 'move' or 'copy'.")


def main():
    logger.debug('Start of the Stub Program')
    parser = argparse.ArgumentParser(description='Stub Application to Handle Dex Files.')
    parser.add_argument('-f', '--fname', type=str, help='Dex File Name')
    parser.add_argument('-d', '--dirname', type=str, help='Dex File data Directory')
    args = parser.parse_args()
    logger.debug(f"Name of the 894 File to be Integrated: {args.fname} ")
    logger.debug(f"Name of Folder that has the 894 File: {args.dirname} ")

    # Create a ConfigParser object
    config = configparser.ConfigParser()
    # Read the config file
    config.read('config.ini')
    logger.debug("Parsing the Configuration file.")

    storenum = config['settings']['store']
    archiveDir = config['settings']['Archive']
    remoteDir = config['settings']['Remote_Path']
    serverUrl = config['settings']['server_url']

    logger.debug(f"Associated store: {storenum} ")
    logger.debug(f"Remote Dir: {remoteDir} ")
    logger.debug(f"Archive Dir: {archiveDir} ")
    logger.debug(f"Server URK: {serverUrl} ")

    if args.fname:
        # Move/Copy the file to Remote and Archive
        logger.debug(f"Starting the Movement of the file to archive and Remote Folders: {args.fname} ")
        move_or_copy_files(args.fname, args.dirname, archiveDir, action="copy")
        move_or_copy_files(args.fname, args.dirname, remoteDir, action="move")
    else:
        logger.critical("There is no File provided as argument ")

    sessionId = createSession(serverUrl, storenum, args.fname)
    logger.debug(f"Session Id :{sessionId}")

    if sessionId:
        invList = processFile(serverUrl, sessionId)
        logger.debug(f"Invoice List :{invList}")

    insert_to_db(invList)

    logger.debug(f"Initiating a DB Connection")

if __name__ == '__main__':
    main()
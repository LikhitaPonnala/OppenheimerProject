*** Settings ***
Documentation  API Testing in Robot Framework
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections

*** Variables ***
${base_url}    http://localhost:8080/
${dispense_url}    http://localhost:8080/dispense
${CONTENT_TYPE}    application/json
${BROWSER}          Chrome
${UploadFiletest}           css=[type='file']
${AddFile}           ${CURDIR}\\myFile.csv
${Dtable}    //*[@id="contents"]/div[2]/table
${SaveFile}    ${CURDIR}\\result.png
${Red_Color}    rgba(220, 53, 69, 1)

*** Test Cases ***
T001_Clerk_Insert_Single_Record
    [documentation]  Single record of a working class hero should consist of Natural Id
    ...    (natid), Name, Gender, Birthday, Salary and Tax paid
    [tags]  Post    Clerk
    Create Session  mysession  ${base_url}  verify=true
	&{header}=  Create Dictionary   Content-Type=${CONTENT_TYPE}   User-Agent=RobotFramework
    ${response}=  POST On Session  mysession  /calculator/insert  data={"birthday":"14081995","gender":"F","name":"Likhita","natid":"L9493956300","salary":"15000","tax":"2000"}   headers=${header}
    Status Should Be   202  ${response}  #Check Status 202 means record inserted
	Set Test Message       ${response}
	
T002_Clerk_Insert_Multiple_Records
    [documentation]  As the Clerk, I should be able to insert more than one working
	...    class hero into database via an API
    [tags]  Post    Clerk
    Create Session  mysession  ${base_url}  verify=true
	&{header}=  Create Dictionary   Content-Type=${CONTENT_TYPE}   User-Agent=RobotFramework
    ${response}=  POST On Session  mysession  /calculator/insertMultiple  data=[{"birthday":"15081955","gender":"M","name":"Peter","natid":"L8919277655","salary":"16000","tax":"143"},{"birthday":"13081995","gender":"F","name":"Mounika","natid":"F12345678","salary":"25000","tax":"3000"}]  headers=${header}
    Status Should Be   202  ${response}
	Set Test Message       ${response}
	
T003_Clerk_Upload_Csv_File
    [documentation]  As the Clerk, I should be able to upload a csv file to a portal so
	...   that I can populate the database from a UI
    [tags]  Post    File_Upload    Clerk
	Open Browser      ${base_url}    ${BROWSER}    options=add_argument("--start-maximized")
    Sleep             3
    Title Should Be   Technical Challenge for CDS
	Execute Javascript    window.scrollTo(0, window.scrollY+300)
	Choose File   ${UploadFiletest}     ${AddFile}
	Sleep             1
	Click Button   Refresh Tax Relief Table
	Sleep             4
	Capture Element Screenshot    ${Dtable}    ${SaveFile}
	Close Browser
	
T004_Bookkeeper_Tax_relief_Query
    [documentation]  As the Bookkeeper, I should be able to query the amount of tax
    ...    relief for each person in the database so that I can report the
    ...    figures to my Bookkeeping Manager
    [tags]  Get    Bookkeeper
    Create Session  mysession  ${base_url}  verify=true
	&{header}=  Create Dictionary   Content-Type=${CONTENT_TYPE}   User-Agent=RobotFramework
    ${response}=  GET On Session  mysession  /calculator/taxRelief    headers=${header}
    Status Should Be   200  ${response}
	Set Test Message       ${response.content}
	
T005_Governor_Dispense_Check
    [documentation]  As the Governor, I should be able to see a button on the screen so
	...  that I can dispense tax relief for my working class heroes
    [tags]  Governor
	Open Browser      ${base_url}    ${BROWSER}    options=add_argument("--start-maximized")
    Sleep             3
	Element Text Should Be    //*[@id="contents"]/a[2]    Dispense Now
	${elements}    Get Webelement    //*[@id="contents"]/a[2]
	${bg_color}    Call Method    ${elements}    value_of_css_property    background-color
	Should be equal   ${bg_color}    ${Red_Color}
	Scroll Element Into View    //*[@id="contents"]/a[2]
	Click Link    Dispense Now
	Sleep             3
	${url}=   Get Location
	Should be equal   ${url}    ${dispense_url}
	Element Text Should Be    //*[@id="app"]/div/main/div/div/div    Cash dispensed
	Close Browser
	
T001_Clerk_Insert_Single_Record_Neg
    [documentation]  Single record of a working class hero should consist of Natural Id
    ...    (natid), Name, Gender, Birthday, Salary and Tax paid
    [tags]  Post    Clerk
    Create Session  mysession  ${base_url}  verify=true
	&{header}=  Create Dictionary   Content-Type=${CONTENT_TYPE}   User-Agent=RobotFramework
    ${response}=  Run Keyword And Ignore Error    POST On Session  mysession  /calculator/insert  data={"birthday":"14-08-1995","gender":"F","name":"Likhita","natid":"P8919277655","salary":"15000","tax":"2000"}   headers=${header}
    Status Should Be   FAIL  ${response}  #Check Status 500 means record not inserted
	Set Test Message       ${response}

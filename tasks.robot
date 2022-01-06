*** Settings ***

Documentation     Template robot main suite.

Library         RPA.HTTP
Library         RPA.Robocloud.Secrets
Library         RPA.PDF
Library         RPA.Browser.Selenium
Library         RPA.Tables
Library         RPA.Archive
Library         Dialogs
Library         RPA.FileSystem
Library         RPA.core.notebook



***Keywords***

Open the link
    ${link}=    Get Secret    weburl
    Open Available Browser  ${link}[link]
    Maximize Browser Window
    
Download the csv
    
    ${CSV_LINK}=    Get Value From User    KINDLY ENTER CSV LINK:-    
    Download    ${CSV_LINK}    orders.csv
    Sleep    2 seconds
Startup Cleaning
    Create Directory    ${CURDIR}${/}output



Loop
    
    @{data}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{data}
        Click Button    Yep
        Select From List By Value    //*[@id="head"]    ${row}[Head]
        Click Button    //*[@id="id-body-${row}[Body]"]
        Input Text    //input[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
        Input Text    //*[@id="address"]    ${row}[Address]
        Click Button    //*[@id="preview"]
        Wait Until Element Is Visible   //*[@id="robot-preview-image"]
        Capture Element Screenshot    //*[@id="robot-preview-image"]    ${CURDIR}${/}output${/}${row}[Order number].png
        Sleep    2 seconds
        Wait Until Element Is Visible   //button[@id="order"]
        Click Button  //button[@id="order"]
        Check Process
        Wait Until Page Contains Element    //*[@id="receipt"]    timeout=20
        Sleep    2 seconds
        ${reciept_data}=  Get Element Attribute  //*[@id="receipt"]  outerHTML
        Html To Pdf  ${reciept_data}  ${CURDIR}${/}output${/}${row}[Order number].pdf
        Click Button  //button[@id="order-another"]
        Add Watermark Image To Pdf    ${CURDIR}${/}output${/}${row}[Order number].png    ${CURDIR}${/}output${/}${row}[Order number].pdf    ${CURDIR}${/}output${/}${row}[Order number].pdf      
        
    END

        
Creating a ZIP archive
   Archive Folder With ZIP   ${CURDIR}${/}output  PDFRECEIPTS.zip   recursive=True    include=*.pdf    exclude=*.png
   @{files}                  List Archive             PDFRECEIPTS.zip
   FOR  ${file}  IN  ${files}
      Log  ${file}
   END

Check Process
    FOR  ${i}  IN RANGE  ${20}
        ${alert}=  Is Element Visible  //div[@class="alert alert-danger"]  
        Run Keyword If  '${alert}'=='True'  Click Button  //button[@id="order"] 
        Exit For Loop If  '${alert}'=='False'       
    END
    
    Run Keyword If  '${alert}'=='True'  REPEATPROCESS

    
REPEATPROCESS
    Close Browser
    Open the link
    Continue For Loop




*** Tasks ***
Minimal task
    Startup Cleaning
    Open the link
    Download the csv
    Loop   
    Creating a ZIP archive
    
    


*** Settings ***
Documentation       Template robot main suite.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Archive
Library    RPA.FileSystem
Library    RPA.PDF
Library    RPA.Tables
Library    RPA.Robocorp.WorkItems


*** Tasks ***
Tasks
    Launch the website
    Log In
    Download the Excel
    Load Data from Excel and Fill the form
    Merge Screenshot
    Compress all pdf into one ZIP


*** Keywords ***
Launch the website
    Open Available Browser    https://robotsparebinindustries.com/#/    

Log In
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Click Button    //*[@id="root"]/div/div/div/div[1]/form/button
    Wait Until Element Is Visible    //*[@id="root"]/header/div/ul/li[2]/a
    Click Element    //*[@id="root"]/header/div/ul/li[2]/a
    Wait Until Element Is Visible    //*[@id="root"]/header/div/ul/li[2]/a
    Click Button    OK

Download the Excel 
    Download    https://robotsparebinindustries.com/orders.csv    orders.csv    overwrite=True

Load Data from Excel and Fill the form
    
    ${OrderData}=    Read table from CSV    orders.csv    

    FOR    ${ord}    IN    @{OrderData}
        Fill and submit the form    ${ord}     
    END

Fill and submit the form
    [Arguments]    ${order}
    Wait Until Element Is Visible    //*[@id="root"]
    Select From List By Index    //*[@id="head"]    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    //div[3]/input    ${order}[Legs]
    Input Text    address    t${order}[Address]
    Click Button    preview
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]    
    Sleep    5 seconds
    Click Button    order
    FOR    ${counter}    IN RANGE    ${100}
        ${alert}=    Is Element Visible    //div[@class="alert alert-danger"]
        IF    '${alert}' == 'True'    Click Button    //button[@id="order"]
        IF    '${alert}' == 'False'    BREAK    
    END
    
    Sleep    5 seconds
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]
    Wait Until Element Is Visible    //*[@id="receipt"]

    Screenshot    //*[@id="robot-preview-image"]    ${CURDIR}${/}robots${/}${order}[Order number].png
    ${reciept}=    Get Element Attribute    //*[@id="receipt"]    outerHTML

    Html To Pdf    ${reciept}    ${CURDIR}${/}reciepts${/}${order}[Order number].pdf

    
    Click Button    //*[@id="order-another"]
    Wait Until Element Is Visible    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Click Button    OK

Merge Screenshot
    FOR    ${counter}    IN RANGE    1    21    
        Open Pdf    ${CURDIR}${/}reciepts${/}${counter}.pdf
        Add Watermark Image To Pdf    ${CURDIR}${/}robots${/}${counter}.png    ${CURDIR}${/}reciepts${/}${counter}.pdf
        Close Pdf    ${CURDIR}${/}reciepts${/}${counter}.pdf
    END

Compress all pdf into one ZIP
    Archive Folder With Zip    ${CURDIR}${/}reciepts    ${OUTPUT_DIR}${/}reciepts.zip

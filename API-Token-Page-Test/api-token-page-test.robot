*** Settings ***

Library    SeleniumLibrary

*** Variables ***
${testLink}    https://app.deriv.com/account/api-token
@{SCOPES}=    Read    Trade    Payments    Trading information    Admin
@{CHECKBOX_NAMES}=    read    trade    payments    trading_information    admin 
${createTokenButton}    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large dc-btn__button-group da-api-token__button"]
${submitDelete}    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large dc-dialog__button"]

*** Keywords ***
Clear Input Fields
    Press Keys    None    CTRL+a\ue003

Check Unticked Boxes
    FOR  ${item}  IN  @{CHECKBOX_NAMES}
        Page Should Contain Checkbox    //*[@name='${item}']
        Checkbox Should Not Be Selected    //*[@name='${item}']
    END

*** Test Cases ***
TC_01 TC_02 Login Deriv
    Open Browser    ${testLink}    chrome
    Wait Until Page Contains Element    //input[@type='email']    300
    Input Text    //input[@type='email']    
    Input Text    //input[@type='password']    
    Click Element    //button[@type='submit']
    Sleep    2

TC_03 Check correct directory
    Maximize Browser Window
    Reload Page
    Wait Until Element Is Visible    //div[@data-testid="dt_themed_scrollbars"]    40  
    Location Should Be    ${testLink}

TC_04 Default Page
    Wait Until Page Contains    Read    300
    FOR  ${item}  IN  @{SCOPES}
        Page Should Contain    ${item}
    END
    Check Unticked Boxes
    Element Should Be Disabled    ${createTokenButton}

TC_05 Create Button Disabled if no token picked
    Click Element    //input[@name="token_name"]
    Input Text    //input[@name="token_name"]    Test_no_token
    Check Unticked Boxes
    Element Should Be Disabled    ${createTokenButton}
    Click Element    //input[@name="token_name"]
    Clear Input Fields

TC_06 Scopes boxes are tickable
    FOR  ${item}  IN  @{CHECKBOX_NAMES}
        Page Should Contain Checkbox    //*[@name='${item}']
        Click Element    //*[@name='${item}']//parent::label
        Checkbox Should Be Selected    //*[@name='${item}']
    END

TC_07 Scopes boxes are untickable
    FOR  ${item}  IN  @{CHECKBOX_NAMES}
        Checkbox Should Be Selected    //*[@name='${item}']
        Click Element    //*[@name='${item}']//parent::label
        Checkbox Should Not Be Selected    //*[@name='${item}']
    END
    
TC_08 TC_09 TC_10 Generate token, verify token, delete token
    FOR  ${item}  IN  @{CHECKBOX_NAMES}
        Page Should Contain Checkbox    //*[@name='${item}']
        Click Element    //*[@name='${item}']//parent::label
        Checkbox Should Be Selected    //*[@name='${item}']
        Element Should Be Disabled    ${createTokenButton}
        IF  "${item}" == "trading_information"
            ${item}=    Set Variable    Trading information
        ELSE
            ${item}=    Set Variable    ${item.title()}
        END
        Click Element    //input[@name="token_name"]
        Input Text    //input[@name="token_name"]    Test_1
        Click Element    ${createTokenButton}
        Wait Until Element Is Visible    //div[@class="da-api-token__pass-dot-container"]    40
        Element Text Should Be    //*[@class="da-api-token__table-cell da-api-token__table-cell--name"]    Test_1
        Element Should Be Visible    //div[@class="da-api-token__pass-dot"]    10
        Page Should Not Contain    //p[@class="dc-text"]//parent::div[@class="da-api-token__clipboard-wrapper"]
        Click Element    //*[@class="dc-icon da-api-token__visibility-icon"]
        Element Should Be Visible    //p[@class="dc-text"]//parent::div[@class="da-api-token__clipboard-wrapper"]    20
        Page Should Not Contain    //div[@class="da-api-token__pass-dot"]
        Click Element    //*[@class="dc-icon da-api-token__visibility-icon"]
        IF  "${item}" == "Admin"
            Click Element    //*[@class="dc-icon dc-clipboard"]
            Sleep    1
            Page Should Contain    Be careful
            Click Button    ${submitDelete}
            Click Element    //input[@name="token_name"]
            Press Keys    None    CTRL+v
            Should Not Be Empty    //input[@name="token_name"]
            Clear Input Fields
            Element Should Contain    //label[@class="dc-input__label"]    Token name
            Page Should Contain Element    //div[@class="da-api-token__table-scope-cell da-api-token__table-scope-cell-admin"]
        ELSE
            Click Element    //*[@class="dc-icon dc-clipboard"]
            Click Element    //input[@name="token_name"]
            Press Keys    None    CTRL+v
            Should Not Be Empty    //input[@name="token_name"]
            Clear Input Fields
            Element Should Contain    //label[@class="dc-input__label"]    Token name
            Element Should Contain    //div[@class="da-api-token__table-scope-cell"]    ${item}
        END
        Click Element    //*[@data-testid="dt_token_delete_icon"]
        Wait Until Element Is Visible    ${submitDelete}
        Click Element    ${submitDelete}
        Sleep    1
        Page Should Not Contain    //div[@class="da-api-token__pass-dot-container"]
    END

Close Browser
    Close Browser
    
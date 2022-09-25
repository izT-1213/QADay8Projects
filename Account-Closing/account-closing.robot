*** Settings ***

Library    SeleniumLibrary

*** Variables ***
${testLink}    https://app.deriv.com/account/closing-account
${closeAccountbtn}    //button[@class="dc-btn dc-btn--primary dc-btn__large closing-account__button--close-account"]
${cancelBtn}    //button[@class="dc-btn dc-btn--secondary dc-btn__large closing-account__button--cancel"]
${backBtn}    //button[@class="dc-btn dc-btn__effect dc-btn--secondary dc-btn__large"]
@{CLOSEREASONS}=    financial-priorities    stop-trading    not-interested    another-website    not-user-friendly    difficult-transactions    lack-of-features    unsatisfactory-service    other-reasons

*** Keywords ***
Clear Input Fields
    Press Keys    None    CTRL+a\ue003

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

TC_04 Verify Default Page
    Wait Until Page Contains    Are you sure?    300
    Page Should Contain    Are you sure?
    Page Should Contain    If you close your account:
    Page Should Contain    Before closing your account:
    Page Should Contain    We shall delete your personal information
    Element Should Be Enabled    ${closeAccountbtn}
    Element Should Be Enabled    ${cancelBtn}
    Click Element    ${cancelBtn}
    Sleep    2
    Wait Until Location Contains    https://app.deriv.com    120
    Location Should Contain    https://app.deriv.com
    Sleep    2
    Go Back
    Wait Until Element Is Visible    ${closeAccountbtn}    60
    Click Button    ${closeAccountbtn}
    Wait Until Page Contains    Please tell us why you’re leaving. (Select up to 3 reasons.)    30
    Page Should Contain    Please tell us why you’re leaving. (Select up to 3 reasons.)

TC_05 Verify Default Page Pt2
    Wait Until Page Contains    Please tell us why you’re leaving. (Select up to 3 reasons.)   30
    Page Should Contain    Please tell us why you’re leaving. (Select up to 3 reasons.)
    Page Should Contain    I have other financial priorities.
    Page Should Contain    I want to stop myself from trading.
    FOR  ${item}  IN  @{CLOSEREASONS}
        Wait Until Page Contains Element    //input[@name='${item}']    60
        Checkbox Should Not Be Selected    //input[@name='${item}']
    END
    Element Should Be Enabled    ${backBtn}
    Click Button    ${backBtn}
    Wait Until Page Contains    Are you sure?    30
    Page Should Contain    Are you sure?
    Click Button    ${closeAccountbtn}
    Wait Until Page Contains    Please tell us why you’re leaving. (Select up to 3 reasons.)    30
    Element Should Be Disabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]

TC_06 Check Tickboxes
    FOR  ${item}  IN  @{CLOSEREASONS}
        Checkbox Should Not Be Selected    //input[@name='${item}']
        Click Element    //input[@name='${item}']//parent::label
        Checkbox Should Be Selected    //input[@name='${item}']
        Element Should Be Enabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
        Click Element    //input[@name='${item}']//parent::label
        Element Should Be Disabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
        Element Should Be Visible    //p[@class="dc-text closing-account-reasons__error"]
        Element Text Should Be    //p[@class="dc-text closing-account-reasons__error"]    Please select at least one reason
    END
    Click Element    //input[@name='financial-priorities']//parent::label
    Click Element    //input[@name='stop-trading']//parent::label
    Element Should Be Enabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
    Click Element    //input[@name='not-interested']//parent::label
    Element Should Be Enabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
    Element Should Be Disabled    //input[@name='another-website']
    Element Should Be Disabled    //input[@name='not-user-friendly']
    Element Should Be Disabled    //input[@name='difficult-transactions']
    Element Should Be Disabled    //input[@name='lack-of-features']
    Element Should Be Disabled    //input[@name='unsatisfactory-service']
    Element Should Be Disabled    //input[@name='other-reasons']
    Click Element    //input[@name='not-interested']//parent::label
    Click Element    //input[@name='stop-trading']//parent::label
    Click Element    //input[@name='financial-priorities']//parent::label
    Element Should Be Visible    //p[@class="dc-text closing-account-reasons__error"]    60
    Element Text Should Be    //p[@class="dc-text closing-account-reasons__error"]    Please select at least one reason

TC_07 Check Input Text Limit
    Click Element    //input[@name='financial-priorities']//parent::label
    Element Should Be Enabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
    Click Element    //textarea[@name="other_trading_platforms"]
    FOR  ${x}  IN RANGE    111
        Press Keys    None    a
    END
    ${descvalue}=    Get Text    //textarea[@name="other_trading_platforms"]
    ${length}=    Get Length    ${descvalue}
    Should Be Equal As Integers    ${length}    110
    Element Text Should Be    //p[@class="dc-text closing-account-reasons__hint"]    Remaining characters: 0
    Element Should Be Enabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
    Click Element    //textarea[@name="other_trading_platforms"]
    Clear Input Fields
    Click Element    //textarea[@name="do_to_improve"]
    FOR  ${x}  IN RANGE    111
        Press Keys    None    a
    END
    ${descvalue}=    Get Text    //textarea[@name="do_to_improve"]
    ${length}=    Get Length    ${descvalue}
    Should Be Equal As Integers    ${length}    110
    Element Should Be Enabled    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
    Click Element    //textarea[@name="do_to_improve"]
    Clear Input Fields

TC_08 Check Warning Pop Up
   Click Element    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
   Wait Until Element Is Visible    //div[@class="account-closure-warning-modal"]    60
   Element Should Be Visible    //div[@class="account-closure-warning-modal"]
   Element Should Be Visible    //button[@class="dc-btn dc-btn__effect dc-btn--secondary dc-btn__large"]
   Element Should Be Visible    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
   Click Button    //button[@class="dc-btn dc-btn__effect dc-btn--secondary dc-btn__large" and contains (span, 'Go Back')]
   Wait Until Page Does Not Contain    //div[@class="account-closure-warning-modal"]    60
   Click Element    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large"]
   Wait Until Element Is Visible    //div[@class="account-closure-warning-modal"]    60
   Click Button    //button[@class="dc-btn dc-btn__effect dc-btn--primary dc-btn__large" and contains (span, 'Close account')]
   Wait Until Location Is    https://deriv.com/    60
   Location Should Be    https://deriv.com/

Close Browser
    Close Browser

    
*** Settings ***
Library    RequestsLibrary    
Resource    ../keywords/auth.resource
Test Setup    Create Token
Test Template    Create Booking DDT

*** Test Cases ***
TC001    fulano    ciclano    80    false    2025-04-29    2025-04-30    piscina    
TC002    beltrano    ciclano    150    true    2025-04-29    2025-04-30    tenis de mesa

*** Keywords ***
Create Booking DDT
    [Arguments]    ${firstname}    ${lastname}    ${totalprice}    
    ...            ${depositpaid}    ${checkin}    ${checkout}
    ...            ${additionalneeds}
    &{bookingdates}    Create Dictionary    checkin=${checkin}    checkout=${checkout}
    ${depositpaid_boolean}    Run Keyword If    '${depositpaid}' == 'true'    Set Variable    ${True}    ELSE    Set Variable    ${False}

    ${body}    Create Dictionary    firstname=${firstname}    lastname=${lastname}
    ...             totalprice=${totalprice}      depositpaid=${depositpaid_boolean} 
    ...             bookingdates=${bookingdates}    additionalneeds=${additionalneeds}
    ${response}    POST    url=https://restful-booker.herokuapp.com/booking
    ...                    json=${body}   
    
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}
    Status Should Be    200

    ${bookingid}    Set Variable    ${response_body}[bookingid]
    Set Suite Variable    ${bookingid}

    Should Be Equal    ${response_body}[booking][firstname]                  ${firstname}
    Should Be Equal    ${response_body}[booking][lastname]                    ${lastname}
    Should Be Equal As Integers    ${response_body}[booking][totalprice]    ${totalprice}
    IF    ${depositpaid_boolean}
        Should Be True     ${response_body}[booking][depositpaid]
        Log To Console    Entrou no True 
    ELSE
        Should Not Be True    ${response_body}[booking][depositpaid]
        Log To Console    Entrou no False
    END
                
    Should Be Equal    ${response_body}[booking][bookingdates][checkin]        ${checkin}
    Should Be Equal    ${response_body}[booking][bookingdates][checkout]      ${checkout}
    Should Be Equal    ${response_body}[booking][additionalneeds]      ${additionalneeds}

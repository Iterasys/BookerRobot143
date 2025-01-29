*** Settings ***
Library    RequestsLibrary
Resource    ../keywords/auth.resource

Suite Setup    Create Token

*** Variables ***
${url}    https://restful-booker.herokuapp.com/booking  
${firstname}          Jose
${lastname}           Correia
${totalprice}         150
${depositpaid}        True
@{bookingdates}       {}  
${checkin}            2025-01-29
${checkout}           2025-01-30
${additionalneeds}    Breakfast

*** Test Cases ***
Create Booking
    ${body}    Evaluate    json.loads(open("./fixtures/json/booking1.json").read())
    ${response}    POST    url=${url}    json=${body}
    
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}

    Status Should Be    200

    ${bookingid}    Set Variable    ${response_body}[bookingid]
    Set Suite Variable    ${bookingid}

    Should Be Equal    ${response_body}[booking][firstname]                  ${firstname}
    Should Be Equal    ${response_body}[booking][lastname]                    ${lastname}
    Should Be Equal As Integers    ${response_body}[booking][totalprice]    ${totalprice}
    IF    ${depositpaid}
        Should Be True     ${response_body}[booking][depositpaid] 
    ELSE
        Should Not Be True    ${response_body}[booking][depositpaid]
    END
                
    Should Be Equal    ${response_body}[booking][bookingdates][checkin]        ${checkin}
    Should Be Equal    ${response_body}[booking][bookingdates][checkout]      ${checkout}
    Should Be Equal    ${response_body}[booking][additionalneeds]      ${additionalneeds}

Get Booking
    ${response}    GET    ${url}/${bookingid}

    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}

    Should Be Equal    ${response_body}[firstname]                  ${firstname}
    Should Be Equal    ${response_body}[lastname]                    ${lastname}
    Should Be Equal As Integers    ${response_body}[totalprice]    ${totalprice}
    IF    ${depositpaid}
        Should Be True     ${response_body}[depositpaid] 
    ELSE
        Should Not Be True    ${response_body}[depositpaid]
    END
                
    Should Be Equal    ${response_body}[bookingdates][checkin]        ${checkin}
    Should Be Equal    ${response_body}[bookingdates][checkout]      ${checkout}
    Should Be Equal    ${response_body}[additionalneeds]      ${additionalneeds}

Update Booking
    ${headers}    Create Dictionary    Content-Type=application/json
    ...                                Cookie=token=${token}
    ${body}    Evaluate    json.loads(open("./fixtures/json/booking2.json").read())
    ${response}    PUT    url=${url}/${bookingid}
    ...                   headers=${headers}
    ...                   json=${body}
    
    ${response_body}    Set Variable    ${response.json()}   
    Log To Console      ${response_body}

    Status Should Be    200

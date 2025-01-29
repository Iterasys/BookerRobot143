*** Settings ***
Library    RequestsLibrary

*** Keywords ***
Create Token
    ${body}    Create Dictionary    username=admin    password=password123
    ${response}    POST    url=https://restful-booker.herokuapp.com/auth    json=${body}

    Status Should Be    200
    ${token}    Set Variable    ${response.json()}[token]
    Set Suite Variable    ${token}
    Log To Console    token:${token}


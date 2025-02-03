*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    SeleniumLibrary
# Library    RPA.JSON
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
    Validar Agendamento    ${response}    ${totalprice}    ${checkout}    ${additionalneeds}

Update Booking
    ${headers}    Create Dictionary    Content-Type=application/json
    ...                                Cookie=token=${token}
    ${body}    Evaluate    json.loads(open("./fixtures/json/booking2.json").read())
    ${response}    PUT    url=${url}/${bookingid}
    ...                   headers=${headers}
    ...                   json=${body}
    
    Validar Agendamento    ${response}    300    2025-01-31    ${additionalneeds}        

Get Booking Ids - All Bookings - Zero Parameters
# inicialmente não vamos passar parametros e todos os registros serão retornados
    ${response}    GET    ${url}

    ${response_body}    Set Variable    ${response.json()}   
    Log To Console      ${response_body}

    Status Should Be    200

Get Booking Ids - Filters by Name - 2 Parameters
# inicialmente não vamos passar parametros e todos os registros serão retornados 
    ${response}    GET    url=${url}?firstname=${firstname}&lastname=${lastname}

    ${response_body}    Set Variable    ${response.json()}   
    Log To Console      ${response_body}

    Status Should Be    200
    # Verificar se o id do último registro criado está na lista
    ${ids}    Get Value From Json   ${response_body}    $[*].bookingid
    List Should Contain Value    ${ids}    ${bookingid}

    # contagem de agendamentos
    ${count}    Get Length    ${ids}
    Log To Console    Nº de Agendamentos: ${ids}


Partial Update Booking
    # Opção 1
    # ${additionalneeds}    Set Variable    Dinner
    # ${body}    Create Dictionary    ${additionalneeds}

    # Opção 2
    ${body}    Create Dictionary    additionalneeds=Dinner

    ${headers}    Create Dictionary    Content-Type=application/json
    ...                                Cookie=token=${token}

    ${response}    PATCH    url=${url}/${bookingid}    json=${body}
    ...                     headers=${headers}

   Validar Agendamento    ${response}    300    2025-01-31    Dinner 

Delete Booking
   ${headers}    Create Dictionary    Content-Type=application/json
   ...                                Cookie=token=${token}
   
   ${response}    DELETE    url=${url}/${bookingid}
   ...                      headers=${headers}

   Status Should Be    201    


*** Keywords ***
Validar Agendamento   
    [Arguments]    ${response}    ${expected_totalprice}    ${expected_checkout}
    ...            ${expected_additionalneeds}

    ${response_body}    Set Variable    ${response.json()}   
    Log To Console      ${response_body}

    Status Should Be    200
    Should Be Equal    ${response_body}[firstname]                  ${firstname}
    Should Be Equal    ${response_body}[lastname]                    ${lastname}
    Should Be Equal As Integers    ${response_body}[totalprice]    ${expected_totalprice}
    IF    ${depositpaid}
        Should Be True     ${response_body}[depositpaid] 
    ELSE
        Should Not Be True    ${response_body}[depositpaid]
    END
                
    Should Be Equal    ${response_body}[bookingdates][checkin]        ${checkin}
    Should Be Equal    ${response_body}[bookingdates][checkout]      ${expected_checkout}
    Should Be Equal    ${response_body}[additionalneeds]      ${expected_additionalneeds}
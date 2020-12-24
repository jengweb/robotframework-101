*** Settings ***
Library    RequestsLibrary
Library    Collections
Suite Setup    Create Session    ${toy_store}    ${URL}    verify=true
Suite Teardown    Delete All Sessions
Test Template    Checkout Product
Resource     ./resources.robot

*** Test Cases ***
Checkout Dinner Set    ${2}    ${2}    43 Piece dinner Set    1    ${14.95}    ${12.95}
Checkout Bicycle    ${2}    ${1}    Balance Training Bicycle    2    ${241.90}    ${119.95}

*** Keywords ***
Checkout Product
    [Arguments]    ${total}    ${product_id}    ${product_name}    ${quantity}    ${total_price}    ${product_price}
    Get Product List    ${total}
    Get Product Detail    ${product_id}    ${product_name}    ${product_price}
    Order Product    ${product_id}    ${quantity}    ${total_price}
    Confirm Payment    ${total_price}

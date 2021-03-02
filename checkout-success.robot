*** Settings ***
Library    RequestsLibrary

*** Variables ***


*** Test Cases ***
Checkout Dinner Set
    Get Product List
    Get Product Detail
    Order Product
    Confirm Payment
    Delete All Sessions

*** Keywords ***
Get Product List
    Create Session   toy_store   https://dminer.in.th    verify=true
    &{accept}=   Create Dictionary   Accept=application/json
    
    ${productList}=   GET On Session   toy_store   /api/v1/product    headers=&{accept}

    Status Should Be  200   ${productList}
    Should Be Equal   ${productList.json()["total"]}   ${2}

Get Product Detail
    Create Session   toy_store   https://dminer.in.th    verify=true
    &{accept}=   Create Dictionary   Accept=application/json

    ${productDetail}=    GET On Session    toy_store    /api/v1/product/2    headers=&{accept}

    Request Should Be Successful    ${productDetail}
    Should Be Equal    ${productDetail.json()["id"]}    ${2}
    Should Be Equal    ${productDetail.json()["product_name"]}    43 Piece dinner Set
    Should Be Equal    ${productDetail.json()["product_price"]}    ${12.95}

Order Product
    Create Session   toy_store    https://dminer.in.th    verify=true
    ${order}=    To Json    {"cart":[{"product_id": 2,"quantity": 1}], "shipping_method": "Kerry", "shipping_address": "405/37 ถ.มหิดล", "shipping_sub_district": "ท่าศาลา", "shipping_district": "เมือง", "shipping_province": "เชียงใหม่", "shipping_zip_code": "50000", "recipient_name": "ณัฐญา ชุติบุตร", "recipient_phone_number": "0970809292"}
    &{post_headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json

    ${orderStatus}=    POST On Session    toy_store    /api/v1/order    json=${order}    headers=&{post_headers}

    Request Should Be Successful    ${orderStatus}
    Should Be Equal    ${orderStatus.json()["total_price"]}    ${14.95}
    Set Test Variable    ${order_id}    ${orderStatus.json()["order_id"]}

Confirm Payment
    Create Session   toy_store   https://dminer.in.th    verify=true
    ${confirmPayment}=    To Json    {"order_id": ${order_id}, "payment_type": "credit", "type": "visa", "card_number": "4719700591590995", "cvv": "752", "expired_month": 7, "expired_year": 20, "card_name": "Karnwat Wongudom", "total_price": 14.95}
    &{post_headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json

    ${confirmPaymentStatus}=     POST On Session    toy_store    /api/v1/confirmPayment    json=${confirmPayment}    headers=&{post_headers}

    Request Should Be Successful    ${confirmPaymentStatus}
    Should Match Regexp    ${confirmPaymentStatus.json()["notify_message"]}    \\d{1,2}/\\d{1,2}/\\d{4} \\d{2}:\\d{2}:\\d{2}
    Should Match Regexp    ${confirmPaymentStatus.json()["notify_message"]}    \\d{10}$
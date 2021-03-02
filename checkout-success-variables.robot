*** Settings ***
Library    RequestsLibrary

*** Variables ***
${toy_store}
${URL}        https://dminer.in.th
&{CONTENT_TYPE}      Content-Type=application/json
&{ACCEPT}            Accept=application/json
&{POST_HEADERS}      &{ACCEPT}    &{CONTENT_TYPE}
${ORDER_TEMPLATE}    {"cart":[{"product_id": 2,"quantity": 1}],"shipping_method": "Kerry","shipping_address": "405/37 ถ.มหิดล","shipping_sub_district": "ท่าศาลา","shipping_district": "เมือง","shipping_province": "เชียงใหม่","shipping_zip_code": "50000","recipient_name": "ณัฐญา ชุติบุตร","recipient_phone_number": "0970809292"}
${CONFIRM_PAYMENT_TEMPLATE}    {"order_id": \${order_id}, "payment_type": "credit", "type": "visa", "card_number": "4719700591590995", "cvv": "752", "expired_month": 7, "expired_year": 20, "card_name": "Karnwat Wongudom", "total_price": 14.95}
${OK}         200

*** Test Cases ***
Checkout Dinner Set
    Get Product List
    Get Product Detail
    Order Product
    Confirm Payment
    Delete All Sessions

*** Keywords ***
Get Product List
    Create Session   ${toy_store}   ${URL}    verify=true
    
    ${productList}=   GET On Session   ${toy_store}   /api/v1/product    headers=&{ACCEPT}

    Status Should Be  ${OK}   ${productList}
    Should Be Equal   ${productList.json()["total"]}   ${2}

Get Product Detail
    Create Session   ${toy_store}   ${URL}    verify=true

    ${productDetail}=    GET On Session    ${toy_store}    /api/v1/product/2    headers=&{ACCEPT}

    Request Should Be Successful    ${productDetail}
    Should Be Equal    ${productDetail.json()["id"]}    ${2}
    Should Be Equal    ${productDetail.json()["product_name"]}    43 Piece dinner Set
    Should Be Equal    ${productDetail.json()["product_price"]}    ${12.95}

Order Product
    Create Session   ${toy_store}    ${URL}    verify=true
    ${order}=    To Json    ${ORDER_TEMPLATE}

    ${orderStatus}=    POST On Session    ${toy_store}    /api/v1/order    json=${order}    headers=&{POST_HEADERS}

    Request Should Be Successful    ${orderStatus}
    Should Be Equal    ${orderStatus.json()["total_price"]}    ${14.95}
    Set Test Variable    ${order_id}    ${orderStatus.json()["order_id"]}

Confirm Payment
    Create Session   ${toy_store}   ${URL}    verify=true
    # ${confirmPayment}=    To Json    ${CONFIRM_PAYMENT_TEMPLATE}
    ${confirmPayment}=    Replace Variables    ${CONFIRM_PAYMENT_TEMPLATE}

    ${confirmPaymentStatus}=     POST On Session    ${toy_store}    /api/v1/confirmPayment    json=${confirmPayment}    headers=&{POST_HEADERS}

    Request Should Be Successful    ${confirmPaymentStatus}
    Should Match Regexp    ${confirmPaymentStatus.json()["notify_message"]}    \\d{1,2}/\\d{1,2}/\\d{4} \\d{2}:\\d{2}:\\d{2}
    Should Match Regexp    ${confirmPaymentStatus.json()["notify_message"]}    \\d{10}$
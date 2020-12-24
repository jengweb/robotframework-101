*** Settings ***
Library    RequestsLibrary
Library    Collections
Suite Setup    Create Session    ${toy_store}    ${URL}    verify=true
Suite Teardown    Delete All Sessions
Test Template    Checkout Product

*** Variables ***
${toy_store}
${URL}    https://dminer.in.th
&{CONTENT_TYPE}    Content-Type=application/json
&{ACCEPT}    Accept=application/json
&{POST_HEADERS}    &{ACCEPT}    &{CONTENT_TYPE}
${ORDER_TEMPLATE}    {"cart":[{"product_id": \${product_id},"quantity": \${quantity}}],"shipping_method": "Kerry","shipping_address": "405/37 ถ.มหิดล","shipping_sub_district": "ท่าศาลา","shipping_district": "เมือง","shipping_province": "เชียงใหม่","shipping_zip_code": "50000","recipient_name": "ณัฐญา ชุติบุตร","recipient_phone_number": "0970809292"}
${CONFIRM_PAYMENT_TEMPLATE}    {"order_id": \${order_id}, "payment_type": "credit", "type": "visa", "card_number": "4719700591590995", "cvv": "752", "expired_month": 7, "expired_year": 20, "card_name": "Karnwat Wongudom", "total_price": \${total_price}}
${OK}    200

*** Test Cases ***
Checkout Dinner Set    ${2}    ${2}    43 Piece dinner Set    1    ${14.95}    ${12.95}
Checkout Bicycle    ${2}    ${1}    Balance Training Bicycle    2    ${241.90}    ${119.95}

# Checkout Dinner Set
#     Get Product List    ${2}
#     Get Product Detail    ${2}    43 Piece dinner Set    ${12.95}
#     Order Product    2    1    ${14.95}
#     Confirm Payment    14.95

# Checkout Bicycle
#     Get Product List    ${2}
#     Get Product Detail    ${1}    Balance Training Bicycle    ${119.45}
#     Order Product    1    2    ${241.90}
#     Confirm Payment    241.90

*** Keywords ***
Checkout Product
    [Arguments]    ${total}    ${product_id}    ${product_name}    ${quantity}    ${total_price}    ${product_price}
    Get Product List    ${total}
    # Find Product by Name    ${product_name}
    Get Product Detail    ${product_id}    ${product_name}    ${product_price}
    Order Product    ${product_id}    ${quantity}    ${total_price}
    Confirm Payment    ${total_price}

Find Product by Name
    [Arguments]    ${product_name}
    ${id}=    Set Variable    ${0}
    FOR     ${product}    IN     @{products}
        ${id}=      Set Variable    ${product["id"]}
        Run Keyword If    '${product["product_name"]}' == '${product_name}'   Exit For Loop
        ${id}=      Set Variable    ${0}
    END
    Should Be True     ${id} != 0    product id should not equal 0
    Set Test Variable    ${product_id}    ${id}

Get Product List
    [Arguments]    ${total}
    ${productList}=   Get Request   ${toy_store}   /api/v1/product    headers=&{ACCEPT}

    Status Should Be  ${OK}   ${productList}
    Should Be Equal   ${productList.json()["total"]}   ${total}

    ${products}=    Get From Dictionary    ${productList.json()}    products
    Set Test Variable    ${products}    ${products}
    
Get Product Detail
    [Arguments]    ${product_id}    ${product_name}    ${product_price}
    ${productDetail}=    Get Request    ${toy_store}    /api/v1/product/${product_id}    headers=&{ACCEPT}

    Request Should Be Successful    ${productDetail}
    Should Be Equal    ${productDetail.json()["id"]}    ${product_id}
    Should Be Equal    ${productDetail.json()["product_name"]}    ${product_name}
    Should Be Equal    ${productDetail.json()["product_price"]}    ${product_price}

Order Product
    [Arguments]    ${product_id}    ${quantity}    ${total_price}
    ${order}=    Replace Variables    ${ORDER_TEMPLATE}

    ${orderStatus}=    Post Request    ${toy_store}    /api/v1/order    json=${order}    headers=&{POST_HEADERS}

    Request Should Be Successful    ${orderStatus}
    # Should Be Equal    ${orderStatus.json()["total_price"]}    ${total_price}
    Should Be Equal As Numbers    ${orderStatus.json()["total_price"]}    ${total_price}
    Set Test Variable    ${order_id}    ${orderStatus.json()["order_id"]}

Confirm Payment
    [Arguments]    ${total_price}
    ${confirmPayment}=    Replace Variables    ${CONFIRM_PAYMENT_TEMPLATE}

    ${confirmPaymentStatus}=    Post Request    ${toy_store}    /api/v1/confirmPayment    json=${confirmPayment}    headers=&{POST_HEADERS}

    Request Should Be Successful    ${confirmPaymentStatus}
    Should Match Regexp    ${confirmPaymentStatus.json()["notify_message"]}    \\d{1,2}/\\d{1,2}/\\d{4} \\d{2}:\\d{2}:\\d{2}
    Should Match Regexp    ${confirmPaymentStatus.json()["notify_message"]}    \\d{10}$